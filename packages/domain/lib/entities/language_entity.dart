import 'package:equatable/equatable.dart';

class LanguageEntity extends Equatable {
  final String code;
  final String name;

  const LanguageEntity({required this.code, required this.name});

  @override
  List<Object?> get props => [code, name];
}
