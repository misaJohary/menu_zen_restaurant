import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/restaurant_detail/restaurant_detail_cubit.dart';
import '../../widgets/favorite_heart_button.dart';
import 'tabs/about_tab.dart';
import 'tabs/menu_tab.dart';
import 'tabs/photos_tab.dart';
import 'tabs/reserve_tab.dart';
import 'tabs/reviews_tab.dart';
import 'widgets/detail_bottom_bar.dart';
import 'widgets/detail_hero.dart';
import 'widgets/detail_meta_header.dart';

class RestaurantDetailPage extends StatelessWidget {
  final int restaurantId;
  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RestaurantDetailCubit>()..load(restaurantId),
      child: _RestaurantDetailView(restaurantId: restaurantId),
    );
  }
}

class _RestaurantDetailView extends StatelessWidget {
  final int restaurantId;
  const _RestaurantDetailView({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantDetailCubit, RestaurantDetailState>(
      builder: (context, state) {
        return switch (state) {
          RestaurantDetailInitial() ||
          RestaurantDetailLoading() =>
            const _LoadingScaffold(),
          RestaurantDetailError(:final message) => _ErrorScaffold(
            message: message,
            onRetry: () =>
                context.read<RestaurantDetailCubit>().load(restaurantId),
          ),
          RestaurantDetailLoaded() => _LoadedView(state: state),
        };
      },
    );
  }
}

class _LoadedView extends StatefulWidget {
  final RestaurantDetailLoaded state;
  const _LoadedView({required this.state});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView>
    with SingleTickerProviderStateMixin {
  static const double _heroHeight = 280;

  late final TabController _tabController;
  late final ScrollController _scrollController;
  double _bottomBarOpacity = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // Fade in once we've scrolled past most of the hero.
    final raw = (_scrollController.offset - _heroHeight * 0.6) / 80;
    final clamped = raw.clamp(0.0, 1.0);
    if (clamped != _bottomBarOpacity) {
      setState(() => _bottomBarOpacity = clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = widget.state.detail;
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: _heroHeight,
            backgroundColor: Theme.of(context).colorScheme.surface,
            iconTheme: const IconThemeData(color: Colors.white),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            actions: [
              FavoriteHeartButton(
                restaurant: detail,
                iconColor: Colors.white,
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.shareNetwork),
                onPressed: () {},
                tooltip: l10n.commonShare,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: DetailHero(
                imageUrl: detail.cover ?? detail.logo,
                fallbackText: detail.name,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: DetailMetaHeader(detail: detail),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: Theme.of(context).textTheme.titleSmall,
                tabs: [
                  Tab(text: l10n.tabPhotos),
                  Tab(text: l10n.tabMenu),
                  Tab(text: l10n.tabReserve),
                  Tab(text: l10n.tabReviews),
                  Tab(text: l10n.tabAbout),
                ],
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            PhotosTab(pictures: detail.pictures),
            MenuTab(
              menuByCategory: widget.state.menuByCategory,
              availableLanguages: detail.languages,
            ),
            ReserveTab(detail: detail),
            ReviewsTab(
              restaurantId: detail.id,
              restaurantName: detail.name,
              reviews: widget.state.reviewsPreview,
              summary: widget.state.summary,
            ),
            AboutTab(detail: detail),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedOpacity(
        duration: AppMotion.effectiveDuration(context, AppMotion.transition),
        opacity: _bottomBarOpacity,
        child: IgnorePointer(
          ignoring: _bottomBarOpacity < 0.1,
          child: DetailBottomBar(
            onReserve: () => _tabController.animateTo(2),
            onOrder: () {},
          ),
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _StickyTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorScaffold({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: PhosphorIconsDuotone.wifiSlash,
        title: l10n.commonReachKitchenError,
        body: message,
        actionLabel: l10n.commonTryAgain,
        onAction: onRetry,
      ),
    );
  }
}
