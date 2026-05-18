import 'package:domain/entities/customer_token_entity.dart';

import 'customer_model.dart';

class CustomerTokenModel {
  static CustomerTokenEntity fromJson(Map<String, dynamic> json) {
    return CustomerTokenEntity(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      customer: CustomerModel.fromJson(
        json['customer'] as Map<String, dynamic>,
      ),
    );
  }
}
