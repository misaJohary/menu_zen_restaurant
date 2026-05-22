import 'package:design_system/design_system.dart';
import 'package:domain/entities/customer_entity.dart';
import 'package:domain/entities/opening_hours_entity.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../../core/navigation/route_paths.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/reservation_request/reservation_request_cubit.dart';

/// Entry point for "Request a reservation".
///
/// Loads the restaurant (or uses a pre-passed entity) to know its opening
/// hours, then renders the request form. The actual cubit submits to the
/// backend with status `waiting`.
class ReservationRequestPage extends StatelessWidget {
  final int restaurantId;
  final RestaurantPublicEntity? initialRestaurant;

  const ReservationRequestPage({
    super.key,
    required this.restaurantId,
    this.initialRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) => switch (authState) {
        AuthAuthenticated(:final customer) => BlocProvider(
          create: (_) => getIt<ReservationRequestCubit>(),
          child: _ReservationRequestView(
            restaurantId: restaurantId,
            initialRestaurant: initialRestaurant,
            customer: customer,
          ),
        ),
        AuthInitial() ||
        AuthSubmitting() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        AuthUnauthenticated() => _SignedOutScaffold(),
      },
    );
  }
}

class _SignedOutScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reservationRequestTitle)),
      body: SafeArea(
        child: EmptyState(
          icon: PhosphorIconsDuotone.calendarPlus,
          title: l10n.reservationSignedOutTitle,
          body: l10n.reservationSignedOutBody,
          actionLabel: l10n.reservationSignedOutAction,
          onAction: () => context.push(RoutePaths.authLogin),
        ),
      ),
    );
  }
}

class _ReservationRequestView extends StatefulWidget {
  final int restaurantId;
  final RestaurantPublicEntity? initialRestaurant;
  final CustomerEntity customer;

  const _ReservationRequestView({
    required this.restaurantId,
    required this.initialRestaurant,
    required this.customer,
  });

  @override
  State<_ReservationRequestView> createState() =>
      _ReservationRequestViewState();
}

class _ReservationRequestViewState extends State<_ReservationRequestView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtl;
  late final TextEditingController _noteCtl;

  RestaurantPublicEntity? _restaurant;
  String? _loadError;
  bool _loading = false;

  DateTime? _selectedDate;
  String? _selectedSlot; // "HH:MM"
  int _partySize = 2;

  // Visible date strip: 14 chips starting tomorrow. Beyond that the user taps
  // "More…" to open a full calendar picker.
  static const int _dayStripLength = 14;

  @override
  void initState() {
    super.initState();
    _phoneCtl = TextEditingController(text: widget.customer.phone ?? '');
    _noteCtl = TextEditingController();
    _restaurant = widget.initialRestaurant;
    if (_restaurant == null) {
      _loadRestaurant();
    }
    // Auto-select tomorrow so the user sees slots immediately.
    _selectedDate = _tomorrow();
  }

  DateTime _tomorrow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _phoneCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurant() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final result = await getIt<PublicRestaurantsRepository>().getRestaurant(
      widget.restaurantId,
    );
    if (!mounted) return;
    if (result.isSuccess && result.getSuccess != null) {
      setState(() {
        _restaurant = result.getSuccess;
        _loading = false;
      });
    } else {
      setState(() {
        _loadError = result.getError?.message;
        _loading = false;
      });
    }
  }

  List<DateTime> get _days {
    final start = _tomorrow();
    return List.generate(
      _dayStripLength,
      (i) => start.add(Duration(days: i)),
    );
  }

  /// Whether [_selectedDate] is outside the visible strip (i.e. the user
  /// picked it via the full calendar). Drives the trailing "More…" chip.
  bool get _isSelectedDateBeyondStrip {
    if (_selectedDate == null) return false;
    final lastStripDay = _tomorrow().add(
      const Duration(days: _dayStripLength - 1),
    );
    return _selectedDate!.isAfter(lastStripDay);
  }

  Future<void> _openCalendar() async {
    final first = _tomorrow().add(const Duration(days: _dayStripLength));
    final initial = _isSelectedDateBeyondStrip ? _selectedDate! : first;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: _tomorrow().add(const Duration(days: 365)),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _selectedDate = picked;
      _selectedSlot = null;
    });
  }

  List<String> _slotsForDate(DateTime date) {
    const stepMinutes = 60;
    final hours = _restaurant?.openingHours;
    if (hours == null) {
      // Fallback: hourly slots between 11:00 and 22:00 if the restaurant has
      // not published opening hours.
      return _generateSlots(11 * 60, 22 * 60, stepMinutes);
    }
    final dayKey = date.weekday - 1;
    final daySlots = hours.periods[dayKey] ?? const <OpeningHoursSlotEntity>[];
    final result = <String>[];
    for (final slot in daySlots) {
      final open = _parseHHmm(slot.open);
      final close = _parseHHmm(slot.close);
      if (open == null || close == null) continue;
      result.addAll(_generateSlots(open, close, stepMinutes));
    }
    return result;
  }

  List<String> _generateSlots(int openMinutes, int closeMinutes, int step) {
    final out = <String>[];
    // Round up to the next hour so we don't render half-hour starts when
    // opening hours begin at e.g. 11:30.
    final rounded = ((openMinutes + step - 1) ~/ step) * step;
    for (var m = rounded; m + step <= closeMinutes; m += step) {
      out.add(_formatMinutes(m));
    }
    return out;
  }

  bool _isSlotInPast(DateTime date, String hhmm) {
    final minutes = _parseHHmm(hhmm);
    if (minutes == null) return true;
    final slotMoment = DateTime(
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    );
    return !slotMoment.isAfter(DateTime.now());
  }

  DateTime _composeReservedAt(DateTime date, String hhmm) {
    final minutes = _parseHHmm(hhmm) ?? 0;
    return DateTime(date.year, date.month, date.day, minutes ~/ 60, minutes % 60);
  }

  void _submit() {
    if (_restaurant == null) return;
    if (_selectedDate == null || _selectedSlot == null) return;
    if (!_formKey.currentState!.validate()) return;
    final reservedAt = _composeReservedAt(_selectedDate!, _selectedSlot!);
    if (!reservedAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).reservationErrorPastTime,
            ),
          ),
        );
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<ReservationRequestCubit>().submit(
      restaurantId: widget.restaurantId,
      reservedAt: reservedAt,
      phone: _phoneCtl.text.trim(),
      partySize: _partySize,
      note: _noteCtl.text.trim().isEmpty ? null : _noteCtl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reservationRequestTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_restaurant == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reservationRequestTitle)),
        body: EmptyState(
          icon: PhosphorIconsDuotone.wifiSlash,
          title: l10n.commonReachKitchenError,
          body: _loadError ?? '',
          actionLabel: l10n.commonTryAgain,
          onAction: _loadRestaurant,
        ),
      );
    }

    return BlocConsumer<ReservationRequestCubit, ReservationRequestState>(
      listener: (context, state) {
        switch (state) {
          case ReservationRequestSubmitted(:final reservation):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(l10n.reservationSuccessToast)),
              );
            context.pushReplacement(
              RoutePaths.reservationDetail(reservation.id),
              extra: reservation,
            );
          case ReservationRequestError(:final message):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          default:
            break;
        }
      },
      builder: (context, state) {
        final submitting = state is ReservationRequestSubmitting;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.reservationRequestTitle)),
          body: SafeArea(
            child: _RequestForm(
              formKey: _formKey,
              restaurant: _restaurant!,
              days: _days,
              selectedDate: _selectedDate,
              isSelectedDateBeyondStrip: _isSelectedDateBeyondStrip,
              selectedSlot: _selectedSlot,
              partySize: _partySize,
              phoneCtl: _phoneCtl,
              noteCtl: _noteCtl,
              submitting: submitting,
              slotsForDate: _slotsForDate,
              isSlotInPast: _isSlotInPast,
              onDateChanged: (d) {
                setState(() {
                  _selectedDate = d;
                  _selectedSlot = null;
                });
              },
              onMoreDates: _openCalendar,
              onSlotChanged: (s) => setState(() => _selectedSlot = s),
              onPartySizeChanged: (p) => setState(() => _partySize = p),
              onSubmit: _submit,
            ),
          ),
        );
      },
    );
  }
}

class _RequestForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final RestaurantPublicEntity restaurant;
  final List<DateTime> days;
  final DateTime? selectedDate;
  final bool isSelectedDateBeyondStrip;
  final String? selectedSlot;
  final int partySize;
  final TextEditingController phoneCtl;
  final TextEditingController noteCtl;
  final bool submitting;
  final List<String> Function(DateTime) slotsForDate;
  final bool Function(DateTime, String) isSlotInPast;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onMoreDates;
  final ValueChanged<String> onSlotChanged;
  final ValueChanged<int> onPartySizeChanged;
  final VoidCallback onSubmit;

  const _RequestForm({
    required this.formKey,
    required this.restaurant,
    required this.days,
    required this.selectedDate,
    required this.isSelectedDateBeyondStrip,
    required this.selectedSlot,
    required this.partySize,
    required this.phoneCtl,
    required this.noteCtl,
    required this.submitting,
    required this.slotsForDate,
    required this.isSlotInPast,
    required this.onDateChanged,
    required this.onMoreDates,
    required this.onSlotChanged,
    required this.onPartySizeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dayLabel = DateFormat('EEE', localeTag);
    final dateLabel = DateFormat('d', localeTag);

    final effectiveDate = selectedDate;
    final slots = effectiveDate == null
        ? const <String>[]
        : slotsForDate(effectiveDate);
    final hasOpeningHours = restaurant.openingHours != null;
    final moreLabel = isSelectedDateBeyondStrip && selectedDate != null
        ? DateFormat.MMMd(localeTag).format(selectedDate!)
        : l10n.reservationMoreDates;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xxxl,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RestaurantHeader(restaurant: restaurant),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.reservationDateLabel,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                // +1 trailing slot for the "More…" calendar chip.
                itemCount: days.length + 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.s),
                itemBuilder: (_, index) {
                  if (index == days.length) {
                    return _MoreDateChip(
                      label: moreLabel,
                      selected: isSelectedDateBeyondStrip,
                      onTap: onMoreDates,
                    );
                  }
                  final day = days[index];
                  final isSelected =
                      !isSelectedDateBeyondStrip &&
                      selectedDate != null &&
                      day.year == selectedDate!.year &&
                      day.month == selectedDate!.month &&
                      day.day == selectedDate!.day;
                  return _DateChip(
                    weekday: dayLabel.format(day).toUpperCase(),
                    day: dateLabel.format(day),
                    selected: isSelected,
                    onTap: () => onDateChanged(day),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(l10n.reservationTimeLabel, style: textTheme.titleMedium),
            if (!hasOpeningHours) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.reservationOpeningHoursMissing,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s),
            if (selectedDate == null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Text(
                  l10n.reservationPickDateFirst,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              )
            else if (slots.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Text(
                  l10n.reservationNoTimes,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  for (final slot in slots)
                    _SlotPill(
                      label: slot,
                      selected: slot == selectedSlot,
                      disabled: isSlotInPast(effectiveDate!, slot),
                      onTap: () => onSlotChanged(slot),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.l),
            Text(l10n.reservationPartySizeLabel, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            _PartySizeSelector(
              value: partySize,
              onChanged: onPartySizeChanged,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(l10n.reservationPhoneLabel, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: phoneCtl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 \-\(\)\+]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.reservationPhoneLabel,
                prefixIcon: const Icon(PhosphorIconsRegular.phone),
              ),
              validator: (v) {
                final trimmed = (v ?? '').trim();
                if (trimmed.isEmpty) {
                  return l10n.reservationPhoneRequired;
                }
                final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.length < 6) {
                  return l10n.reservationPhoneInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.l),
            Text(l10n.reservationNoteLabel, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: noteCtl,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: l10n.reservationNoteHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: submitting ? null : onSubmit,
              icon: const Icon(PhosphorIconsRegular.paperPlaneTilt),
              label: submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.reservationSubmit),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              l10n.reservationSubmitHint,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  final RestaurantPublicEntity restaurant;
  const _RestaurantHeader({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: SizedBox(
            width: 56,
            height: 56,
            child: restaurant.logo != null
                ? Image.network(
                    restaurant.logo!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _RestaurantInitial(name: restaurant.name),
                  )
                : _RestaurantInitial(name: restaurant.name),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(restaurant.name, style: textTheme.titleMedium),
              if (restaurant.city.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  restaurant.city,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RestaurantInitial extends StatelessWidget {
  final String name;
  const _RestaurantInitial({required this.name});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
            ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String weekday;
  final String day;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({
    required this.weekday,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.effectiveDuration(context, AppMotion.tap),
        width: 56,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekday,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
                color: selected
                    ? scheme.onPrimary.withValues(alpha: 0.85)
                    : scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _SlotPill({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: disabled ? null : (_) => onTap(),
      labelStyle: TextStyle(
        color: disabled
            ? scheme.onSurface.withValues(alpha: 0.35)
            : selected
            ? scheme.onPrimary
            : scheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: scheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        side: BorderSide(
          color: selected
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

/// Modern, compact party-size selector: pills 1–6 plus a "More…" pill that
/// opens a stepper dialog for larger groups. Mirrors the OpenTable/Resy
/// pattern — one tap covers the common cases, a single secondary action
/// covers everything else.
class _PartySizeSelector extends StatelessWidget {
  static const int _inlineMax = 6;
  static const int _absoluteMax = 200;

  final int value;
  final ValueChanged<int> onChanged;
  const _PartySizeSelector({required this.value, required this.onChanged});

  Future<void> _openMoreDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    int draft = value <= _inlineMax ? _inlineMax + 1 : value;
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            title: Text(l10n.reservationPartySizeLabel),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.outlined(
                  onPressed: draft > _inlineMax + 1
                      ? () => setLocal(() => draft -= 1)
                      : null,
                  icon: const Icon(PhosphorIconsRegular.minus),
                ),
                Text(
                  l10n.reserveGuests(draft),
                  style: Theme.of(ctx).textTheme.headlineSmall,
                ),
                IconButton.outlined(
                  onPressed: draft < _absoluteMax
                      ? () => setLocal(() => draft += 1)
                      : null,
                  icon: const Icon(PhosphorIconsRegular.plus),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(draft),
                child: Text(l10n.commonApply),
              ),
            ],
          ),
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final moreSelected = value > _inlineMax;
    final moreLabel = moreSelected
        ? l10n.reserveGuests(value)
        : l10n.reservationMoreParty;
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (var n = 1; n <= _inlineMax; n++)
          _PartyPill(
            label: '$n',
            selected: !moreSelected && value == n,
            onTap: () => onChanged(n),
          ),
        _PartyPill(
          label: moreLabel,
          selected: moreSelected,
          onTap: () => _openMoreDialog(context),
        ),
      ],
    );
  }
}

class _PartyPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PartyPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.effectiveDuration(context, AppMotion.tap),
        constraints: const BoxConstraints(minWidth: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.18),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MoreDateChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MoreDateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.effectiveDuration(context, AppMotion.tap),
        constraints: const BoxConstraints(minWidth: 72),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsRegular.calendarDots,
              size: 16,
              color: selected
                  ? scheme.onPrimary
                  : scheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int? _parseHHmm(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}

String _formatMinutes(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}
