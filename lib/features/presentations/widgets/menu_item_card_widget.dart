import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:menu_zen_restaurant/core/extensions/double_extension.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_item_entity.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/category_name_widget.dart';

class MenuItemCardWidget extends StatelessWidget {
  const MenuItemCardWidget({
    super.key,
    required this.menuItem,
    required this.onEdit,
    required this.onStatusChanged,
    required this.selectedLanguage,
  });

  final MenuItemEntity menuItem;
  final VoidCallback onEdit;
  final Function(bool) onStatusChanged;
  final String selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final menuName = menuItem.translations.getField(
      selectedLanguage,
      (t) => t.name,
    );
    final menuDescription =
        menuItem.translations.getOptionalField(
          selectedLanguage,
          (t) => t.description,
        ) ??
        '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${menuItem.price.formatMoney}Ar',
                  style: const TextStyle(
                    color: Color(0xFF91C14F),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF91C14F),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: menuItem.picture != null
                      ? CachedNetworkImage(
                          imageUrl: menuItem.picture!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        menuDescription,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (menuItem.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          menuItem.category!.themeColor?.withOpacity(0.1) ??
                          const Color(0xFFFDE7E7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Try to find emoji if it's the first character of the name
                        Text(
                          _getEmoji(menuItem.category!.translations.first.name),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          menuItem.category!.translations
                              .getField(selectedLanguage, (t) => t.name)
                              .replaceAll(
                                RegExp(
                                  r'^(\p{Emoji_Presentation}|\p{Emoji}\uFE0F)\s*',
                                  unicode: true,
                                ),
                                '',
                              ),
                          style: TextStyle(
                            color: darken(
                              menuItem.category!.themeColor ?? Colors.red,
                              0.4,
                            ),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Disponible',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: menuItem.active ?? true,
                        onChanged: onStatusChanged,
                        activeThumbColor: const Color(0xFF91C14F),
                        activeTrackColor: const Color(
                          0xFF91C14F,
                        ).withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEmoji(String name) {
    final regex = RegExp(
      r'^(\p{Emoji_Presentation}|\p{Emoji}\uFE0F)\s*',
      unicode: true,
    );
    final match = regex.firstMatch(name);
    return match?.group(1) ?? '📁';
  }
}
