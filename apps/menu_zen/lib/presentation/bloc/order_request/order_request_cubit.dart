import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/entities/customer_order_type.dart';
import 'package:domain/params/customer_order_create_params.dart';
import 'package:domain/params/customer_order_item_create_params.dart';
import 'package:domain/repositories/customer_orders_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_request_state.dart';

class OrderRequestCubit extends Cubit<OrderRequestState> {
  final CustomerOrdersRepository _repository;

  OrderRequestCubit(this._repository) : super(const OrderRequestIdle());

  Future<void> submitDelivery({
    required int restaurantId,
    required String deliveryAddress,
    required String contactPhone,
    String? contactName,
    String? deliveryNotes,
    required List<CustomerOrderItemCreateParams> items,
  }) async {
    emit(const OrderRequestSubmitting());
    final result = await _repository.create(
      CustomerOrderCreateParams(
        restaurantId: restaurantId,
        orderType: CustomerOrderType.delivery,
        contactName: contactName,
        contactPhone: contactPhone,
        deliveryAddress: deliveryAddress,
        deliveryNotes: deliveryNotes,
        items: items,
      ),
    );
    if (result.isSuccess && result.getSuccess != null) {
      emit(OrderRequestSubmitted(result.getSuccess!));
    } else {
      emit(
        OrderRequestError(
          result.getError?.message ?? 'Could not place your order.',
        ),
      );
    }
  }

  void reset() => emit(const OrderRequestIdle());
}
