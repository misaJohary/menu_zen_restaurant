import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final int id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatar;
  final DateTime? createdAt;

  const CustomerEntity({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.avatar,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, phone, fullName, avatar, createdAt];
}
