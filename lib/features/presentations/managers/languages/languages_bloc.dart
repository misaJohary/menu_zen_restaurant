import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/bloc_status.dart';
import '../../../domains/entities/language_entity.dart';
import '../../../domains/repositories/languages_repository.dart';

part 'languages_event.dart';
part 'languages_state.dart';

@injectable
class LanguagesBloc extends Bloc<LanguagesEvent, LanguagesState> {
  final LanguagesRepository languagesRepository;

  LanguagesBloc({required this.languagesRepository}) : super(LanguagesState()) {
    on<LanguagesFetched>(_onLanguagesFetched);
    on<LanguageSelected>(_onLanguageSelected);
  }

  _onLanguagesFetched(
    LanguagesFetched event,
    Emitter<LanguagesState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final res = await languagesRepository.getLanguages();
    if (res.isSuccess) {
      final languages = res.getSuccess!;
      emit(
        state.copyWith(
          status: BlocStatus.loaded,
          languages: languages,
          selectedLanguage: languages.isNotEmpty ? languages.first : null,
        ),
      );
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onLanguageSelected(
    LanguageSelected event,
    Emitter<LanguagesState> emit,
  ) async {
    emit(state.copyWith(selectedLanguage: event.language));
  }
}
