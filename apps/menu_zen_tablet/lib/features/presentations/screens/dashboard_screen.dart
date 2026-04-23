import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:domain/entities/revenues_entity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../../core/navigation/app_router.gr.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/entities/user_entity.dart';
import '../managers/auths/auth_bloc.dart';
import '../managers/stats/stats_bloc.dart';
import '../widgets/logo.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final role = authState.userRestaurant?.user.role;
    if (role != Role.cook && role != Role.server) {
      context.read<StatsBloc>().add(StatsRevenueGot());
      context.read<StatsBloc>().add(StatsTodayOrderCountGot());
      context.read<StatsBloc>().add(StatsTopMenuItemsGot());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.05),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kspacing * 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                direction: AxisDirection.down,
                child: _buildHeader(context),
              ),
              const SizedBox(height: kspacing * 4),
              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: _buildStatsRow(),
              ),
              const SizedBox(height: kspacing * 4),
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isPortrait = constraints.maxWidth < 900;
                    if (isPortrait) {
                      return Column(
                        children: [
                          _buildBanner(),
                          const SizedBox(height: kspacing * 2),
                          const TopMenuCard(),
                          const SizedBox(height: kspacing * 4),
                          const RevenueCard(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildBanner(),
                              const SizedBox(height: kspacing * 2),
                              const TopMenuCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: kspacing * 4),
                        const Expanded(flex: 3, child: RevenueCard()),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        final revenue = state.revenues?.todayRevenue ?? 0;
        final revenueDiff = state.revenues?.diffPercentage ?? 0;
        final orderCount = state.ordersCount?.todayCount ?? 0;
        final menuCount = state.topMenuItems?.values.length ?? 0;

        return Row(
          children: [
            Expanded(
              child: StatCard(
                label: "Total commande",
                value: orderCount.toString().padLeft(2, '0'),
                percentage:
                    "+ 15,6%", // Static for now as no diff in orderCount entity
                icon: Icons.access_time_filled_rounded,
                iconColor: const Color(0xFF9181F4),
              ),
            ),
            const SizedBox(width: kspacing * 2),
            Expanded(
              child: StatCard(
                label: "Revenue journalière",
                value: "${(revenue / 1000).toStringAsFixed(0)}k",
                percentage:
                    "${revenueDiff.isNegative ? '↓' : '↑'} ${revenueDiff.abs().toStringAsFixed(1)}%",
                isNegative: revenueDiff.isNegative,
                icon: Icons.access_time_filled_rounded,
                iconColor: const Color(0xFFFBDD72),
              ),
            ),
            const SizedBox(width: kspacing * 2),
            Expanded(
              child: StatCard(
                label: "Total menu",
                value: menuCount.toString(),
                percentage: "+ 15,6%",
                icon: Icons.access_time_filled_rounded,
                iconColor: const Color(0xFFB9E8B2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.userRestaurant?.user;
        final actualFullName = user != null
            ? (user.fullName ??
                  '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim())
            : '';
        final displayName = actualFullName.isNotEmpty
            ? actualFullName
            : (user?.username ?? '');

        final initials = displayName.isNotEmpty
            ? displayName
                  .split(' ')
                  .where((e) => e.isNotEmpty)
                  .map((n) => n[0])
                  .take(2)
                  .join()
                  .toUpperCase()
            : (user?.username.isNotEmpty == true
                  ? user!.username[0].toUpperCase()
                  : '');
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (state.userRestaurant != null)
                  Logo(imageUrl: state.userRestaurant!.restaurant.logo)
                else
                  const SizedBox(height: 40),
                const SizedBox(width: kspacing * 2),
                Text(
                  "Dashboard",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => context.router.push(const ProfileRoute()),
              borderRadius: BorderRadius.circular(20),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: primaryColor,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(kspacing * 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Click Menu Zen",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: kspacing),
                SizedBox(
                  width: 250,
                  child: Text(
                    "Gérez vos menus, suivez vos performances et optimisez votre offre en temps réel.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Image.asset(
                'assets/images/salade_au_fromage.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final IconData icon;
  final Color iconColor;
  final bool isNegative;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.percentage,
    required this.icon,
    required this.iconColor,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kspacing * 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(kspacing * 1.5),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: kspacing * 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedCountUp(
                    end:
                        double.tryParse(
                          value.replaceAll(RegExp(r'[^0-9.]'), ''),
                        ) ??
                        0,
                    suffix: value.contains('k') ? 'k' : '',
                    delay: const Duration(milliseconds: 400),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: kspacing),
                  Text(
                    percentage,
                    style: TextStyle(
                      color: isNegative ? Colors.red : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RevenueCard extends StatefulWidget {
  const RevenueCard({super.key});

  @override
  State<RevenueCard> createState() => _RevenueCardState();
}

class _RevenueCardState extends State<RevenueCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kspacing * 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Revenu de la semaine",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.chevron_left, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ],
              ),
            ],
          ),
          const SizedBox(height: kspacing * 4),
          SizedBox(
            height: 350,
            child: BlocBuilder<StatsBloc, StatsState>(
              builder: (context, state) {
                switch (state.revenueStatus) {
                  case BlocStatus.loaded:
                    return SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(
                        majorGridLines: const MajorGridLines(width: 0),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        axisLine: const AxisLine(width: 0),
                        majorTickLines: const MajorTickLines(size: 0),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        numberFormat: NumberFormat.compact(),
                      ),
                      series: <CartesianSeries>[
                        LineSeries<DailyRevenue, String>(
                          color: Colors.blue,
                          dataSource: state.revenues?.dailyRevenues ?? [],
                          xValueMapper: (DailyRevenue data, _) =>
                              DateFormat('E').format(data.date),
                          yValueMapper: (DailyRevenue data, _) => data.revenue,
                          markerSettings: const MarkerSettings(
                            isVisible: false,
                          ),
                        ),
                      ],
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                    );
                  case BlocStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: kspacing),
              const Text(
                "Revenue de la semaine en Ar",
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TopMenuCard extends StatefulWidget {
  const TopMenuCard({super.key});

  @override
  State<TopMenuCard> createState() => _TopMenuCardState();
}

class _TopMenuCardState extends State<TopMenuCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kspacing * 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Meilleures menus",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kspacing * 2),
          BlocBuilder<StatsBloc, StatsState>(
            builder: (context, state) {
              if (state.topMenuStatus == BlocStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = state.topMenuItems?.values;
              if (items == null || items.isEmpty) {
                return const Center(child: Text("Aucune donnée disponible"));
              }
              return Column(
                children: items.take(3).map((item) {
                  final percentage = state.topMenuItems!.totalQuantity > 0
                      ? (item.totalQuantity /
                            state.topMenuItems!.totalQuantity *
                            100)
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: kspacing),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                imageUrl: item.picture,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey.shade200),
                              ),
                            ),
                            const SizedBox(width: kspacing * 1.5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    item.category,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: "${percentage.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: " Vendus",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: (percentage / 100).toDouble(),
                          ),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.grey.shade100,
                                color: Colors.orange,
                                minHeight: 8,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
