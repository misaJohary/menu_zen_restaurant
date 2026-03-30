import 'package:flutter/material.dart';
import 'package:menu_zen_restaurant/core/constants/constants.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_entity.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_menu_item.dart';

enum PaymentMethod {
  orangeMoney,
  mvola,
  cash,
  visa,
}

class PaymentSummaryDialog extends StatefulWidget {
  final OrderEntity order;

  const PaymentSummaryDialog({
    super.key,
    required this.order,
  });

  @override
  State<PaymentSummaryDialog> createState() => _PaymentSummaryDialogState();
}

class _PaymentSummaryDialogState extends State<PaymentSummaryDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 1000,
        height: 700,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: Payment Methods
                  Expanded(
                    flex: 6,
                    child: _buildPaymentMethods(context, isDark),
                  ),

                  // Divider
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),

                  // Right: Order Summary
                  Expanded(
                    flex: 4,
                    child: _buildOrderSummary(context, isDark),
                  ),
                ],
              ),
            ),

            // Footer
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(kspacing * 3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(kspacing),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.payment_rounded, color: primaryColor),
              ),
              const SizedBox(width: kspacing * 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paiement',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Commande #${widget.order.id}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(kspacing * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode de paiement',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: kspacing * 4),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: kspacing * 3,
              crossAxisSpacing: kspacing * 3,
              childAspectRatio: 1.5,
              children: [
                _buildMethodCard(
                  PaymentMethod.orangeMoney,
                  'Orange Money',
                  const Color(0xFFFF6600),
                  icon: Icons.smartphone_rounded,
                ),
                _buildMethodCard(
                  PaymentMethod.mvola,
                  'Mvola',
                  const Color(0xFFFEDD00),
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: Colors.black,
                ),
                _buildMethodCard(
                  PaymentMethod.cash,
                  'Espèces',
                  Colors.green,
                  icon: Icons.money_rounded,
                ),
                _buildMethodCard(
                  PaymentMethod.visa,
                  'Visa / MasterCard',
                  Colors.blue.shade900,
                  icon: Icons.credit_card_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(
    PaymentMethod method,
    String label,
    Color color, {
    required IconData icon,
    Color? iconColor,
  }) {
    final bool isSelected = _selectedMethod == method;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveIconColor = iconColor ??
        (isSelected ? color : (isDark ? Colors.white70 : Colors.black87));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? Colors.white10 : Colors.black12),
              width: 3,
            ),
            color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          ),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 48, color: effectiveIconColor),
                    const SizedBox(height: kspacing * 2),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : null,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, bool isDark) {
    return Container(
      color: isDark
          ? Colors.white.withOpacity(0.02)
          : Colors.black.withOpacity(0.02),
      padding: const EdgeInsets.all(kspacing * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé de la commande',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: kspacing * 4),
          Expanded(
            child: ListView.separated(
              itemCount: widget.order.orderMenuItems.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = widget.order.orderMenuItems[index];
                return _buildSummaryItem(item, isDark);
              },
            ),
          ),
          const SizedBox(height: kspacing * 2),
          _buildTotalSection(isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(OrderMenuItem item, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black12,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${item.quantity}x',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: kspacing * 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.menuItem.translations.isNotEmpty
                    ? item.menuItem.translations.first.name
                    : 'Article',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (item.notes != null && item.notes!.isNotEmpty)
                Text(
                  item.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        Text(
          '${(item.unitPrice * item.quantity).toStringAsFixed(0)} Ar',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTotalSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(kspacing * 3),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sous-total'),
              Text('${widget.order.totalAmount.toStringAsFixed(0)} Ar'),
            ],
          ),
          const SizedBox(height: kspacing),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taxe (0%)'),
              Text('0 Ar'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: kspacing * 2),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
              ),
              Text(
                '${widget.order.totalAmount.toStringAsFixed(0)} Ar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(kspacing * 3),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: kspacing * 4, vertical: kspacing * 2),
            ),
            child: const Text('Annuler'),
          ),
          const SizedBox(width: kspacing * 2),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context)
                .pop({'action': 'print_and_pay', 'method': _selectedMethod}),
            icon: const Icon(Icons.print_rounded),
            label: const Text('Imprimer et Payer'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: kspacing * 4, vertical: kspacing * 2),
              side: BorderSide(color: primaryColor),
              foregroundColor: primaryColor,
            ),
          ),
          const SizedBox(width: kspacing * 2),
          ElevatedButton(
            onPressed: () => Navigator.of(context)
                .pop({'action': 'pay', 'method': _selectedMethod}),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: kspacing * 6, vertical: kspacing * 2),
              elevation: 0,
            ),
            child: const Text(
              'Payer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
