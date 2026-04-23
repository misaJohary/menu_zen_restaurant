import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:domain/entities/category_entity.dart';
import 'package:data/extensions/color_extension.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/languages/languages_bloc.dart';

import '../../../core/constants/constants.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onEdit});

  final CategoryEntity category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguagesBloc, LanguagesState>(
      builder: (context, langState) {
        final selectedLang = langState.selectedLanguage?.code ?? 'fr';
        final categoryName = category.translations.getField(
          selectedLang,
          (t) => t.name,
        );
        final categoryDescription =
            category.translations.getOptionalField(
              selectedLang,
              (t) => t.description,
            ) ??
            '';

        // Extract emoji if it's there
        final regex = RegExp(
          r'^(\p{Emoji_Presentation}|\p{Emoji}\uFE0F)\s*',
          unicode: true,
        );
        final match = regex.firstMatch(categoryName);
        String? emoji;
        String name = categoryName;

        if (match != null) {
          emoji = match.group(1);
          name = categoryName.substring(match.end);
        }

        final color = category.themeColor ?? Colors.grey;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Color.lerp(color, Colors.white, 0.82),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(kspacing * 2.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emoji ?? '📂',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit_outlined,
                          color: color.darken(0.35),
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: kspacing * 4),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color.darken(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: kspacing / 2),
                  Text(
                    categoryDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color.darken(0.4).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
