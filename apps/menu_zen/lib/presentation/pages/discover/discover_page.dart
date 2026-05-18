import 'package:design_system/design_system.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../../core/navigation/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../bloc/discover/discover_cubit.dart';
import '../../data/moods.dart';
import 'widgets/discover_header.dart';
import 'widgets/discover_rail.dart';
import 'widgets/editorial_pick.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DiscoverCubit>()..load(),
      child: const _DiscoverView(),
    );
  }
}

class _DiscoverView extends StatelessWidget {
  const _DiscoverView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DiscoverCubit, DiscoverState>(
          builder: (context, state) {
            return switch (state) {
              DiscoverInitial() || DiscoverLoading() => const _LoadingView(),
              DiscoverError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<DiscoverCubit>().load(),
              ),
              DiscoverLoaded() => _LoadedView(state: state,),
            };
          },
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final DiscoverLoaded state;
  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<DiscoverCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          DiscoverHeader(
            city: state.city ?? 'Near you',
            locationDenied: state.locationDenied,
            onSearchTap: () => context.go(RoutePaths.search),
          ),
          const SizedBox(height: AppSpacing.m),
          const _MoodsStrip(),
          const SizedBox(height: AppSpacing.l),
          if (state.pick != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: EditorialPick(
                title: state.pickIsNew ? 'New on Menu Zen' : 'Picked for you',
                restaurant: state.pick!,
                onTap: () => context.push(
                  RoutePaths.restaurantDetail(state.pick!.id),
                ),
              ),
            ),
          if (state.near.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            DiscoverRail(
              title: 'Near you',
              items: state.near,
              showDistance: !state.locationDenied,
            ),
          ],
          if (state.trending.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            DiscoverRail(
              title: 'Trending this week',
              items: state.trending,
              showDistance: !state.locationDenied,
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodsStrip extends StatelessWidget {
  const _MoodsStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        itemBuilder: (_, index) {
          final mood = kMoods[index];
          return MoodChip(
            label: mood.label,
            icon: mood.icon,
            onTap: () => context.go('${RoutePaths.search}?q=${mood.query}'),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
        itemCount: kMoods.length,
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final placeholder = _placeholderRestaurant();
    final placeholders = List.generate(3, (_) => placeholder);
    return Skeletonizer(
      enabled: true,
      child: ScrollConfiguration(
        behavior: const _NoOverscrollBehavior(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            children: [
              const DiscoverHeader(city: 'Near you', locationDenied: false),
              const SizedBox(height: AppSpacing.m),
              Skeleton.replace(
                width: double.infinity,
                height: 44,
                child: const _MoodsStrip(),
              ),
              const SizedBox(height: AppSpacing.l),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: EditorialPick(
                  title: 'Picked for you',
                  restaurant: placeholder,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Skeleton.replace(
                width: double.infinity,
                height: 280,
                child: DiscoverRail(
                  title: 'Near you',
                  items: placeholders,
                  showDistance: false,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Skeleton.replace(
                width: double.infinity,
                height: 280,
                child: DiscoverRail(
                  title: 'Trending this week',
                  items: placeholders,
                  showDistance: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoOverscrollBehavior extends ScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: PhosphorIconsDuotone.wifiSlash,
      title: "We couldn't reach the kitchen.",
      body: message,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}

RestaurantPublicEntity _placeholderRestaurant() {
  return const RestaurantPublicEntity(
    id: 0,
    name: 'Restaurant Name Placeholder',
    description: 'A short, evocative subtitle that fills the space.',
    phone: '',
    email: '',
    city: 'City',
    distanceKm: 1.2,
  );
}

// expose for use elsewhere
String formatRestaurantSubtitle(RestaurantPublicEntity r) {
  final parts = <String>[];
  final type = restaurantTypeLabel(r.type?.name);
  if (type.isNotEmpty) parts.add(type);
  if (r.city.isNotEmpty) parts.add(r.city);
  return parts.join(' · ');
}
