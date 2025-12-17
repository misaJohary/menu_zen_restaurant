import 'package:equatable/equatable.dart';

abstract class TranslationBase extends Equatable{
  final String languageCode;

  const TranslationBase({
    required this.languageCode,
  });
}