import 'package:equatable/equatable.dart';

import 'customer_entity.dart';

class CustomerTokenEntity extends Equatable {
  final String accessToken;
  final String tokenType;
  final CustomerEntity customer;

  const CustomerTokenEntity({
    required this.accessToken,
    required this.tokenType,
    required this.customer,
  });

  @override
  List<Object?> get props => [accessToken, tokenType, customer];
}
