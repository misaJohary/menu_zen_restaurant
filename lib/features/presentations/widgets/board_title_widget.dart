import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class BoardTitleWidget extends StatelessWidget {
  const BoardTitleWidget({
    super.key,
    required this.title,
    this.description,
    required this.labelButton,
    this.contentPadding,
    required this.onButtonPressed,
  });

  final String title;
  final String? description;
  final String labelButton;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      contentPadding: contentPadding?? EdgeInsets.all(kspacing),
      titleTextStyle: Theme.of(
        context,
      ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w800),
      subtitle: description!= null? Text(
        description!,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(color: grey, fontSize: 22),
      ) : null,
      trailing: ElevatedButton.icon(
        onPressed: onButtonPressed,
        icon: Icon(Icons.add),
        label: Text(labelButton),
      ),
    );
  }
}
