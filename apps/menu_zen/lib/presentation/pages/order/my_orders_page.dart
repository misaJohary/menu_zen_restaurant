import 'package:design_system/design_system.dart';
import 'package:domain/entities/customer_order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../../core/navigation/route_paths.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/my_orders/my_orders_cubit.dart';
import 'widgets/order_card.dart';

/// Customer-facing list of orders, gated by auth.
class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => switch (state) {
        AuthAuthenticated() => BlocProvider(
          create: (_) => getIt<MyOrdersCubit>()..load(),
          child: const _MyOrdersView(),
        ),
        AuthInitial() ||
        AuthSubmitting() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        AuthUnauthenticated() || AuthOffline() => _SignedOutScaffold(),
      },
    );
  }
}

class _SignedOutScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: SafeArea(
        child: EmptyState(
          icon: PhosphorIconsDuotone.shoppingBag,
          title: l10n.orderSignedOutTitle,
          body: l10n.orderSignedOutBody,
          actionLabel: l10n.orderSignedOutAction,
          onAction: () => context.push(RoutePaths.authLogin),
        ),
      ),
    );
  }
}

class _MyOrdersView extends StatefulWidget {
  const _MyOrdersView();

  @override
  State<_MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<_MyOrdersView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Index ↔ filter. `null` = all.
  static const List<CustomerOrderStatus?> _tabFilters = [
    null,
    CustomerOrderStatus.created,
    CustomerOrderStatus.inPreparation,
    CustomerOrderStatus.ready,
    CustomerOrderStatus.served,
    CustomerOrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabFilters.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    context.read<MyOrdersCubit>().changeFilter(
      _tabFilters[_tabController.index],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ordersTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: l10n.ordersTabAll),
            Tab(text: l10n.orderStatusCreated),
            Tab(text: l10n.orderStatusInPreparation),
            Tab(text: l10n.orderStatusReady),
            Tab(text: l10n.orderStatusServed),
            Tab(text: l10n.orderStatusCancelled),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<MyOrdersCubit, MyOrdersState>(
          listenWhen: (prev, curr) =>
              curr is MyOrdersLoaded &&
              curr.lastErrorMessage != null &&
              (prev is! MyOrdersLoaded ||
                  prev.lastErrorMessage != curr.lastErrorMessage),
          listener: (context, state) {
            final message = (state as MyOrdersLoaded).lastErrorMessage;
            if (message != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) => switch (state) {
            MyOrdersInitial() ||
            MyOrdersLoading() => const _LoadingView(),
            MyOrdersError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<MyOrdersCubit>().refresh(),
            ),
            MyOrdersLoaded(:final items) when items.isEmpty => _EmptyView(
              filter: state.filter,
            ),
            MyOrdersLoaded() => _LoadedView(state: state),
          },
        ),
      ),
    );
  }
}

class _LoadedView extends StatefulWidget {
  final MyOrdersLoaded state;
  const _LoadedView({required this.state});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset >= max - 240) {
      context.read<MyOrdersCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<MyOrdersCubit>().refresh(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: widget.state.items.length + (widget.state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
        itemBuilder: (_, index) {
          if (index >= widget.state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.l),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final order = widget.state.items[index];
          return OrderCard(
            order: order,
            onTap: () => context.push(
              RoutePaths.orderDetail(order.id),
              extra: order,
            ),
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final CustomerOrderStatus? filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: PhosphorIconsDuotone.shoppingBag,
      title: l10n.ordersEmptyTitle,
      body: filter == null
          ? l10n.ordersEmptyBody
          : l10n.ordersEmptyFiltered,
      actionLabel: filter == null ? l10n.ordersEmptyAction : null,
      onAction: filter == null
          ? () => context.go(RoutePaths.discover)
          : null,
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
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
      title: l10n.ordersErrorTitle,
      body: message,
      actionLabel: l10n.commonTryAgain,
      onAction: onRetry,
    );
  }
}
