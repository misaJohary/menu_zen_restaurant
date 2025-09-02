import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_zen_restaurant/core/extensions/color_extension.dart';
import 'package:menu_zen_restaurant/core/extensions/double_extension.dart';

import '../../../../core/constants/constants.dart';
import '../../../domains/entities/order_entity.dart';
import '../edit_delete_icon.dart';

class OrderItem extends StatelessWidget {
  const OrderItem({
    super.key,
    required this.order,
    required this.onStatusChanged,
    this.onEdit,
    this.onDelete,
  });

  final OrderEntity order;

  final ValueSetter<OrderStatus> onStatusChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kspacing),
      borderSide: BorderSide(width: .1),
    );
    return Container(
      width: 400,
      padding: EdgeInsets.all(kspacing * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kspacing),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Table X', style: Theme.of(context).textTheme.titleLarge),
              EditDeleteIcon(
                onDelete: onDelete ?? () {},
                onEdit: onEdit ?? () {},
                iconSize: 20,
              ),
            ],
          ),
          SizedBox(height: kspacing),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(kspacing),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: kspacing * 1.8,
                    ),
                    titleTextStyle: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 20),
                    title: Text(order.clientName ?? 'Client X'),
                    subtitleTextStyle: Theme.of(context).textTheme.bodyLarge,
                    subtitle: order.createdAt != null
                        ? Text(DateFormat('HH:MM').format(order.createdAt!))
                        : null,
                    trailing: SizedBox(
                      width: 150,
                      height: 80,
                      child: DropdownButtonFormField<OrderStatus>(
                        decoration: InputDecoration(
                          border: inputBorder,
                          enabledBorder: inputBorder,
                          focusedBorder: inputBorder,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: kspacing,
                          ),
                        ),
                        value: order.orderStatus,
                        items: [
                          ...OrderStatus.values.map(
                            (orderStatus) => DropdownMenuItem(
                              value: orderStatus,
                              child: Text(orderStatus.name),
                            ),
                          ),
                        ],

                        onChanged: (value) {
                          onStatusChanged(value!);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: order.orderMenuItems.length,
                      itemBuilder: (context, index) {
                        final orderMenuItem = order.orderMenuItems[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: kspacing * 2,
                            vertical: kspacing / 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${orderMenuItem.menuItem.name} x${orderMenuItem.quantity}',
                              ),
                              Text(
                                (orderMenuItem.menuItem.price *
                                        orderMenuItem.quantity)
                                    .formatMoney,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('${order.orderMenuItems.length} items'),
                    trailing: Text(
                      '${order.orderMenuItems.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice)).formatMoney} Ar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor.darken(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
