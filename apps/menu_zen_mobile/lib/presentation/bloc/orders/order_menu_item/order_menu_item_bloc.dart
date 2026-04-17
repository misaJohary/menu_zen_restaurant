import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domain/entities/category_entity.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:domain/entities/order_entity.dart';
import 'package:domain/entities/order_menu_item.dart';
import 'package:domain/repositories/menu_item_repository.dart';
import 'package:domain/repositories/orders_repository.dart';

import '../../../../core/enums/bloc_status.dart';

part 'order_menu_item_event.dart';
part 'order_menu_item_state.dart';

class OrderMenuItemBloc
    extends Bloc<OrderMenuItemEvent, OrderMenuItemState> {
  final OrdersRepository repo;
  final MenuItemRepository menuItemRepo;

  OrderMenuItemBloc({required this.repo, required this.menuItemRepo})
      : super(const OrderMenuItemState()) {
    on<OrderMenuItemFetched>(_onFetched);
    on<OrderMenuItemIncremented>(_onIncremented);
    on<OrderMenuItemDecremented>(_onDecremented);
    on<OrderMenuItemRemoved>(_onRemoved);
    on<OrderMenuItemCleared>(_onCleared);
    on<OrderMenuUpdateInitiated>(_onUpdateInitiated);
    on<OrderMenuItemNoteUpdated>(_onNoteUpdated);
    on<OrderMenuItemPriceUpdated>(_onPriceUpdated);
    on<OrderMenuItemOffered>(_onOffered);
    on<OrderMenuItemCustomAdded>(_onCustomAdded);
    on<OrderMenuItemDuplicatedWithPrice>(_onDuplicatedWithPrice);
    on<OrderMenuItemOrderedIncremented>(_onOrderedIncremented);
    on<OrderMenuItemOrderedDecremented>(_onOrderedDecremented);
  }

  // ─── helpers ───────────────────────────────────────────────────────────────

  /// Sync orderedItems when a catalog item quantity changes.
  /// Matches by menuItem.id AND unitPrice to allow offered (price=0) duplicates.
  List<OrderMenuItem> _syncOrdered(
    List<OrderMenuItem> current,
    OrderMenuItem updated,
  ) {
    final items = List<OrderMenuItem>.from(current);
    final index = items.indexWhere(
      (i) =>
          i.menuItem.id == updated.menuItem.id &&
          i.unitPrice == updated.unitPrice,
    );
    if (updated.quantity > 0) {
      if (index >= 0) {
        items[index] = updated;
      } else {
        items.add(updated);
      }
    } else {
      if (index >= 0) items.removeAt(index);
    }
    return items;
  }

  // ─── handlers ──────────────────────────────────────────────────────────────

  Future<void> _onFetched(
    OrderMenuItemFetched event,
    Emitter<OrderMenuItemState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final result = await repo.getOrderMenuItems(search: event.search);
    if (result.isSuccess) {
      final fetched = result.getSuccess ?? [];
      // Preserve quantities already in orderedItems
      final items = fetched.map((item) {
        final idx = state.orderedItems.indexWhere(
          (o) =>
              o.menuItem.id == item.menuItem.id &&
              o.unitPrice == item.unitPrice,
        );
        return idx >= 0
            ? item.copyWith(quantity: state.orderedItems[idx].quantity)
            : item;
      }).toList();
      emit(state.copyWith(
        orderMenuItems: items,
        status: BlocStatus.loaded,
      ));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  void _onIncremented(
    OrderMenuItemIncremented event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final items = List<OrderMenuItem>.from(state.orderMenuItems);
    if (event.index < 0 || event.index >= items.length) return;
    final updated = items[event.index].copyWith(
      quantity: items[event.index].quantity + 1,
    );
    items[event.index] = updated;
    emit(state.copyWith(
      orderMenuItems: items,
      orderedItems: _syncOrdered(state.orderedItems, updated),
    ));
  }

  void _onDecremented(
    OrderMenuItemDecremented event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final items = List<OrderMenuItem>.from(state.orderMenuItems);
    if (event.index < 0 || event.index >= items.length) return;
    final current = items[event.index];
    if (current.quantity <= 0) return;
    final updated = current.copyWith(quantity: current.quantity - 1);
    items[event.index] = updated;
    emit(state.copyWith(
      orderMenuItems: items,
      orderedItems: _syncOrdered(state.orderedItems, updated),
    ));
  }

  void _onRemoved(
    OrderMenuItemRemoved event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final items = List<OrderMenuItem>.from(state.orderMenuItems);
    final index = items.indexWhere(
      (i) =>
          i.menuItem.id == event.orderMenuItem.menuItem.id &&
          i.unitPrice == event.orderMenuItem.unitPrice,
    );
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: 0);
    }
    final zeroed = event.orderMenuItem.copyWith(quantity: 0);
    emit(state.copyWith(
      orderMenuItems: items,
      orderedItems: _syncOrdered(state.orderedItems, zeroed),
    ));
  }

  void _onCleared(
    OrderMenuItemCleared event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final reset = state.orderMenuItems
        .map((i) => i.copyWith(quantity: 0))
        .toList();
    emit(state.copyWith(orderMenuItems: reset, orderedItems: const []));
  }

  Future<void> _onUpdateInitiated(
    OrderMenuUpdateInitiated event,
    Emitter<OrderMenuItemState> emit,
  ) async {
    await _onFetched(const OrderMenuItemFetched(), emit);
    final catalog = List<OrderMenuItem>.from(state.orderMenuItems);
    if (catalog.isEmpty) return;

    final orderedItems = <OrderMenuItem>[];
    for (final orderItem in event.order.orderMenuItems) {
      final idx = catalog.indexWhere(
        (i) => i.menuItem.id == orderItem.menuItem.id,
      );
      if (idx != -1) {
        catalog[idx] = catalog[idx].copyWith(quantity: orderItem.quantity);
        orderedItems.add(catalog[idx].copyWith(
          unitPrice: orderItem.unitPrice,
          notes: orderItem.notes,
        ));
      } else {
        orderedItems.add(orderItem);
      }
    }
    emit(state.copyWith(orderMenuItems: catalog, orderedItems: orderedItems));
  }

  void _onNoteUpdated(
    OrderMenuItemNoteUpdated event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final items = List<OrderMenuItem>.from(state.orderedItems);
    if (event.orderedIndex >= items.length) return;
    items[event.orderedIndex] = items[event.orderedIndex].copyWith(
      notes: event.note,
    );
    emit(state.copyWith(orderedItems: items));
  }

  void _onPriceUpdated(
    OrderMenuItemPriceUpdated event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final items = List<OrderMenuItem>.from(state.orderedItems);
    if (event.orderedIndex >= items.length) return;
    items[event.orderedIndex] = items[event.orderedIndex].copyWith(
      unitPrice: event.newPrice,
    );
    emit(state.copyWith(orderedItems: items));
  }

  void _onOffered(
    OrderMenuItemOffered event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final offeredItem = OrderMenuItem(
      menuItem: event.item.menuItem,
      quantity: event.offeredQuantity,
      unitPrice: 0.0,
      status: 'init',
    );
    emit(state.copyWith(
      orderedItems: [...state.orderedItems, offeredItem],
    ));
  }

  void _onOrderedIncremented(
    OrderMenuItemOrderedIncremented event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final items = List<OrderMenuItem>.from(state.orderedItems);
    if (event.orderedIndex < 0 || event.orderedIndex >= items.length) return;
    items[event.orderedIndex] = items[event.orderedIndex].copyWith(
      quantity: items[event.orderedIndex].quantity + 1,
    );
    emit(state.copyWith(orderedItems: items));
  }

  void _onOrderedDecremented(
    OrderMenuItemOrderedDecremented event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final items = List<OrderMenuItem>.from(state.orderedItems);
    if (event.orderedIndex < 0 || event.orderedIndex >= items.length) return;
    final current = items[event.orderedIndex];
    if (current.quantity <= 1) return;
    items[event.orderedIndex] = current.copyWith(
      quantity: current.quantity - 1,
    );
    emit(state.copyWith(orderedItems: items));
  }

  void _onDuplicatedWithPrice(
    OrderMenuItemDuplicatedWithPrice event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final copy = event.item.copyWith(
      quantity: 1,
      unitPrice: event.newPrice,
    );
    emit(state.copyWith(
      orderedItems: [...state.orderedItems, copy],
    ));
  }

  Future<void> _onCustomAdded(
    OrderMenuItemCustomAdded event,
    Emitter<OrderMenuItemState> emit,
  ) async {
    emit(state.copyWith(customAddStatus: BlocStatus.loading));

    final entity = MenuItemEntity(
      id: null,
      translations: [
        _SimpleTranslation(name: event.name, languageCode: 'fr'),
      ],
      price: event.price,
      category: event.category,
      menus: const [],
    );

    final result = await menuItemRepo.addMenuItem(entity);

    if (!result.isSuccess) {
      emit(state.copyWith(customAddStatus: BlocStatus.failed));
      return;
    }

    final created = result.getSuccess!;
    final customItem = OrderMenuItem(
      menuItem: created,
      quantity: 1,
      unitPrice: event.price,
      status: 'init',
    );
    emit(state.copyWith(
      customAddStatus: BlocStatus.loaded,
      orderMenuItems: [...state.orderMenuItems, customItem],
      orderedItems: [...state.orderedItems, customItem],
    ));
  }
}

class _SimpleTranslation extends MenuItemTranslation {
  const _SimpleTranslation({
    required super.name,
    required super.languageCode,
  });

  @override
  List<Object?> get props => [name, languageCode];
}
