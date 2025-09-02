import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:menu_zen_restaurant/core/extensions/double_extension.dart';
import 'package:menu_zen_restaurant/core/navigation/app_router.gr.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/make_order_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/orders/order_item.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/enums/bloc_status.dart';
import '../../../domains/entities/order_entity.dart';
import '../../managers/orders/order_menu_item/order_menu_item_bloc.dart';
import '../../managers/orders/orders_bloc.dart';
import '../custom_container.dart';

class OrderSummaryPannel extends StatefulWidget {
  const OrderSummaryPannel({super.key, required this.controller, this.order});

  final MakeOrderController controller;
  final OrderEntity? order;

  @override
  State<OrderSummaryPannel> createState() => _OrderSummaryPannelState();
}

class _OrderSummaryPannelState extends State<OrderSummaryPannel> {
  bool _isUpdate = false;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _isUpdate = true;
      widget.controller.orderUpdateInitiated(widget.order!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 500), () {
          widget.controller.formKey.currentState?.patchValue({
            'firstname': widget.order!.clientName,
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
  listeners: [
    BlocListener<OrdersBloc, OrdersState>(
      listenWhen: (previous, current) =>
          previous.createStatus != current.createStatus,
      listener: (context, state) {
        switch (state.createStatus) {
          case BlocStatus.loaded:
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Commande créée avec succès !',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.green),
                ),
                content: OrderItem(
                  order: state.selectedOrder!,
                  onStatusChanged: (_) {},
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Créer une autre'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.router.push(OrdersRoute());
                    },
                    child: Text('Voir listes'),
                  ),
                ],
              ),
            );
            widget.controller.clearOrderMenuItem();
            widget.controller.formKey.currentState?.reset();
            break;
          case BlocStatus.failed:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Une erreur est survenue lors de la création de la commande',
                ),
                backgroundColor: Colors.green,
              ),
            );
            break;
          default:
            break;
        }
      },
),
    BlocListener<OrdersBloc, OrdersState>(
      listenWhen: (previous, current) =>
      previous.updateStatus != current.updateStatus,
      listener: (context, state) {
        switch (state.updateStatus) {
          case BlocStatus.loaded:
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Commande mise à jour avec succès !',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.green),
                ),
                content: OrderItem(
                  order: state.selectedOrder!,
                  onStatusChanged: (_) {},
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Créer une autre'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.router.push(OrdersRoute());
                    },
                    child: Text('Voir listes'),
                  ),
                ],
              ),
            );
            widget.controller.clearOrderMenuItem();
            widget.controller.formKey.currentState?.reset();
            break;
          case BlocStatus.failed:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Une erreur est survenue lors de la création de la commande',
                ),
                backgroundColor: Colors.green,
              ),
            );
            break;
          default:
            break;
        }
      },
    ),
  ],
  child: BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
        builder: (context, state) {
          if (state.status == BlocStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state.status == BlocStatus.failed) {
            return Center(
              child: Text(
                'Échec du chargement des éléments de commande',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          if (state.status == BlocStatus.loaded) {
            return CustomContainer(
              width: 320,
              child: FormBuilder(
                key: widget.controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails de la commande',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: kspacing),
                    OrderInfoField(
                      label: 'Prénom du client',
                      field: FormBuilderTextField(
                        name: 'firstname',
                        decoration: inputDecoration,
                      ),
                    ),
                    SizedBox(height: kspacing * 2),
                    OrderInfoField(
                      label: 'Numéro de table',
                      field: FormBuilderDropdown(
                        //initialValue: 1,
                        name: 'table_number',
                        decoration: inputDecoration,
                        items: [],
                      ),
                    ),
                    SizedBox(height: kspacing * 2),
                    Text(
                      'Votre commande',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 17),
                    ),
                    SizedBox(height: kspacing),
                    BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
                      builder: (context, state) {
                        if (state.orderMenuItems.isEmpty) {
                          return Center(
                            child: Text(
                              'Aucun élément de menu sélectionné',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }
                        final order = widget.controller.filterMenuOrdered(
                          state,
                        );
                        if (order.isEmpty) {
                          return Center(
                            child: Text(
                              'Aucune commande sélectionnée',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }
                        return Expanded(
                          child: ListView(
                            controller: widget.controller.orderListScroll,
                            shrinkWrap: true,
                            children: [
                              ...order.map((orderMenu) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: Text(orderMenu.menuItem.name),
                                        subtitle: RichText(
                                          text: TextSpan(
                                            text: '${orderMenu.quantity}x',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelLarge,
                                            children: [
                                              TextSpan(
                                                text:
                                                    ' ${orderMenu.unitPrice.formatMoney} Ar',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: Color(0xFF999999),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: Text(
                                          '${(orderMenu.quantity * orderMenu.unitPrice).formatMoney} Ar',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Color(0xFF999999),
                                              ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        widget.controller.removeOrderFromList(
                                          orderMenu,
                                        );
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        color: Color(0xFF999999),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text('Total'),
                                      trailing: Text(
                                        '${order.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice)).formatMoney} Ar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.clear, color: Colors.transparent),
                                ],
                              ),
                              BlocBuilder<OrdersBloc, OrdersState>(
                                builder: (context, orderState) {
                                  if (orderState.createStatus ==
                                      BlocStatus.loading || orderState.updateStatus ==
                                      BlocStatus.loading) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (_isUpdate) {
                                    return ElevatedButton(
                                      child: Text('Mettre à jour'),
                                      onPressed: () {
                                        widget.controller.updateOrder(
                                          widget.order!,
                                        );
                                      },
                                    );
                                  } else {
                                    return ElevatedButton(
                                      child: Text('Commander'),
                                      onPressed: () {
                                        widget.controller.validateOrder(state);
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
);
  }
}

final InputDecoration inputDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kspacing * 3),
    borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kspacing * 3),
    borderSide: BorderSide(color: Color(0xFFD9D9D9)),
  ),
);

class OrderInfoField extends StatelessWidget {
  const OrderInfoField({super.key, required this.label, required this.field});

  final String label;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 17),
        ),
        SizedBox(width: kspacing * 3),
        Expanded(child: SizedBox(height: 40, child: field)),
      ],
    );
  }
}
