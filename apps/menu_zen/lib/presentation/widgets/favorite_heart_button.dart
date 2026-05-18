import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/navigation/route_paths.dart';
import '../../l10n/generated/app_localizations.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/favorites/favorites_cubit.dart';

/// Heart toggle backed by the app-scoped [FavoritesCubit].
///
/// When the customer is signed out the heart still renders, but tapping it
/// routes to the login screen instead of mutating server state.
class FavoriteHeartButton extends StatelessWidget {
  final RestaurantPublicEntity restaurant;
  final Color? iconColor;
  final String? tooltip;

  const FavoriteHeartButton({
    super.key,
    required this.restaurant,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final signedIn = authState is AuthAuthenticated;
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          buildWhen: (prev, curr) =>
              prev.restaurantIds.contains(restaurant.id) !=
                  curr.restaurantIds.contains(restaurant.id) ||
              _pendingChanged(prev, curr, restaurant.id),
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            final isFavorite =
                signedIn && state.restaurantIds.contains(restaurant.id);
            final pending =
                state is FavoritesLoaded &&
                state.pending.contains(restaurant.id);
            return IconButton(
              tooltip: tooltip ??
                  (isFavorite
                      ? l10n.favoriteRemoveTooltip
                      : l10n.favoriteSaveTooltip),
              onPressed: pending
                  ? null
                  : () => _onTap(context, signedIn: signedIn),
              icon: Icon(
                isFavorite
                    ? PhosphorIconsFill.heart
                    : PhosphorIconsRegular.heart,
                color: isFavorite
                    ? Theme.of(context).colorScheme.error
                    : iconColor,
              ),
            );
          },
        );
      },
    );
  }

  void _onTap(BuildContext context, {required bool signedIn}) {
    if (!signedIn) {
      context.push(RoutePaths.authLogin);
      return;
    }
    context.read<FavoritesCubit>().toggle(restaurant);
  }

  bool _pendingChanged(
    FavoritesState prev,
    FavoritesState curr,
    int restaurantId,
  ) {
    final prevPending =
        prev is FavoritesLoaded && prev.pending.contains(restaurantId);
    final currPending =
        curr is FavoritesLoaded && curr.pending.contains(restaurantId);
    return prevPending != currPending;
  }
}
