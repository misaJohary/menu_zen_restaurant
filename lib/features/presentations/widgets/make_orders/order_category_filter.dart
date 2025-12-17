import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';

import '../../../domains/entities/category_entity.dart';
import '../../controllers/make_order_controller.dart';
import '../../managers/categories/categories_bloc.dart';
import '../../managers/languages/languages_bloc.dart';
import '../custom_chip_choice.dart';

class OrderCategoryFilter extends StatelessWidget {
  const OrderCategoryFilter({super.key, required this.controller});

  final MakeOrderController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Row(
          children: [
            CustomChipChoice<String>(
              label: 'Tout',
              item: 'Tout',
              selected: controller.selectedCategory == null,
              onSelected: (cat) {
                controller.selectCategory(null);
              },
            ),
            BlocBuilder<CategoriesBloc, CategoriesState>(
              buildWhen: (previous, current) =>
                  previous.categories != current.categories,
              builder: (context, state) {
                final categories = state.categories;
                if (categories.isEmpty) {
                  return SizedBox.shrink();
                }
                return BlocBuilder<LanguagesBloc, LanguagesState>(
                  builder: (context, langState) {
                    final selectedLang =
                        langState.selectedLanguage?.code ?? 'en';
                    return Row(
                      children: [
                        ...state.categories.map((category) {
                          final categoryName = category.translations.getField(
                            selectedLang,
                            (t) => t.name,
                          );
                          return CustomChipChoice<CategoryEntity>(
                            label: categoryName,
                            item: category,
                            selected: controller.selectedCategory == category,
                            onSelected: (cat) {
                              controller.selectCategory(cat);
                            },
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
