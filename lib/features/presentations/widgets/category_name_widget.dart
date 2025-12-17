import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:menu_zen_restaurant/features/domains/entities/category_entity.dart';

import '../managers/languages/languages_bloc.dart';

class CategoryNameWidget extends StatelessWidget {
  const CategoryNameWidget(
    this.category, {
    super.key,
    this.height,
    this.style,
    this.padding,
  });

  final CategoryEntity category;
  final double? height;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguagesBloc, LanguagesState>(
      builder: (context, langState) {
        final selectedLang = langState.selectedLanguage?.code ?? 'en';
        final categoryName = category.translations.getField(
          selectedLang,
          (t) => t.name,
        );

        return Container(
          height: height,
          padding: padding ?? EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: category.themeColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            categoryName,
            style:
                style ??
                Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: darken(category.themeColor!, .5),
                ),
          ),
        );
      },
    );
  }
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
