import 'package:design_system/design_system.dart';
import 'package:domain/entities/favorite_entity.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/navigation/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/favorites/favorites_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoritesCubit>();
    final state = cubit.state;
    if (state is FavoritesInitial || state is FavoritesError) {
      cubit.load();
    }
    return const _FavoritesView();
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).favoritesTitle)),
      body: SafeArea(
        child: BlocConsumer<FavoritesCubit, FavoritesState>(
          listenWhen: (prev, curr) =>
              curr is FavoritesLoaded &&
              curr.lastErrorMessage != null &&
              (prev is! FavoritesLoaded ||
                  prev.lastErrorMessage != curr.lastErrorMessage),
          listener: (context, state) {
            final message = (state as FavoritesLoaded).lastErrorMessage;
            if (message != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) {
            return switch (state) {
              FavoritesInitial() || FavoritesLoading() => const _LoadingView(),
              FavoritesError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<FavoritesCubit>().load(),
              ),
              FavoritesLoaded(:final items) when items.isEmpty =>
                const _EmptyView(),
              FavoritesLoaded() => _LoadedView(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final FavoritesLoaded state;

  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<FavoritesCubit>().refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
        itemBuilder: (_, index) {
          final favorite = state.items[index];
          final pending = state.pending.contains(favorite.restaurant.id);
          return _FavoriteRow(favorite: favorite, isPending: pending);
        },
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  final FavoriteEntity favorite;
  final bool isPending;

  const _FavoriteRow({required this.favorite, required this.isPending});

  @override
  Widget build(BuildContext context) {
    final restaurant = favorite.restaurant;
    final openStatus = resolveOpenStatus(context, restaurant.openingHours);
    return Dismissible(
      key: ValueKey('favorite-${restaurant.id}'),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      confirmDismiss: (_) async {
        if (isPending) return false;
        context.read<FavoritesCubit>().remove(restaurant.id);
        return true;
      },
      child: Opacity(
        opacity: isPending ? 0.6 : 1,
        child: RestaurantCard(
          name: restaurant.name,
          subtitle: _subtitle(context, restaurant),
          coverUrl: restaurant.cover ?? restaurant.logo,
          openStatus: openStatus?.status,
          openStatusLabel: openStatus?.label,
          variant: RestaurantCardVariant.horizontal,
          onTap: () =>
              context.push(RoutePaths.restaurantDetail(restaurant.id)),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context, RestaurantPublicEntity r) {
    final parts = <String>[];
    final type = restaurantTypeLabel(context, r.type?.name);
    if (type.isNotEmpty) parts.add(type);
    if (r.city.isNotEmpty) parts.add(r.city);
    return parts.join(' · ');
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.m),
      ),
      child: Icon(PhosphorIconsBold.trash, color: scheme.onErrorContainer),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
        itemBuilder: (_, __) => const RestaurantCard(
          name: 'Restaurant name placeholder',
          subtitle: 'A short, evocative subtitle',
          variant: RestaurantCardVariant.horizontal,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: PhosphorIconsDuotone.heart,
      title: l10n.favoritesEmptyTitle,
      body: l10n.favoritesEmptyBody,
      actionLabel: l10n.favoritesEmptyAction,
      onAction: () => context.go(RoutePaths.discover),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: PhosphorIconsDuotone.wifiSlash,
      title: l10n.favoritesErrorTitle,
      body: message,
      actionLabel: l10n.commonTryAgain,
      onAction: onRetry,
    );
  }
}

/// Guards [FavoritesPage] behind an authenticated session. When the customer
/// is signed out, surfaces a CTA to the login screen instead.
class FavoritesPageGate extends StatelessWidget {
  const FavoritesPageGate({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => switch (state) {
        AuthAuthenticated() => const FavoritesPage(),
        AuthInitial() || AuthSubmitting() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        AuthUnauthenticated() => Scaffold(
          appBar: AppBar(title: Text(l10n.favoritesTitle)),
          body: SafeArea(
            child: EmptyState(
              icon: PhosphorIconsDuotone.heart,
              title: l10n.favoritesSignedOutTitle,
              body: l10n.favoritesSignedOutBody,
              actionLabel: l10n.favoritesSignedOutAction,
              onAction: () => context.push(RoutePaths.authLogin),
            ),
          ),
        ),
      },
    );
  }
}
