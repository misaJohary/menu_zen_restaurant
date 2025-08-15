import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class CardListTile extends StatelessWidget {
  const CardListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(kspacing * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, if (subtitle != null) subtitle!],
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}