import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DetailBottomBar extends StatelessWidget {
  final VoidCallback onReserve;
  final VoidCallback onOrder;

  const DetailBottomBar({
    super.key,
    required this.onReserve,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: AppColors.hairline, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReserve,
                icon: const Icon(PhosphorIconsRegular.calendarPlus),
                label: const Text('Reserve'),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: FilledButton.icon(
                onPressed: onOrder,
                icon: const Icon(PhosphorIconsRegular.shoppingBag),
                label: const Text('Order delivery'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
