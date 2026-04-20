import 'package:domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/constants.dart';
import '../../core/enums/bloc_status.dart';
import '../bloc/orders/orders_bloc.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;
  const OrderDetailPage({required this.orderId, super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    // Fetch orders if the bloc is empty — happens on cold-start deep-link
    // when OrdersPage has never been visited.
    final bloc = context.read<OrdersBloc>();
    if (bloc.state.orders.isEmpty &&
        bloc.state.status != BlocStatus.loading) {
      bloc.add(const OrderFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state.status == BlocStatus.loading && state.orders.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Commande')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final order = state.orders.cast<OrderEntity?>().firstWhere(
              (o) => o?.id == widget.orderId,
              orElse: () => null,
            );

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Commande')),
            body: const Center(child: Text('Commande introuvable')),
          );
        }

        return _OrderDetailView(order: order);
      },
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final OrderEntity order;
  const _OrderDetailView({required this.order});

  @override
  Widget build(BuildContext context) {
    final tableName =
        order.rTable?.name ?? 'Table ${order.restaurantTableId}';
    final time = order.createdAt != null
        ? '${order.createdAt!.hour.toString().padLeft(2, '0')}:'
            '${order.createdAt!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tableName,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: order.orderMenuItems.length,
              itemBuilder: (context, i) {
                final item = order.orderMenuItems[i];
                final name = item.menuItem.translations.isNotEmpty
                    ? item.menuItem.translations.first.name
                    : 'Article';
                final isReady = item.status == 'ready';
                final isOffered = item.unitPrice == 0.0;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: GestureDetector(
                      onTap: () {
                        if (item.id != null && order.id != null) {
                          context.read<OrdersBloc>().add(
                                OrderMenuItemStatusUpdated(
                                  order.id!,
                                  item.id!,
                                  isReady ? 'init' : 'ready',
                                ),
                              );
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isReady ? primaryColor : Colors.white,
                          border: Border.all(
                            color: isReady
                                ? primaryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isReady
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                    title: Text(
                      '$name × ${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isReady
                            ? Colors.grey.shade400
                            : Colors.black87,
                        decoration: isReady
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: item.notes != null && item.notes!.isNotEmpty
                        ? Text(
                            item.notes!,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    trailing: Text(
                      isOffered
                          ? 'offert'
                          : formatPriceFull(
                              item.unitPrice * item.quantity,
                            ),
                      style: TextStyle(
                        color: isOffered
                            ? Colors.green.shade600
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Summary + action
          _DetailSummary(order: order),
        ],
      ),
    );
  }
}

class _DetailSummary extends StatelessWidget {
  final OrderEntity order;
  const _DetailSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDone = order.orderStatus == OrderStatus.served;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                formatPriceFull(order.totalAmount.toDouble()),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (!isDone) ...[
            const SizedBox(height: 16),
            BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                final isLoading = state.updateStatus == BlocStatus.loading;
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<OrdersBloc>().add(
                              OrderStatusUpdated(
                                order.id!,
                                OrderStatus.served,
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'TERMINER LA COMMANDE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
