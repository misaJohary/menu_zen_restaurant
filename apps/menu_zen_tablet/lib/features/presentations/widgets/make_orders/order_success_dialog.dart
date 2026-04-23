import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:menu_zen_restaurant/core/constants/constants.dart';
import 'package:menu_zen_restaurant/core/extensions/double_extension.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:domain/entities/order_entity.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/languages/languages_bloc.dart';

class OrderSuccessDialog extends StatelessWidget {
  const OrderSuccessDialog({
    super.key,
    required this.order,
    this.onEdit,
    this.onDelete,
    required this.onAnotherOrder,
    required this.onViewList,
  });

  final OrderEntity order;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onAnotherOrder;
  final VoidCallback onViewList;

  String _getStatusText(OrderStatus status) {
    return switch (status) {
      OrderStatus.created => 'Créée',
      OrderStatus.inPreparation => 'En cours',
      OrderStatus.ready => 'Prête',
      OrderStatus.served => 'Servie',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E6B1D),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.rTable?.name ?? '??',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.clientName ?? 'Client',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        order.createdAt != null
                            ? DateFormat('HH:mm').format(order.createdAt!)
                            : DateFormat('HH:mm').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: primaryColor),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
            const SizedBox(height: 20),

            // Table Header
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Détails',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Qte',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Prix (Ar)',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Items List
            Flexible(
              child: SingleChildScrollView(
                child: BlocBuilder<LanguagesBloc, LanguagesState>(
                  builder: (context, langState) {
                    final selectedLang =
                        langState.selectedLanguage?.code ?? 'en';
                    return Column(
                      children: order.orderMenuItems.map((item) {
                        final itemName = item.menuItem.translations.getField(
                          selectedLang,
                          (t) => t.name,
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  itemName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    item.quantity.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    (item.menuItem.price * item.quantity)
                                        .formatMoney,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
            const SizedBox(height: 16),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  order.totalAmount.formatMoney,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statut',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9ECEF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.orderStatus),
                    style: const TextStyle(
                      color: Color(0xFF6C757D),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onAnotherOrder,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F7E8),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Text(
                      'AUTRE COMMANDE',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: onViewList,
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text(
                      'VOIR LISTES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
