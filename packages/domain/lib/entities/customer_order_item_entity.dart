import 'package:equatable/equatable.dart';

class CustomerOrderItemEntity extends Equatable {
  final int? id;
  final int menuItemId;
  final int quantity;
  final int unitPrice;
  final String? notes;

  const CustomerOrderItemEntity({
    this.id,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  @override
  List<Object?> get props => [id, menuItemId, quantity, unitPrice, notes];
}
