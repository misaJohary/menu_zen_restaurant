import 'package:design_system/design_system.dart';
import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/entities/customer_order_item_entity.dart';
import 'package:domain/entities/customer_order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/order_detail/order_detail_cubit.dart';
import 'widgets/order_status_chip.dart';

class OrderDetailPage extends StatelessWidget {
  final int orderId;
  final CustomerOrderEntity? initial;

  const OrderDetailPage({super.key, required this.orderId, this.initial});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<OrderDetailCubit>();
        if (initial != null) {
          cubit.seed(initial!);
        } else {
          cubit.load(orderId);
        }
        return cubit;
      },
      child: _OrderDetailView(orderId: orderId),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final int orderId;
  const _OrderDetailView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetailTitle)),
      body: SafeArea(
        child: BlocConsumer<OrderDetailCubit, OrderDetailState>(
          listenWhen: (prev, curr) =>
              curr is OrderDetailLoaded &&
              curr.lastErrorMessage != null &&
              (prev is! OrderDetailLoaded ||
                  prev.lastErrorMessage != curr.lastErrorMessage),
          listener: (context, state) {
            final message = (state as OrderDetailLoaded).lastErrorMessage;
            if (message != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) => switch (state) {
            OrderDetailInitial() ||
            OrderDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            OrderDetailError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<OrderDetailCubit>().load(orderId),
            ),
            OrderDetailCancelling(:final order) => _DetailBody(
              order: order,
              cancelling: true,
            ),
            OrderDetailLoaded(:final order) => _DetailBody(
              order: order,
              cancelling: false,
            ),
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final CustomerOrderEntity order;
  final bool cancelling;
  const _DetailBody({required this.order, required this.cancelling});

  static final _priceFormat = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final createdAtLabel = DateFormat.yMMMMEEEEd(localeTag).add_jm();
    final canCancel = order.orderStatus.canCancel;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.orderCardId(order.id),
                style: textTheme.headlineSmall,
              ),
            ),
            OrderStatusChip(status: order.orderStatus),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          createdAtLabel.format(order.createdAt.toLocal()),
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if ((order.deliveryAddress ?? '').isNotEmpty)
          _DetailRow(
            icon: PhosphorIconsRegular.mapPin,
            label: l10n.orderAddressLabel,
            value: order.deliveryAddress!,
          ),
        if ((order.deliveryNotes ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          _DetailRow(
            icon: PhosphorIconsRegular.note,
            label: l10n.orderNotesLabel,
            value: order.deliveryNotes!,
          ),
        ],
        if ((order.contactPhone ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          _DetailRow(
            icon: PhosphorIconsRegular.phone,
            label: l10n.orderPhoneLabel,
            value: order.contactPhone!,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.orderSummaryTitle,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.s),
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            children: [
              for (var i = 0; i < order.items.length; i++) ...[
                if (i > 0) const Divider(height: AppSpacing.m),
                _OrderItemRow(
                  item: order.items[i],
                  priceFormat: _priceFormat,
                ),
              ],
              const Divider(height: AppSpacing.l),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.orderTotalLabel, style: textTheme.titleSmall),
                  Text(
                    l10n.menuItemPrice(_priceFormat.format(order.totalAmount)),
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (order.orderStatus == CustomerOrderStatus.cancelled) ...[
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PhosphorIconsRegular.xCircle,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    l10n.orderStatusCancelled,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (canCancel) ...[
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: cancelling ? null : () => _confirmCancel(context),
            icon: const Icon(PhosphorIconsRegular.xCircle),
            label: cancelling
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.orderCancel),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OrderDetailCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.orderCancelDialogTitle),
        content: Text(l10n.orderCancelDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonKeep),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.orderCancel),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.cancel();
    }
  }
}

class _OrderItemRow extends StatelessWidget {
  final CustomerOrderItemEntity item;
  final NumberFormat priceFormat;
  const _OrderItemRow({required this.item, required this.priceFormat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lineTotal = item.unitPrice * item.quantity;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '× ${item.quantity}',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.menuItemPrice(priceFormat.format(item.unitPrice)),
                style: textTheme.bodyMedium,
              ),
              if ((item.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item.notes!,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: scheme.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: PhosphorIconsDuotone.wifiSlash,
      title: l10n.commonReachKitchenError,
      body: message,
      actionLabel: l10n.commonTryAgain,
      onAction: onRetry,
    );
  }
}
