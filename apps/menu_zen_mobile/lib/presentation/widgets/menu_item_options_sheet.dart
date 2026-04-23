import 'package:domain/entities/order_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/constants.dart';
import '../bloc/orders/order_menu_item/order_menu_item_bloc.dart';

/// Shows the long-press options sheet for an ordered menu item.
///
/// [orderedIndex] is the position in [OrderMenuItemState.orderedItems].
/// Pass -1 when the item is not yet in the ordered list (will not show
/// note/price/offer until added).
void showMenuItemOptionsSheet(
  BuildContext context,
  OrderMenuItem item,
  int orderedIndex,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: context.read<OrderMenuItemBloc>(),
      child: _OptionsSheet(item: item, orderedIndex: orderedIndex),
    ),
  );
}

class _OptionsSheet extends StatefulWidget {
  final OrderMenuItem item;
  final int orderedIndex;

  const _OptionsSheet({required this.item, required this.orderedIndex});

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  bool _priceExpanded = false;
  bool _noteExpanded = false;
  bool _offerExpanded = false;

  late final TextEditingController _priceController;
  late final TextEditingController _noteController;
  int _offeredQty = 1;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.unitPrice.toInt().toString(),
    );
    _noteController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _itemName => widget.item.menuItem.translations.isNotEmpty
      ? widget.item.menuItem.translations.first.name
      : 'Article';

  String get _itemPrice => widget.item.unitPrice == 0
      ? 'Offert'
      : formatPriceFull(widget.item.unitPrice);

  void _applyPrice() {
    final newPrice =
        double.tryParse(_priceController.text) ?? widget.item.unitPrice;
    context.read<OrderMenuItemBloc>().add(
      OrderMenuItemDuplicatedWithPrice(widget.item, newPrice),
    );
    Navigator.pop(context);
  }

  void _applyNote() {
    if (widget.orderedIndex >= 0) {
      context.read<OrderMenuItemBloc>().add(
        OrderMenuItemNoteUpdated(
          widget.orderedIndex,
          _noteController.text.trim(),
        ),
      );
    }
    Navigator.pop(context);
  }

  void _applyOffer() {
    context.read<OrderMenuItemBloc>().add(
      OrderMenuItemOffered(widget.item, _offeredQty),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Item name + price
          Text(
            _itemName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _itemPrice,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // ── Éditer prix ──────────────────────────────────────
          _ExpandableRow(
            icon: Icons.edit_outlined,
            label: 'Éditer prix',
            expanded: _priceExpanded,
            onTap: () => setState(() {
              _priceExpanded = !_priceExpanded;
            }),
            expandedContent: _PriceField(
              controller: _priceController,
              onOk: _applyPrice,
            ),
          ),

          // ── Ajouter note ──────────────────────────────────────
          _ExpandableRow(
            icon: Icons.note_outlined,
            label: 'Ajouter note',
            expanded: _noteExpanded,
            onTap: () => setState(() {
              _noteExpanded = !_noteExpanded;
            }),
            expandedContent: _NoteField(
              controller: _noteController,
              onOk: _applyNote,
            ),
          ),

          // ── Offrir ────────────────────────────────────────────
          _ExpandableRow(
            icon: Icons.card_giftcard_outlined,
            label: 'Offrir',
            expanded: _offerExpanded,
            onTap: () => setState(() {
              _offerExpanded = !_offerExpanded;
            }),
            expandedContent: _OfferField(
              quantity: _offeredQty,
              onDecrement: () {
                if (_offeredQty > 1) setState(() => _offeredQty--);
              },
              onIncrement: () => setState(() => _offeredQty++),
              onOk: _applyOffer,
            ),
          ),

          const SizedBox(height: 12),

          // ── Annuler ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CancelRow(onTap: () => Navigator.pop(context)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Private sub-widgets ─────────────────────────────────────────────────────

class _ExpandableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool expanded;
  final VoidCallback onTap;
  final Widget expandedContent;

  const _ExpandableRow({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.onTap,
    required this.expandedContent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: expandedContent,
              ),
          ],
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onOk;

  const _PriceField({required this.controller, required this.onOk});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffix: const Text('Ar', style: TextStyle(color: Colors.grey)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onOk,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onOk;

  const _NoteField({required this.controller, required this.onOk});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Ajouter une instruction...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onOk,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _OfferField extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onOk;

  const _OfferField({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: 12),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        _QtyButton(icon: Icons.add, onTap: onIncrement),
        const Spacer(),
        ElevatedButton(
          onPressed: onOk,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}

class _CancelRow extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.close, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Annuler',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
