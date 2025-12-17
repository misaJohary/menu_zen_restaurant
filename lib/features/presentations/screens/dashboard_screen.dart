import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:menu_zen_restaurant/core/extensions/double_extension.dart';
import 'package:menu_zen_restaurant/features/domains/entities/revenues_entity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/enums/bloc_status.dart';
import '../managers/stats/stats_bloc.dart';
import '../widgets/custom_container.dart';

@RoutePage()
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: Center(child: Image.asset('assets/images/dashboard.png')),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: OrderCountCard()),
                Expanded(child: TopMenuCard()),
              ],
            ),
          ),
          Expanded(child: RevenueCard()),
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
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(StatsRevenueGot());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        return CustomContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Revenue journalière",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Expanded(
                child: BlocBuilder<StatsBloc, StatsState>(
                  builder: (context, state) {
                    switch (state.revenueStatus) {
                      case BlocStatus.loaded:
                        final diff = state.revenues?.diffPercentage
                            .ceilToDouble();
                        return Center(
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text:
                                          '${state.revenues?.todayRevenue.formatMoney} Ar',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayLarge,
                                      children: [
                                        TextSpan(
                                          text:
                                              '\n${diff?.isNegative == true ? '' : '+'}$diff%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                color: diff?.isNegative == true
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                primaryYAxis: NumericAxis(
                                  numberFormat: NumberFormat.simpleCurrency(
                                    decimalDigits: 0,
                                    name: 'Ar ',
                                  ),
                                  // Or for more control:
                                  // numberFormat: NumberFormat('#,##0 Ar'),
                                ),
                                legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom,
                                ),
                                series: <CartesianSeries>[
                                  StackedLineSeries<DailyRevenue, String>(
                                    color: Theme.of(context).primaryColor,
                                    dataSource: state.revenues?.dailyRevenues,
                                    name: 'Revenue de la semaine',
                                    yValueMapper: (DailyRevenue data, _) =>
                                        data.revenue,
                                    isVisibleInLegend: true,
                                    xValueMapper: (DailyRevenue data, _) =>
                                        DateFormat(
                                          'dd/MM/yy',
                                        ).format(data.date),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      case BlocStatus.loading:
                        return Text('Calculating....');
                      default:
                        return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrderCountCard extends StatefulWidget {
  const OrderCountCard({super.key});

  @override
  State<OrderCountCard> createState() => _OrderCountCardState();
}

class _OrderCountCardState extends State<OrderCountCard> {
  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(StatsTodayOrderCountGot());
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nombre de commandes",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Expanded(
            child: Center(
              child: BlocBuilder<StatsBloc, StatsState>(
                builder: (context, state) {
                  switch (state.orderCountStatus) {
                    case BlocStatus.loaded:
                      return Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                text: '${state.ordersCount?.todayCount}',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Lottie.asset('assets/lotties/ring.json'),
                          ),
                        ],
                      );
                    // return CircleAvatar(
                    //   radius: 80,
                    //   backgroundColor: Theme.of(context).primaryColor,
                    //   child: CircleAvatar(
                    //     radius: 75,
                    //     backgroundColor: Colors.white,
                    //     child: RichText(
                    //       text: TextSpan(
                    //         text: '${state.ordersCount?.todayCount}',
                    //         style: Theme.of(context).textTheme.displayLarge,
                    //       ),
                    //     ),
                    //   ),
                    // );
                    case BlocStatus.loading:
                      return Text('Calculating....');
                    default:
                      return SizedBox.shrink();
                  }
                },
              ),
            ),
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
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(StatsTopMenuItemsGot());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        return CustomContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Meilleures Menus",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Expanded(
                child: BlocBuilder<StatsBloc, StatsState>(
                  builder: (context, state) {
                    switch (state.topMenuStatus) {
                      case BlocStatus.loaded:
                        final items = state.topMenuItems?.values;
                        if (items == null || items.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            for (int i = 0; i < items.length; i++)
                              Transform.scale(
                                scale: i == 0 ? 1.05 : 1,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                          child: CachedNetworkImage(
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            imageUrl: items[i].picture,
                                          ),
                                        ),
                                        title: Text(items[i].name),
                                        subtitle: Text(items[i].category),
                                        trailing: Text(
                                          '${items[i].totalQuantity} Vendu(s)',
                                        ),
                                      ),
                                      LinearProgressIndicator(
                                        value:
                                            (items[i].totalQuantity /
                                            state.topMenuItems!.totalQuantity),
                                        borderRadius: BorderRadius.circular(30),
                                        minHeight: 8,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      //return Text('${state.topMenuItems.last.name}', style: Theme.of(context).textTheme.displayLarge,);
                      case BlocStatus.loading:
                        return Text('Calculating....');
                      default:
                        return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TopServerCard extends StatefulWidget {
  const TopServerCard({super.key});

  @override
  State<TopServerCard> createState() => _TopServerCardState();
}

class _TopServerCardState extends State<TopServerCard> {
  @override
  void initState() {
    super.initState();
    //context.read<StatsBloc>().add(StatsTodayOrderCountGot());
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Meilleurs serveur",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Spacer(),
          // Expanded(
          //   child: Center(
          //     child: BlocBuilder<StatsBloc, StatsState>(
          //       builder: (context, state) {
          //         switch (state.orderCountStatus) {
          //           case BlocStatus.loaded:
          //             return Text(
          //               '${state.ordersCount?.dailyCounts.last.count}',
          //               style: Theme.of(context).textTheme.displayLarge,
          //             );
          //           case BlocStatus.loading:
          //             return Text('Calculating....');
          //           default:
          //             return SizedBox.shrink();
          //         }
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
