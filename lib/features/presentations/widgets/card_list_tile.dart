import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import 'custom_container.dart';

class CardListTile extends StatelessWidget {
  const CardListTile({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
  });

  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      margin: EdgeInsets.symmetric(
        horizontal: kspacing,
        vertical: kspacing * 2,
      ),
      padding: EdgeInsets.all(kspacing*5),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: kspacing * 2)],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, if (trailing != null) trailing!],
                ),
                if (subtitle != null) ...[subtitle!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
