part of 'order_menu_item_bloc.dart';

abstract class OrderMenuItemEvent extends Equatable {
  const OrderMenuItemEvent();
}

class OrderMenuItemFetched extends OrderMenuItemEvent {
  const OrderMenuItemFetched({this.search});
  final String? search;
  @override
  List<Object?> get props => [search];
}

class OrderMenuItemIncremented extends OrderMenuItemEvent {
  const OrderMenuItemIncremented(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class OrderMenuItemDecremented extends OrderMenuItemEvent {
  const OrderMenuItemDecremented(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class OrderMenuItemRemoved extends OrderMenuItemEvent {
  const OrderMenuItemRemoved(this.orderMenuItem);
  final OrderMenuItem orderMenuItem;
  @override
  List<Object?> get props => [orderMenuItem];
}

class OrderMenuItemCleared extends OrderMenuItemEvent {
  const OrderMenuItemCleared();
  @override
  List<Object?> get props => [];
}

class OrderMenuUpdateInitiated extends OrderMenuItemEvent {
  const OrderMenuUpdateInitiated(this.order);
  final OrderEntity order;
  @override
  List<Object?> get props => [order];
}

/// Update note on an item in orderedItems by index.
class OrderMenuItemNoteUpdated extends OrderMenuItemEvent {
  const OrderMenuItemNoteUpdated(this.orderedIndex, this.note);
  final int orderedIndex;
  final String note;
  @override
  List<Object?> get props => [orderedIndex, note];
}

/// Update unit price on an item in orderedItems by index.
class OrderMenuItemPriceUpdated extends OrderMenuItemEvent {
  const OrderMenuItemPriceUpdated(this.orderedIndex, this.newPrice);
  final int orderedIndex;
  final double newPrice;
  @override
  List<Object?> get props => [orderedIndex, newPrice];
}

/// Add an offered (free) copy of an item to orderedItems.
class OrderMenuItemOffered extends OrderMenuItemEvent {
  const OrderMenuItemOffered(this.item, this.offeredQuantity);
  final OrderMenuItem item;
  final int offeredQuantity;
  @override
  List<Object?> get props => [item, offeredQuantity];
}

/// Add a custom item (name + price) typed by the user directly.
class OrderMenuItemCustomAdded extends OrderMenuItemEvent {
  const OrderMenuItemCustomAdded(this.name, this.price, {this.category});
  final String name;
  final double price;
  final CategoryEntity? category;
  @override
  List<Object?> get props => [name, price, category];
}

/// Increment quantity of an item directly in orderedItems (not in catalog).
class OrderMenuItemOrderedIncremented extends OrderMenuItemEvent {
  const OrderMenuItemOrderedIncremented(this.orderedIndex);
  final int orderedIndex;
  @override
  List<Object?> get props => [orderedIndex];
}

/// Decrement quantity of an item directly in orderedItems (not in catalog).
class OrderMenuItemOrderedDecremented extends OrderMenuItemEvent {
  const OrderMenuItemOrderedDecremented(this.orderedIndex);
  final int orderedIndex;
  @override
  List<Object?> get props => [orderedIndex];
}

/// Duplicate an existing ordered item with a different unit price (qty = 1).
class OrderMenuItemDuplicatedWithPrice extends OrderMenuItemEvent {
  const OrderMenuItemDuplicatedWithPrice(this.item, this.newPrice);
  final OrderMenuItem item;
  final double newPrice;
  @override
  List<Object?> get props => [item, newPrice];
}

/// Select the table the in-progress order will be attached to.
class OrderMenuItemTableSelected extends OrderMenuItemEvent {
  const OrderMenuItemTableSelected(this.tableId);
  final int? tableId;
  @override
  List<Object?> get props => [tableId];
}
