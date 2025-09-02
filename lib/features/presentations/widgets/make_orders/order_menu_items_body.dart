import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/extensions/double_extension.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/loading_widget.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/enums/bloc_status.dart';
import '../../controllers/make_order_controller.dart';
import '../../managers/categories/categories_bloc.dart';
import '../../managers/orders/order_menu_item/order_menu_item_bloc.dart';
import '../custom_container.dart';
import 'order_category_filter.dart';

class OrderMenuItemsBody extends StatefulWidget {
  const OrderMenuItemsBody({super.key, required this.controller});

  final MakeOrderController controller;

  @override
  State<OrderMenuItemsBody> createState() => _OrderMenuItemsBodyState();
}

class _OrderMenuItemsBodyState extends State<OrderMenuItemsBody> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(CategoriesFetched());
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomContainer(
        child: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            return Column(
              children: [
                OrderCategoryFilter(controller: widget.controller),
                SizedBox(height: kspacing * 2),
                Expanded(
                  child: BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case BlocStatus.loading:
                          return Center(child: LoadingWidget());
                        case BlocStatus.failed:
                          return Center(
                            child: Text(
                              'Échec du chargement des éléments de menu',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        case BlocStatus.loaded:
                          final orderMenu = state.orderMenuItems;
                          if (orderMenu.isEmpty) {
                            return Center(
                              child: Text(
                                'Aucun élément de menu trouvé',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                          }
                          return GridView.builder(
                            gridDelegate:
                                 SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: widget.controller.filterMenuOrdered(state).isEmpty ? 4 : 3, // 4 items per row
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio:
                                      1, // makes them look like rectangles
                                ),
                            shrinkWrap: true,
                            itemCount: state.orderMenuItems.length,
                            itemBuilder: (context, index) {
                              final menuItem = orderMenu[index].menuItem;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  menuItem.picture != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            kspacing*2,
                                          ),
                                          child: CachedNetworkImage(
                                            width: double.infinity,
                                            height: 160,
                                            fit: BoxFit.cover,
                                            imageUrl: menuItem.picture!,
                                          ),
                                        )
                                      : const CircleAvatar(
                                          child: Icon(Icons.fastfood),
                                        ),
                                  SizedBox(height: kspacing),
                                  Text(menuItem.name, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 17),),
                                  SizedBox(height: kspacing),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${menuItem.price.formatMoney} Ar',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Color(0xFF7E7D7E)),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F5F5),

                                          borderRadius: BorderRadius.circular(
                                            kspacing * 2,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                if (orderMenu[index].quantity >
                                                    0) {
                                                  widget.controller.decrementQuantity(
                                                    index,
                                                  );
                                                }
                                              },
                                              child: Icon(
                                                Icons.remove_circle,
                                                size: 35,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                kspacing,
                                              ),
                                              child: Text(
                                                orderMenu[index].quantity
                                                    .toString(),
                                                style: Theme.of(context).textTheme.bodyLarge,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                widget.controller.incrementQuantity(
                                                  index,
                                                );
                                                if (widget.controller
                                                            .orderListScroll !=
                                                        null &&
                                                    widget.controller
                                                        .orderListScroll!
                                                        .hasClients) {
                                                  widget.controller.orderListScroll!
                                                      .animateTo(
                                                        widget.controller
                                                            .orderListScroll!
                                                            .position
                                                            .maxScrollExtent,
                                                        duration: Duration(
                                                          seconds: 2,
                                                        ),
                                                        curve: Curves
                                                            .fastOutSlowIn,
                                                      );
                                                }
                                              },
                                              child: Icon(
                                                Icons.add_circle,
                                                size: 35,
                                                color: Color(0xFF201F20),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );

                        default:
                          return SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
