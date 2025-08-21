import 'package:flutter/material.dart';
import 'package:menu_zen_restaurant/features/domains/entities/category_entity.dart';

class CategoryNameWidget extends StatelessWidget {
  const CategoryNameWidget(this.category, {super.key, });

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: category.themeColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        category.name,
        style: Theme.of(
          context,
        ).textTheme.titleLarge,
      ),
    );
  }
}