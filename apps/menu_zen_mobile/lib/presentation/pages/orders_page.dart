import 'dart:async';

import 'package:domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/enums/bloc_status.dart';
import '../bloc/orders/orders_bloc.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _showDone = false;
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const OrderFetched());
    _searchController.addListener(
      () => setState(() => _search = _searchController.text.trim()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderEntity> _filtered(List<OrderEntity> orders) {
    final active = orders.where((o) {
      if (_showDone) return o.orderStatus == OrderStatus.served;
      return o.orderStatus != OrderStatus.served;
    }).toList();

    if (_search.isEmpty) return active;
    final q = _search.toLowerCase();
    return active.where((o) {
      final table = o.rTable?.name ?? 'Table ${o.restaurantTableId}';
      return table.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mes commandes',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchController),
          _TabToggle(
            showDone: _showDone,
            onChanged: (v) => setState(() => _showDone = v),
            orders: context.watch<OrdersBloc>().state.orders,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                if (state.status == BlocStatus.loading &&
                    state.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = _filtered(state.orders);
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      _showDone
                          ? 'Aucune commande terminée'
                          : 'Aucune commande en cours',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      context.read<OrdersBloc>().add(const OrderFetched()),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) =>
                        _OrderCard(order: list[i], showDone: _showDone),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Rechercher une table...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ─── Tab Toggle ──────────────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final bool showDone;
  final ValueChanged<bool> onChanged;
  final List<OrderEntity> orders;

  const _TabToggle({
    required this.showDone,
    required this.onChanged,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final inProgressCount = orders
        .where((o) => o.orderStatus != OrderStatus.served)
        .length;
    final doneCount = orders
        .where((o) => o.orderStatus == OrderStatus.served)
        .length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _ToggleBtn(
            label: 'EN COURS',
            count: inProgressCount,
            selected: !showDone,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 8),
          _ToggleBtn(
            label: 'TERMINÉ',
            count: doneCount,
            selected: showDone,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

String _relativeTime(DateTime? createdAt) {
  if (createdAt == null) return '--';
  final diff = DateTime.now().difference(createdAt);
  if (diff.inSeconds < 60) return 'À l\'instant';
  if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
  return 'Il y a ${diff.inDays} j';
}

class _OrderCard extends StatefulWidget {
  final OrderEntity order;
  final bool showDone;

  const _OrderCard({required this.order, required this.showDone});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final totalItems = order.orderMenuItems.fold<int>(
      0,
      (sum, i) => sum + i.quantity,
    );
    final readyItems = order.orderMenuItems
        .where((i) => i.status == 'ready')
        .fold<int>(0, (sum, i) => sum + i.quantity);

    final allReady = totalItems > 0 && readyItems >= totalItems;
    final tableName = order.rTable?.name ?? 'Table ${order.restaurantTableId}';
    final time = _relativeTime(order.createdAt);

    return GestureDetector(
      onTap: () => context.push('/order-detail/${order.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: time + ready badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (totalItems > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: allReady
                            ? primaryColor.withValues(alpha: 0.12)
                            : Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$readyItems/$totalItems prêts',
                        style: TextStyle(
                          color: allReady
                              ? primaryColor
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Table name
              Text(
                tableName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  // Eye icon
                  _IconBtn(
                    icon: Icons.visibility_outlined,
                    onTap: () => context.push('/order-detail/${order.id}'),
                  ),
                  const SizedBox(width: 8),

                  // Pencil icon (only for in-progress)
                  if (!widget.showDone) ...[
                    _IconBtn(
                      icon: Icons.edit_outlined,
                      onTap: () =>
                          context.push('/make-order-edit', extra: order),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // TERMINER button (only for in-progress)
                  if (!widget.showDone)
                    Expanded(
                      child: BlocBuilder<OrdersBloc, OrdersState>(
                        builder: (context, state) {
                          final isLoading =
                              state.updateStatus == BlocStatus.loading;
                          return SizedBox(
                            height: 38,
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'TERMINER',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade600),
      ),
    );
  }
}
