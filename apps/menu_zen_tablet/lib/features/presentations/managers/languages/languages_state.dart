part of 'languages_bloc.dart';

class LanguagesState extends Equatable {
  const LanguagesState({
    this.status = BlocStatus.init,
    this.languages = const [],
    this.selectedLanguage,
  });

  final BlocStatus status;
  final List<LanguageEntity> languages;
  final LanguageEntity? selectedLanguage;

  @override
  List<Object?> get props => [status, languages, selectedLanguage];

  LanguagesState copyWith({
    BlocStatus? status,
    List<LanguageEntity>? languages,
    LanguageEntity? selectedLanguage,
  }) {
    return LanguagesState(
      status: status ?? this.status,
      languages: languages ?? this.languages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
