part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {
  const SearchEvent();
}

class SearchStarted extends SearchEvent {
  final String? initialQuery;
  const SearchStarted({this.initialQuery});
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
}

class SearchFiltersChanged extends SearchEvent {
  final DiscoveryFilters filters;
  const SearchFiltersChanged(this.filters);
}

class SearchModeToggled extends SearchEvent {
  final SearchMode mode;
  const SearchModeToggled(this.mode);
}

class SearchScrolledEnd extends SearchEvent {
  const SearchScrolledEnd();
}

class SearchRefreshed extends SearchEvent {
  const SearchRefreshed();
}
