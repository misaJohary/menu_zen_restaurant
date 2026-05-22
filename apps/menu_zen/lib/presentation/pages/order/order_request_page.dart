import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/entities/customer_entity.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:domain/params/customer_order_item_create_params.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../../core/navigation/route_paths.dart';
import '../../../core/utils/translations.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/order_request/order_request_cubit.dart';

/// Customer-facing entry point for placing a delivery order.
///
/// A single page that walks through 4 sub-steps without route changes so the
/// in-progress cart and form fields never go through navigation. Items are
/// fetched independently of the restaurant detail page so deep-links work.
class OrderRequestPage extends StatelessWidget {
  final int restaurantId;
  final RestaurantPublicEntity? initialRestaurant;

  const OrderRequestPage({
    super.key,
    required this.restaurantId,
    this.initialRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) => switch (authState) {
        AuthAuthenticated(:final customer) => BlocProvider(
          create: (_) => getIt<OrderRequestCubit>(),
          child: _OrderRequestView(
            restaurantId: restaurantId,
            initialRestaurant: initialRestaurant,
            customer: customer,
          ),
        ),
        AuthInitial() || AuthSubmitting() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        AuthUnauthenticated() || AuthOffline() => _SignedOutScaffold(),
      },
    );
  }
}

class _SignedOutScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderRequestTitle)),
      body: SafeArea(
        child: EmptyState(
          icon: PhosphorIconsDuotone.shoppingBag,
          title: l10n.orderSignedOutTitle,
          body: l10n.orderSignedOutBody,
          actionLabel: l10n.orderSignedOutAction,
          onAction: () => context.push(RoutePaths.authLogin),
        ),
      ),
    );
  }
}

class _OrderRequestView extends StatefulWidget {
  final int restaurantId;
  final RestaurantPublicEntity? initialRestaurant;
  final CustomerEntity customer;

  const _OrderRequestView({
    required this.restaurantId,
    required this.initialRestaurant,
    required this.customer,
  });

  @override
  State<_OrderRequestView> createState() => _OrderRequestViewState();
}

class _OrderRequestViewState extends State<_OrderRequestView> {
  static const int _stepCount = 4;
  static final _priceFormat = NumberFormat.decimalPattern();

  final PageController _pageController = PageController();
  late final TextEditingController _addressCtl;
  late final TextEditingController _notesCtl;
  late final TextEditingController _phoneCtl;
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();

  int _currentStep = 0;

  /// Quantity selected per `menuItem.id`. Items not in the map are not in the
  /// cart.
  final Map<int, int> _qty = {};

  List<MenuItemEntity> _items = const [];
  bool _loadingItems = true;
  String? _itemsError;

  @override
  void initState() {
    super.initState();
    _addressCtl = TextEditingController();
    _notesCtl = TextEditingController();
    _phoneCtl = TextEditingController(text: widget.customer.phone ?? '');
    _loadItems();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _addressCtl.dispose();
    _notesCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loadingItems = true;
      _itemsError = null;
    });
    final result = await getIt<PublicRestaurantsRepository>().listMenuItems(
      widget.restaurantId,
      limit: 50,
    );
    if (!mounted) return;
    if (result.isSuccess && result.getSuccess != null) {
      setState(() {
        _items = result.getSuccess!.where((i) => i.active != false).toList();
        _loadingItems = false;
      });
    } else {
      setState(() {
        _itemsError = result.getError?.message;
        _loadingItems = false;
      });
    }
  }

  int get _subtotal {
    var total = 0;
    for (final entry in _qty.entries) {
      final item = _items.cast<MenuItemEntity?>().firstWhere(
        (m) => m?.id == entry.key,
        orElse: () => null,
      );
      if (item == null) continue;
      total += (item.price * entry.value).round();
    }
    return total;
  }

  /// The items the user has actually added (qty > 0), preserving menu order.
  List<({MenuItemEntity item, int quantity})> _selectedItems() {
    final out = <({MenuItemEntity item, int quantity})>[];
    for (final item in _items) {
      final id = item.id;
      if (id == null) continue;
      final qty = _qty[id] ?? 0;
      if (qty > 0) out.add((item: item, quantity: qty));
    }
    return out;
  }

  bool get _hasItems => _qty.values.any((q) => q > 0);

  void _setQty(int menuItemId, int qty) {
    setState(() {
      if (qty <= 0) {
        _qty.remove(menuItemId);
      } else {
        _qty[menuItemId] = qty;
      }
    });
  }

  bool _canAdvance() {
    switch (_currentStep) {
      case 0:
        return _hasItems;
      case 1:
        return _addressCtl.text.trim().isNotEmpty;
      case 2:
        return true;
      case 3:
        return _isPhoneValid(_phoneCtl.text);
    }
    return false;
  }

  bool _isPhoneValid(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 6;
  }

  void _goNext() {
    if (_currentStep == 1) {
      if (!(_addressFormKey.currentState?.validate() ?? false)) return;
    }
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: AppMotion.effectiveDuration(context, AppMotion.transition),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: AppMotion.effectiveDuration(context, AppMotion.transition),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _submit() {
    if (!(_phoneFormKey.currentState?.validate() ?? false)) return;
    // Address was validated when the user advanced past step 1; the step 1
    // form widget may be disposed by PageView by the time we reach here, so
    // we trust the controller value rather than re-validating across pages.
    if (_addressCtl.text.trim().isEmpty) return;
    if (!_hasItems) return;
    FocusScope.of(context).unfocus();

    final items = <CustomerOrderItemCreateParams>[];
    for (final entry in _qty.entries) {
      if (entry.value <= 0) continue;
      items.add(
        CustomerOrderItemCreateParams(
          menuItemId: entry.key,
          quantity: entry.value,
        ),
      );
    }

    context.read<OrderRequestCubit>().submitDelivery(
      restaurantId: widget.restaurantId,
      contactName: widget.customer.fullName,
      contactPhone: _phoneCtl.text.trim(),
      deliveryAddress: _addressCtl.text.trim(),
      deliveryNotes: _notesCtl.text.trim().isEmpty
          ? null
          : _notesCtl.text.trim(),
      items: items,
    );
  }

  String _stepTitle(AppLocalizations l10n) {
    return switch (_currentStep) {
      0 => l10n.orderStepItemsTitle,
      1 => l10n.orderStepAddressTitle,
      2 => l10n.orderStepNotesTitle,
      _ => l10n.orderStepPhoneTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<OrderRequestCubit, OrderRequestState>(
      listener: (context, state) {
        switch (state) {
          case OrderRequestSubmitted(:final order):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(l10n.orderSuccessToast)),
              );
            // Will pushReplacement to detail page in Step F.
            context.pushReplacement(
              RoutePaths.orderDetail(order.id),
              extra: order,
            );
          case OrderRequestError(:final message):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          default:
            break;
        }
      },
      builder: (context, state) {
        final submitting = state is OrderRequestSubmitting;
        return PopScope(
          canPop: _currentStep == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _currentStep > 0) _goBack();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowLeft),
                onPressed: _goBack,
              ),
              title: Text(_stepTitle(l10n)),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _StepIndicator(
                    currentStep: _currentStep,
                    stepCount: _stepCount,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ItemsStep(
                          loading: _loadingItems,
                          error: _itemsError,
                          items: _items,
                          quantities: _qty,
                          priceFormat: _priceFormat,
                          onRetry: _loadItems,
                          onChangeQty: _setQty,
                        ),
                        _AddressStep(
                          formKey: _addressFormKey,
                          controller: _addressCtl,
                          onChanged: (_) => setState(() {}),
                        ),
                        _NotesStep(controller: _notesCtl),
                        _PhoneStep(
                          formKey: _phoneFormKey,
                          controller: _phoneCtl,
                          isValid: _isPhoneValid,
                          selectedItems: _selectedItems(),
                          address: _addressCtl.text.trim(),
                          notes: _notesCtl.text.trim(),
                          subtotal: _subtotal,
                          priceFormat: _priceFormat,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  _Footer(
                    currentStep: _currentStep,
                    stepCount: _stepCount,
                    subtotal: _subtotal,
                    priceFormat: _priceFormat,
                    canAdvance: _canAdvance(),
                    submitting: submitting,
                    onBack: _goBack,
                    onNext: _goNext,
                    onSubmit: _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator + footer
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  const _StepIndicator({required this.currentStep, required this.stepCount});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.s,
      ),
      child: Row(
        children: [
          for (var i = 0; i < stepCount; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= currentStep
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            if (i < stepCount - 1) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final int subtotal;
  final NumberFormat priceFormat;
  final bool canAdvance;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _Footer({
    required this.currentStep,
    required this.stepCount,
    required this.subtotal,
    required this.priceFormat,
    required this.canAdvance,
    required this.submitting,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isLast = currentStep == stepCount - 1;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.08)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtotal > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.orderTotalLabel, style: textTheme.bodyMedium),
                Text(
                  l10n.menuItemPrice(priceFormat.format(subtotal)),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
          ],
          Row(
            children: [
              OutlinedButton(
                onPressed: submitting ? null : onBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                ),
                child: Text(l10n.orderBack),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: FilledButton.icon(
                  onPressed: submitting || !canAdvance
                      ? null
                      : (isLast ? onSubmit : onNext),
                  icon: Icon(
                    isLast
                        ? PhosphorIconsRegular.paperPlaneTilt
                        : PhosphorIconsRegular.arrowRight,
                  ),
                  label: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isLast ? l10n.orderPlaceOrder : l10n.orderNext),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — pick items
// ---------------------------------------------------------------------------

class _ItemsStep extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<MenuItemEntity> items;
  final Map<int, int> quantities;
  final NumberFormat priceFormat;
  final VoidCallback onRetry;
  final void Function(int menuItemId, int qty) onChangeQty;

  const _ItemsStep({
    required this.loading,
    required this.error,
    required this.items,
    required this.quantities,
    required this.priceFormat,
    required this.onRetry,
    required this.onChangeQty,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return EmptyState(
        icon: PhosphorIconsDuotone.wifiSlash,
        title: l10n.commonReachKitchenError,
        body: error!,
        actionLabel: l10n.commonTryAgain,
        onAction: onRetry,
      );
    }
    if (items.isEmpty) {
      return EmptyState(
        icon: PhosphorIconsDuotone.bowlFood,
        title: l10n.orderItemsEmptyTitle,
        body: l10n.orderItemsEmptyBody,
      );
    }

    final locale = localeLanguageOf(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final item = items[index];
        final id = item.id;
        if (id == null) return const SizedBox.shrink();
        final qty = quantities[id] ?? 0;
        return _ItemRow(
          item: item,
          locale: locale,
          quantity: qty,
          priceFormat: priceFormat,
          onChanged: (newQty) => onChangeQty(id, newQty),
        );
      },
    );
  }
}

class _ItemRow extends StatelessWidget {
  final MenuItemEntity item;
  final String locale;
  final int quantity;
  final NumberFormat priceFormat;
  final ValueChanged<int> onChanged;

  const _ItemRow({
    required this.item,
    required this.locale,
    required this.quantity,
    required this.priceFormat,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final translation = pickTranslation(item.translations, locale);
    final name = (translation?.name.trim().isNotEmpty ?? false)
        ? translation!.name
        : l10n.menuItemUntitled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              width: 64,
              height: 64,
              child: (item.picture != null && item.picture!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: item.picture!,
                      fit: BoxFit.cover,
                      cacheManager: PersistentImageCacheManager.instance,
                      placeholder: (_, __) =>
                          Container(color: AppColors.canvas),
                      errorWidget: (_, __, ___) => _Placeholder(scheme: scheme),
                    )
                  : _Placeholder(scheme: scheme),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.menuItemPrice(priceFormat.format(item.price.round())),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          _QtyStepper(
            quantity: quantity,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final ColorScheme scheme;
  const _Placeholder({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.tertiary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(PhosphorIconsRegular.bowlFood, color: scheme.tertiary),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QtyStepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    if (quantity == 0) {
      return OutlinedButton.icon(
        onPressed: () => onChanged(1),
        icon: const Icon(PhosphorIconsRegular.plus, size: 16),
        label: Text(l10n.orderItemAdd),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(quantity - 1),
            icon: Icon(PhosphorIconsRegular.minus, color: scheme.primary),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 22),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(quantity + 1),
            icon: Icon(PhosphorIconsRegular.plus, color: scheme.primary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — delivery address
// ---------------------------------------------------------------------------

class _AddressStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AddressStep({
    required this.formKey,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.orderStepAddressHeadline,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.orderStepAddressBody,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            TextFormField(
              controller: controller,
              onChanged: onChanged,
              maxLines: 3,
              minLines: 2,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: l10n.orderAddressLabel,
                hintText: l10n.orderAddressHint,
                prefixIcon: const Icon(PhosphorIconsRegular.mapPin),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) {
                  return l10n.orderAddressRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — delivery notes (optional)
// ---------------------------------------------------------------------------

class _NotesStep extends StatelessWidget {
  final TextEditingController controller;
  const _NotesStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.orderStepNotesHeadline,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.orderStepNotesBody,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          TextFormField(
            controller: controller,
            maxLines: 4,
            minLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: l10n.orderNotesLabel,
              hintText: l10n.orderNotesHint,
              prefixIcon: const Icon(PhosphorIconsRegular.note),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4 — confirm phone (with order summary)
// ---------------------------------------------------------------------------

class _PhoneStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool Function(String) isValid;
  final List<({MenuItemEntity item, int quantity})> selectedItems;
  final String address;
  final String notes;
  final int subtotal;
  final NumberFormat priceFormat;
  final ValueChanged<String> onChanged;

  const _PhoneStep({
    required this.formKey,
    required this.controller,
    required this.isValid,
    required this.selectedItems,
    required this.address,
    required this.notes,
    required this.subtotal,
    required this.priceFormat,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.orderStepPhoneHeadline,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.orderStepPhoneBody,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 \-\(\)\+]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.orderPhoneLabel,
                hintText: l10n.orderPhoneHint,
                prefixIcon: const Icon(PhosphorIconsRegular.phone),
              ),
              validator: (v) {
                final trimmed = (v ?? '').trim();
                if (trimmed.isEmpty) return l10n.orderPhoneRequired;
                if (!isValid(trimmed)) return l10n.orderPhoneInvalid;
                return null;
              },
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _SummaryCard(
            selectedItems: selectedItems,
            address: address,
            notes: notes,
            subtotal: subtotal,
            priceFormat: priceFormat,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<({MenuItemEntity item, int quantity})> selectedItems;
  final String address;
  final String notes;
  final int subtotal;
  final NumberFormat priceFormat;

  const _SummaryCard({
    required this.selectedItems,
    required this.address,
    required this.notes,
    required this.subtotal,
    required this.priceFormat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = localeLanguageOf(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderSummaryTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s),
          for (var i = 0; i < selectedItems.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.xs),
            _SummaryItemRow(
              item: selectedItems[i].item,
              quantity: selectedItems[i].quantity,
              locale: locale,
              priceFormat: priceFormat,
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          _SummaryRow(
            icon: PhosphorIconsRegular.mapPin,
            label: address.isEmpty ? '—' : address,
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _SummaryRow(
              icon: PhosphorIconsRegular.note,
              label: notes,
            ),
          ],
          const Divider(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.orderTotalLabel, style: textTheme.bodyMedium),
              Text(
                l10n.menuItemPrice(priceFormat.format(subtotal)),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItemRow extends StatelessWidget {
  final MenuItemEntity item;
  final int quantity;
  final String locale;
  final NumberFormat priceFormat;

  const _SummaryItemRow({
    required this.item,
    required this.quantity,
    required this.locale,
    required this.priceFormat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final translation = pickTranslation(item.translations, locale);
    final name = (translation?.name.trim().isNotEmpty ?? false)
        ? translation!.name
        : l10n.menuItemUntitled;
    final lineTotal = (item.price * quantity).round();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '× $quantity',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            name,
            style: textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(
          l10n.menuItemPrice(priceFormat.format(lineTotal)),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: scheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: AppSpacing.s),
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
      ],
    );
  }
}
