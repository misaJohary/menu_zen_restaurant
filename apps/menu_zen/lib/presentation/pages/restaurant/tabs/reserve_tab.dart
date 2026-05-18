import 'package:design_system/design_system.dart';
import 'package:domain/entities/opening_hours_entity.dart';
import 'package:domain/entities/restaurant_detail_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ReserveTab extends StatefulWidget {
  final RestaurantDetailPublicEntity detail;
  const ReserveTab({super.key, required this.detail});

  @override
  State<ReserveTab> createState() => _ReserveTabState();
}

class _ReserveTabState extends State<ReserveTab> {
  late DateTime _selectedDate;
  int _partySize = 2;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  List<DateTime> get _days {
    final today = _selectedDate;
    return List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
  }

  List<String> get _slots {
    // TODO(api): replace with a real `/restaurants/{id}/availability` endpoint.
    final hours = widget.detail.openingHours;
    if (hours == null) return const [];
    final dayKey = _selectedDate.weekday - 1;
    final daySlots = hours.periods[dayKey] ?? const <OpeningHoursSlotEntity>[];
    final result = <String>[];
    for (final slot in daySlots) {
      final open = _toMinutes(slot.open);
      final close = _toMinutes(slot.close);
      if (open == null || close == null) continue;
      for (var minutes = open; minutes + 30 <= close; minutes += 30) {
        result.add(_formatMinutes(minutes));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final slots = _slots;

    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dayLabel = DateFormat('EEE', localeTag);
    final dateLabel = DateFormat('d', localeTag);
    final ctaDateLabel = DateFormat('MMM d', localeTag);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xxxl,
      ),
      children: [
        Text(l10n.reserveChooseDate, style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.s),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
            itemBuilder: (_, index) {
              final day = _days[index];
              final isSelected =
                  day.day == _selectedDate.day &&
                      day.month == _selectedDate.month &&
                      day.year == _selectedDate.year;
              return _DateChip(
                weekday: dayLabel.format(day).toUpperCase(),
                day: dateLabel.format(day),
                selected: isSelected,
                onTap: () => setState(() {
                  _selectedDate = day;
                  _selectedSlot = null;
                }),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(l10n.reservePartySize, style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.s),
        _PartySizeStepper(
          value: _partySize,
          onChanged: (v) => setState(() => _partySize = v),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(l10n.reservePickTime, style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.s),
        if (slots.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Text(
              l10n.reserveNoTimes,
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
                  selected: slot == _selectedSlot,
                  onTap: () => setState(() => _selectedSlot = slot),
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: _selectedSlot == null ? null : () {},
          icon: const Icon(PhosphorIconsRegular.calendarCheck),
          label: Text(
            _selectedSlot == null
                ? l10n.reservePickTime
                : l10n.reserveCta(
                    _partySize,
                    ctaDateLabel.format(_selectedDate),
                    _selectedSlot!,
                  ),
          ),
        ),
      ],
    );
  }

  int? _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
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

class _PartySizeStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _PartySizeStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(PhosphorIconsRegular.minus),
          ),
          SizedBox(
            width: 96,
            child: Text(
              AppLocalizations.of(context).reserveGuests(value),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            onPressed: value < 20 ? () => onChanged(value + 1) : null,
            icon: const Icon(PhosphorIconsRegular.plus),
          ),
        ],
      ),
    );
  }
}

class _SlotPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SlotPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimary : scheme.onSurface,
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
