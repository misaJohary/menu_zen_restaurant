import 'package:design_system/design_system.dart';
import 'package:domain/entities/reservation_request_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../../core/navigation/route_paths.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/my_reservations/my_reservations_cubit.dart';
import 'widgets/reservation_card.dart';

/// Customer-facing list of reservations, gated by auth.
class MyReservationsPage extends StatelessWidget {
  const MyReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => switch (state) {
        AuthAuthenticated() => BlocProvider(
          create: (_) => getIt<MyReservationsCubit>()..load(),
          child: const _MyReservationsView(),
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
      appBar: AppBar(title: Text(l10n.reservationsTitle)),
      body: SafeArea(
        child: EmptyState(
          icon: PhosphorIconsDuotone.bookmarkSimple,
          title: l10n.reservationSignedOutTitle,
          body: l10n.reservationSignedOutBody,
          actionLabel: l10n.reservationSignedOutAction,
          onAction: () => context.push(RoutePaths.authLogin),
        ),
      ),
    );
  }
}

class _MyReservationsView extends StatefulWidget {
  const _MyReservationsView();

  @override
  State<_MyReservationsView> createState() => _MyReservationsViewState();
}

class _MyReservationsViewState extends State<_MyReservationsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Index ↔ filter. `null` = all.
  static const List<ReservationRequestStatus?> _tabFilters = [
    null,
    ReservationRequestStatus.waiting,
    ReservationRequestStatus.accepted,
    ReservationRequestStatus.refused,
    ReservationRequestStatus.canceled,
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
    context.read<MyReservationsCubit>().changeFilter(
      _tabFilters[_tabController.index],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservationsTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: l10n.reservationsTabAll),
            Tab(text: l10n.reservationStatusWaiting),
            Tab(text: l10n.reservationStatusAccepted),
            Tab(text: l10n.reservationStatusRefused),
            Tab(text: l10n.reservationStatusCanceled),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<MyReservationsCubit, MyReservationsState>(
          listenWhen: (prev, curr) =>
              curr is MyReservationsLoaded &&
              curr.lastErrorMessage != null &&
              (prev is! MyReservationsLoaded ||
                  prev.lastErrorMessage != curr.lastErrorMessage),
          listener: (context, state) {
            final message = (state as MyReservationsLoaded).lastErrorMessage;
            if (message != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) => switch (state) {
            MyReservationsInitial() ||
            MyReservationsLoading() => const _LoadingView(),
            MyReservationsError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<MyReservationsCubit>().refresh(),
            ),
            MyReservationsLoaded(:final items) when items.isEmpty =>
              _EmptyView(filter: state.filter),
            MyReservationsLoaded() => _LoadedView(state: state),
          },
        ),
      ),
    );
  }
}

class _LoadedView extends StatefulWidget {
  final MyReservationsLoaded state;
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
      context.read<MyReservationsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<MyReservationsCubit>().refresh(),
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
          final reservation = widget.state.items[index];
          return ReservationCard(
            reservation: reservation,
            onTap: () => context.push(
              RoutePaths.reservationDetail(reservation.id),
              extra: reservation,
            ),
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final ReservationRequestStatus? filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: PhosphorIconsDuotone.calendarBlank,
      title: l10n.reservationsEmptyTitle,
      body: filter == null
          ? l10n.reservationsEmptyBody
          : l10n.reservationsEmptyFiltered,
      actionLabel: filter == null ? l10n.reservationsEmptyAction : null,
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
      title: l10n.reservationsErrorTitle,
      body: message,
      actionLabel: l10n.commonTryAgain,
      onAction: onRetry,
    );
  }
}

