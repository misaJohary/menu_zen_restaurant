import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/constants/constants.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_entity.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_menu_item.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/auths/auth_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

enum PaymentMethod { orangeMoney, mvola, cash, visa }

class PaymentSummaryDialog extends StatefulWidget {
  final OrderEntity order;

  const PaymentSummaryDialog({super.key, required this.order});

  @override
  State<PaymentSummaryDialog> createState() => _PaymentSummaryDialogState();
}

class _PaymentSummaryDialogState extends State<PaymentSummaryDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double _calculateChange() {
    final given = double.tryParse(_amountController.text) ?? 0.0;
    return given - widget.order.totalAmount;
  }

  Future<void> _generateAndPrintPDF() async {
    final authState = context.read<AuthBloc>().state;
    final restaurantName =
        authState.userRestaurant?.restaurant.name ?? 'Menu Zen';

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  restaurantName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Commande #${widget.order.id}'),
              pw.Text(
                'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              ),
              pw.Text('Paiement: ${_selectedMethod.name}'),
              pw.Divider(),
              ...widget.order.orderMenuItems.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${item.quantity}x ${item.menuItem.translations.isNotEmpty ? item.menuItem.translations.first.name : 'Article'}',
                    ),
                    pw.Text(
                      '${(item.unitPrice * item.quantity).toStringAsFixed(0)} Ar',
                    ),
                  ],
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '${widget.order.totalAmount.toStringAsFixed(0)} Ar',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              if (_selectedMethod == PaymentMethod.cash) ...[
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Reçu'),
                    pw.Text(
                      '${(double.tryParse(_amountController.text) ?? 0).toStringAsFixed(0)} Ar',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Rendu'),
                    pw.Text('${_calculateChange().toStringAsFixed(0)} Ar'),
                  ],
                ),
              ],
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Merci pour votre visite !')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

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
                  // Left: Order Summary (without Total)
                  Expanded(flex: 4, child: _buildOrderSummary(context, isDark)),

                  // Divider
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),

                  // Right: Payment Methods and Total Section
                  Expanded(flex: 6, child: _buildRightSide(context, isDark)),
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

  Widget _buildRightSide(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildPaymentMethods(context, isDark)),
        if (_selectedMethod == PaymentMethod.cash)
          Padding(
            padding: const EdgeInsets.only(bottom: kspacing * 3),
            child: _buildCashCalculator(isDark),
          ),
      ],
    );
  }

  Widget _buildCashCalculator(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kspacing * 4),
      padding: const EdgeInsets.all(kspacing * 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_rounded, color: Colors.green, size: 24),
              const SizedBox(width: kspacing * 2),
              Text(
                'Calculateur de change',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: kspacing * 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Montant reçu',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    suffixText: 'Ar',
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: kspacing * 2),
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: kspacing * 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _calculateChange() >= 0
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.red.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rendu',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_calculateChange().toStringAsFixed(0)} Ar',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: _calculateChange() >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(kspacing * 3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  'Visa/MC',
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
    final Color effectiveIconColor =
        iconColor ??
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
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.black.withValues(alpha: 0.02),
      padding: const EdgeInsets.all(kspacing * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé de la commande',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(kspacing * 2.5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sous-total',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.order.totalAmount.toStringAsFixed(0)} Ar',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: kspacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxe (0%)',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text('0 Ar', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: kspacing * 1.5),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kspacing * 2,
                  vertical: kspacing,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.order.totalAmount.toStringAsFixed(0)} Ar',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
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
          top: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: kspacing * 4,
                vertical: kspacing * 2,
              ),
            ),
            child: const Text('Annuler'),
          ),
          const SizedBox(width: kspacing * 2),
          OutlinedButton.icon(
            onPressed: () async {
              final nav = Navigator.of(context);
              await _generateAndPrintPDF();
              if (mounted) {
                nav.pop({'action': 'print_and_pay', 'method': _selectedMethod});
              }
            },
            icon: const Icon(Icons.print_rounded),
            label: const Text('Imprimer et Payer'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: kspacing * 4,
                vertical: kspacing * 2,
              ),
              side: BorderSide(color: primaryColor),
              foregroundColor: primaryColor,
            ),
          ),
          const SizedBox(width: kspacing * 2),
          ElevatedButton(
            onPressed: () async {
              // Now "Payer" also generates PDF per requirements
              final nav = Navigator.of(context);
              await _generateAndPrintPDF();
              if (mounted) {
                nav.pop({'action': 'pay', 'method': _selectedMethod});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: kspacing * 6,
                vertical: kspacing * 2,
              ),
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
