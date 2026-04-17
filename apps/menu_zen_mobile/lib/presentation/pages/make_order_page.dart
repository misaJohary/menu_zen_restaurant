import 'package:domain/entities/category_entity.dart';
import 'package:domain/entities/order_entity.dart';
import 'package:domain/entities/order_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/constants.dart';
import '../../core/enums/bloc_status.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/orders/order_menu_item/order_menu_item_bloc.dart';
import '../bloc/tables/table_bloc.dart';
import '../widgets/menu_item_options_sheet.dart';

class MakeOrderPage extends StatefulWidget {
  final OrderEntity? order;
  const MakeOrderPage({super.key, this.order});

  @override
  State<MakeOrderPage> createState() => _MakeOrderPageState();
}

class _MakeOrderPageState extends State<MakeOrderPage> {
  CategoryEntity? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customPriceController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<OrderMenuItemBloc>().add(const OrderMenuItemFetched());
    context.read<TableBloc>().add(const TableFetched());
    context.read<AuthBloc>().add(const AuthUserGot());
    if (widget.order != null) {
      context.read<OrderMenuItemBloc>().add(
            OrderMenuUpdateInitiated(widget.order!),
          );
    }
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    _customPriceController.dispose();
    super.dispose();
  }

  List<CategoryEntity> _categories(List<OrderMenuItem> items) {
    final seen = <int>{};
    final result = <CategoryEntity>[];
    for (final item in items) {
      final cat = item.menuItem.category;
      if (cat != null && seen.add(cat.id ?? -1)) {
        result.add(cat);
      }
    }
    result.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return result;
  }

  List<OrderMenuItem> _filteredItems(List<OrderMenuItem> all) {
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      return all
          .where((item) =>
              item.menuItem.translations.isNotEmpty &&
              item.menuItem.translations.first.name.toLowerCase().contains(q))
          .toList();
    }
    if (_selectedCategory == null) return all;
    return all
        .where((item) => item.menuItem.category?.id == _selectedCategory!.id)
        .toList();
  }

  int _badgeCount(List<OrderMenuItem> ordered, int? menuItemId) {
    if (menuItemId == null) return 0;
    return ordered
        .where((o) => o.menuItem.id == menuItemId && o.unitPrice > 0)
        .fold(0, (sum, o) => sum + o.quantity);
  }

  void _addCustomItem() {
    final name = _customNameController.text.trim();
    final price = double.tryParse(_customPriceController.text.trim());
    if (name.isEmpty || price == null) return;
    context.read<OrderMenuItemBloc>().add(
          OrderMenuItemCustomAdded(
            name,
            price,
            category: _selectedCategory,
          ),
        );
    _customNameController.clear();
    _customPriceController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        if (widget.order != null) {
          context.read<OrderMenuItemBloc>().add(const OrderMenuItemCleared());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Click Menu Zen',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocListener<OrderMenuItemBloc, OrderMenuItemState>(
          listenWhen: (prev, curr) =>
              prev.customAddStatus != curr.customAddStatus,
          listener: (context, state) {
            if (state.customAddStatus == BlocStatus.failed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur lors de la création de l\'article'),
                ),
              );
            }
          },
          child: Column(
          children: [
            // ── Search bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1),

            // ── Body: category rail + item grid ──────────────────────────
            Expanded(
              child: BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
                builder: (context, state) {
                  if (state.status == BlocStatus.loading &&
                      state.orderMenuItems.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = _categories(state.orderMenuItems);
                  final displayItems = _filteredItems(state.orderMenuItems);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Category rail ──────────────────────────────────
                      if (_searchQuery.isEmpty) ...[
                        _CategoryRail(
                          categories: categories,
                          selected: _selectedCategory,
                          onSelect: (cat) =>
                              setState(() => _selectedCategory = cat),
                        ),
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                        ),
                      ],

                      // ── Item grid ──────────────────────────────────────
                      Expanded(
                        child: _ItemGrid(
                          items: displayItems,
                          orderedItems: state.orderedItems,
                          badgeCount: (menuItemId) =>
                              _badgeCount(state.orderedItems, menuItemId),
                          onTap: (globalIndex) {
                            // globalIndex relative to displayItems;
                            // map back to state.orderMenuItems index
                            final item = displayItems[globalIndex];
                            final realIndex =
                                state.orderMenuItems.indexOf(item);
                            if (realIndex >= 0) {
                              context.read<OrderMenuItemBloc>().add(
                                    OrderMenuItemIncremented(realIndex),
                                  );
                            }
                          },
                          onLongPress: (displayIndex) {
                            final item = displayItems[displayIndex];
                            final orderedIndex =
                                state.orderedItems.indexWhere(
                              (o) =>
                                  o.menuItem.id == item.menuItem.id &&
                                  o.unitPrice == item.unitPrice,
                            );
                            showMenuItemOptionsSheet(
                              context,
                              item,
                              orderedIndex,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Custom item quick-add ────────────────────────────────────
            const Divider(height: 1, thickness: 1),
            BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
              buildWhen: (prev, curr) =>
                  prev.customAddStatus != curr.customAddStatus,
              builder: (context, state) => _CustomItemBar(
                nameController: _customNameController,
                priceController: _customPriceController,
                isLoading:
                    state.customAddStatus == BlocStatus.loading,
                onAdd: _addCustomItem,
              ),
            ),
            const Divider(height: 1, thickness: 1),
          ],
        ),
        ),
      ),
    );
  }
}

// ─── Category rail ────────────────────────────────────────────────────────────

class _CategoryRail extends StatelessWidget {
  final List<CategoryEntity> categories;
  final CategoryEntity? selected;
  final ValueChanged<CategoryEntity?> onSelect;

  const _CategoryRail({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      color: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _CategoryItem(
            label: 'TOUT',
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          ...categories.map(
            (cat) => _CategoryItem(
              label: cat.translations.isNotEmpty
                  ? cat.translations.first.name.toUpperCase()
                  : 'CAT',
              isSelected: selected?.id == cat.id,
              onTap: () => onSelect(cat),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: primaryColor, width: 4),
                )
              : const Border(
                  left: BorderSide(color: Colors.transparent, width: 4),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(1, 0),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? primaryColor : Colors.grey.shade700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─── Item grid ────────────────────────────────────────────────────────────────

class _ItemGrid extends StatelessWidget {
  final List<OrderMenuItem> items;
  final List<OrderMenuItem> orderedItems;
  final int Function(int? menuItemId) badgeCount;
  final ValueChanged<int> onTap;
  final ValueChanged<int> onLongPress;

  const _ItemGrid({
    required this.items,
    required this.orderedItems,
    required this.badgeCount,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Aucun article',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    final rowCount = (items.length / 2).ceil();
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: rowCount,
      itemBuilder: (context, rowIndex) {
        final firstIndex = rowIndex * 2;
        final secondIndex = firstIndex + 1;
        final hasSecond = secondIndex < items.length;

        Widget buildCard(int index) {
          final item = items[index];
          final count = badgeCount(item.menuItem.id);
          return _MenuItemCard(
            item: item,
            badge: count,
            onTap: () => onTap(index),
            onLongPress: () => onLongPress(index),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: buildCard(firstIndex)),
                if (hasSecond) ...[
                  const SizedBox(width: 10),
                  Expanded(child: buildCard(secondIndex)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuItemCard extends StatefulWidget {
  final OrderMenuItem item;
  final int badge;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _MenuItemCard({
    required this.item,
    required this.badge,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<_MenuItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController
        .forward()
        .then((_) => _scaleController.reverse())
        .then((_) => widget.onTap());
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.item.menuItem.translations.isNotEmpty
        ? widget.item.menuItem.translations.first.name
        : '';
    final price = formatPriceCompact(widget.item.unitPrice);
    final isSelected = widget.badge > 0;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Badge
            if (widget.badge > 0)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.badge}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom item quick-add bar ────────────────────────────────────────────────

class _CustomItemBar extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final bool isLoading;
  final VoidCallback onAdd;

  const _CustomItemBar({
    required this.nameController,
    required this.priceController,
    required this.isLoading,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nom de l\'article',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Prix',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 44,
            child: ElevatedButton(
              onPressed: isLoading ? null : onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
