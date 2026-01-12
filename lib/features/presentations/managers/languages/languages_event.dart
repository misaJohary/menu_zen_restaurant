part of 'languages_bloc.dart';

abstract class LanguagesEvent extends Equatable {
  const LanguagesEvent();
}

class LanguagesFetched extends LanguagesEvent {
  const LanguagesFetched();

  @override
  List<Object?> get props => [];
}

class LanguageSelected extends LanguagesEvent {
  final LanguageEntity language;

  const LanguageSelected(this.language);

  @override
  List<Object?> get props => [language];
}




