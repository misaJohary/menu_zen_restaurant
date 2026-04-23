import 'package:domain/entities/order_entity.dart';
import 'package:domain/entities/order_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/enums/bloc_status.dart';
import '../bloc/orders/order_menu_item/order_menu_item_bloc.dart';
import '../bloc/orders/orders_bloc.dart';
import '../bloc/tables/table_bloc.dart';
import '../widgets/menu_item_options_sheet.dart';

class OrderCardPage extends StatefulWidget {
  /// When non-null the page is in edit-mode for an existing order.
  final OrderEntity? order;

  const OrderCardPage({super.key, this.order});

  @override
  State<OrderCardPage> createState() => _OrderCardPageState();
}

class _OrderCardPageState extends State<OrderCardPage> {
  int? _selectedTableId;

  @override
  void initState() {
    super.initState();
    if (context.read<TableBloc>().state.tables.isEmpty) {
      context.read<TableBloc>().add(const TableFetched());
    }
    // Pre-select table if editing an existing order
    if (widget.order != null) {
      _selectedTableId = widget.order!.restaurantTableId;
    }
  }

  void _confirm(List<OrderMenuItem> ordered) {
    if (_selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une table')),
      );
      return;
    }
    if (ordered.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le panier est vide')));
      return;
    }

    final total = ordered.fold<double>(
      0,
      (sum, i) => sum + i.unitPrice * i.quantity,
    );

    if (widget.order != null) {
      // Update existing order
      context.read<OrdersBloc>().add(
        OrderUpdated(
          widget.order!.copyWith(
            orderMenuItems: ordered,
            restaurantTableId: _selectedTableId!,
            totalAmount: total.toInt(),
          ),
        ),
      );
    } else {
      // Create new order
      context.read<OrdersBloc>().add(
        OrderCreated(
          OrderEntity(
            orderStatus: OrderStatus.created,
            paymentStatus: PaymentStatus.unpaid,
            orderMenuItems: ordered,
            restaurantTableId: _selectedTableId!,
            totalAmount: total.toInt(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.order != null;

    return MultiBlocListener(
      listeners: [
        BlocListener<OrdersBloc, OrdersState>(
          listenWhen: (prev, curr) => prev.createStatus != curr.createStatus,
          listener: (context, state) {
            if (state.createStatus == BlocStatus.loaded) {
              context.read<OrderMenuItemBloc>().add(
                const OrderMenuItemCleared(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Commande envoyée !')),
              );
              context.go('/main/commandes');
            } else if (state.createStatus == BlocStatus.failed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Erreur lors de l\'envoi')),
              );
            }
          },
        ),
        BlocListener<OrdersBloc, OrdersState>(
          listenWhen: (prev, curr) => prev.updateStatus != curr.updateStatus,
          listener: (context, state) {
            if (state.updateStatus == BlocStatus.loaded && isEditMode) {
              context.read<OrderMenuItemBloc>().add(
                const OrderMenuItemCleared(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Commande mise à jour !')),
              );
              context.pop();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
            builder: (context, menuState) {
              final count = menuState.orderedItems.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Articles commandés',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '$count plat${count > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        body: BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
          builder: (context, menuState) {
            final ordered = menuState.orderedItems;

            if (ordered.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Panier vide',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final subtotal = ordered.fold<double>(
              0,
              (s, i) => s + i.unitPrice * i.quantity,
            );

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Item cards ────────────────────────────────
                        ...ordered.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _OrderItemCard(
                            item: item,
                            orderedIndex: index,
                            onRemove: () {
                              context.read<OrderMenuItemBloc>().add(
                                OrderMenuItemRemoved(item),
                              );
                            },
                            onLongPress: () {
                              showMenuItemOptionsSheet(context, item, index);
                            },
                          );
                        }),

                        const SizedBox(height: 20),

                        // ── Summary ───────────────────────────────────
                        _SummarySection(subtotal: subtotal),

                        const SizedBox(height: 20),

                        // ── Table selector ────────────────────────────
                        _TableSelector(
                          selectedTableId: _selectedTableId,
                          onSelect: (id) =>
                              setState(() => _selectedTableId = id),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── Action buttons ────────────────────────────────────
                _ActionButtons(
                  isEditMode: isEditMode,
                  isLoading:
                      context.watch<OrdersBloc>().state.createStatus ==
                          BlocStatus.loading ||
                      context.watch<OrdersBloc>().state.updateStatus ==
                          BlocStatus.loading,
                  onVider: () {
                    context.read<OrderMenuItemBloc>().add(
                      const OrderMenuItemCleared(),
                    );
                  },
                  onConfirm: () => _confirm(ordered),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Item card ────────────────────────────────────────────────────────────────

class _OrderItemCard extends StatelessWidget {
  final OrderMenuItem item;
  final int orderedIndex;
  final VoidCallback onRemove;
  final VoidCallback onLongPress;

  const _OrderItemCard({
    required this.item,
    required this.orderedIndex,
    required this.onRemove,
    required this.onLongPress,
  });

  bool get isOffered => item.unitPrice == 0;

  String get name => item.menuItem.translations.isNotEmpty
      ? item.menuItem.translations.first.name
      : 'Article';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + price row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${item.quantity} $name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isOffered
                    ? const Text(
                        'offerts',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                        ),
                      )
                    : Text(
                        formatPriceFull(item.unitPrice * item.quantity),
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ],
            ),

            // Notes badge
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.notes!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],

            const Divider(height: 16),

            // Controls row
            Row(
              children: [
                // Trash
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),

                // Decrement
                _QtyButton(
                  icon: Icons.remove,
                  onTap: () {
                    final state = context.read<OrderMenuItemBloc>().state;
                    final idx = state.orderMenuItems.indexWhere(
                      (i) =>
                          i.menuItem.id == item.menuItem.id &&
                          i.unitPrice == item.unitPrice,
                    );
                    if (idx >= 0) {
                      context.read<OrderMenuItemBloc>().add(
                        OrderMenuItemDecremented(idx),
                      );
                    } else {
                      context.read<OrderMenuItemBloc>().add(
                        OrderMenuItemOrderedDecremented(orderedIndex),
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),

                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),

                // Increment
                _QtyButton(
                  icon: Icons.add,
                  filled: true,
                  onTap: () {
                    final state = context.read<OrderMenuItemBloc>().state;
                    final idx = state.orderMenuItems.indexWhere(
                      (i) =>
                          i.menuItem.id == item.menuItem.id &&
                          i.unitPrice == item.unitPrice,
                    );
                    if (idx >= 0) {
                      context.read<OrderMenuItemBloc>().add(
                        OrderMenuItemIncremented(idx),
                      );
                    } else {
                      context.read<OrderMenuItemBloc>().add(
                        OrderMenuItemOrderedIncremented(orderedIndex),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

// ─── Summary section ──────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  final double subtotal;

  const _SummarySection({required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //_SummaryRow(label: 'SOUS-TOTAL', value: formatPriceFull(subtotal)),
        // const SizedBox(height: 8),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        //   decoration: BoxDecoration(
        //     color: Colors.grey.shade100,
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Row(
        //     children: [
        //       const Text(
        //         'TVA (20%)',
        //         style: TextStyle(color: Colors.black45, fontSize: 14),
        //       ),
        //       const SizedBox(width: 6),
        //       const Icon(Icons.edit, size: 14, color: Colors.black38),
        //       const Spacer(),
        //       Text(
        //         '—',
        //         style: TextStyle(color: Colors.black38, fontSize: 14),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              Text(
                formatPriceFull(subtotal),
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Table selector ───────────────────────────────────────────────────────────

class _TableSelector extends StatelessWidget {
  final int? selectedTableId;
  final ValueChanged<int> onSelect;

  const _TableSelector({required this.selectedTableId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableBloc, TableState>(
      builder: (context, state) {
        final tables = state.tables;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'SÉLECTEUR DE TABLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                if (selectedTableId != null)
                  Text(
                    'Table ${tables.where((t) => t.id == selectedTableId).firstOrNull?.name ?? ''} active',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tables.map((table) {
                  final isSelected = table.id == selectedTableId;
                  return GestureDetector(
                    onTap: () => onSelect(table.id!),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        table.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Action buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onVider;
  final VoidCallback onConfirm;

  const _ActionButtons({
    required this.isEditMode,
    required this.isLoading,
    required this.onVider,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onVider,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(0, 50),
              ),
              child: const Text(
                'VIDER',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onConfirm,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, size: 20),
              label: Text(
                isEditMode ? 'METTRE À JOUR' : 'CONFIRMER',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(0, 50),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
