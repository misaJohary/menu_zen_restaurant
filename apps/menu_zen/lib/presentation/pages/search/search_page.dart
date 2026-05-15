import 'package:design_system/design_system.dart';
import 'package:domain/entities/discovery_filters.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../bloc/search/search_bloc.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/search_map_view.dart';
import 'widgets/search_result_card.dart';

class SearchPage extends StatelessWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SearchBloc>()..add(SearchStarted(initialQuery: initialQuery)),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _controller;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<SearchBloc>().state.query);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<SearchBloc>().add(const SearchScrolledEnd());
    }
  }

  Future<void> _openFilters() async {
    final bloc = context.read<SearchBloc>();
    final result = await showModalBottomSheet<DiscoveryFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterSheet(initial: bloc.state.filters),
    );
    if (result != null) {
      bloc.add(SearchFiltersChanged(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
      listenWhen: (prev, next) => prev.query != next.query,
      listener: (_, state) {
        if (_controller.text != state.query) {
          _controller.text = state.query;
        }
      },
      builder: (context, state) {
        final searchBar = _SearchBar(
          controller: _controller,
          onChanged: (q) =>
              context.read<SearchBloc>().add(SearchQueryChanged(q)),
          onFilterTap: _openFilters,
          filterCount: state.filters.activeCount,
        );
        final modeToggle = _ModeToggle(
          mode: state.mode,
          onChanged: (m) =>
              context.read<SearchBloc>().add(SearchModeToggled(m)),
        );

        if (state.mode == SearchMode.map) {
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                _buildBody(state),
                Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [searchBar, modeToggle],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                searchBar,
                modeToggle,
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const _LoadingList();
    }
    if (state.errorMessage != null && state.items.isEmpty) {
      return EmptyState(
        icon: PhosphorIconsDuotone.wifiSlash,
        title: "We couldn't reach the kitchen.",
        body: state.errorMessage,
        actionLabel: 'Try again',
        onAction: () =>
            context.read<SearchBloc>().add(const SearchRefreshed()),
      );
    }
    if (state.isEmpty) {
      return const EmptyState(
        icon: PhosphorIconsDuotone.forkKnife,
        title: 'No matches yet',
        body: 'Try widening the radius or clearing some filters.',
      );
    }

    final filtered = _applyClient(state);

    if (state.mode == SearchMode.map) {
      return SearchMapView(
        items: filtered,
        origin: LatLng(state.origin.lat, state.origin.long),
      );
    }

    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: filtered.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (_, index) {
        if (index >= filtered.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SearchResultCard(restaurant: filtered[index]);
      },
    );
  }

  /// Client-side application of filters not yet supported by the backend.
  /// TODO(api): drop this once `capabilities` / `dietary` exist server-side.
  List<RestaurantPublicEntity> _applyClient(SearchState state) {
    return state.items;
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final int filterCount;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.filterCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: false,
              decoration: InputDecoration(
                prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass),
                hintText: 'Search restaurants',
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(PhosphorIconsRegular.x),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          _FilterButton(count: filterCount, onTap: onFilterTap),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _FilterButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: count > 0 ? scheme.primary : scheme.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                PhosphorIconsRegular.slidersHorizontal,
                color: count > 0 ? Colors.white : scheme.onSurface,
              ),
              if (count > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final SearchMode mode;
  final ValueChanged<SearchMode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  static const double _height = 44;
  static const double _padding = 4;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMap = mode == SearchMode.map;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth =
                  (constraints.maxWidth - _padding * 2) / 2;
              return Container(
                height: _height,
                padding: const EdgeInsets.all(_padding),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    AnimatedAlign(
                      duration: AppMotion.effectiveDuration(
                        context,
                        AppMotion.transition,
                      ),
                      curve: AppMotion.effectiveCurve(
                        context,
                        AppMotion.emphasized,
                      ),
                      alignment: isMap
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: segmentWidth,
                        height: _height - _padding * 2,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _ModeSegment(
                          label: 'List',
                          icon: PhosphorIconsRegular.list,
                          selected: !isMap,
                          onTap: () => onChanged(SearchMode.list),
                        ),
                        _ModeSegment(
                          label: 'Map',
                          icon: PhosphorIconsRegular.mapTrifold,
                          selected: isMap,
                          onTap: () => onChanged(SearchMode.map),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.effectiveDuration(
              context,
              AppMotion.transition,
            ),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: AppSpacing.s),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (_, __) {
        return Container(
          height: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        );
      },
    );
  }
}
