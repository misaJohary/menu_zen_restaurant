import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class BoardTitleWidget extends StatelessWidget {
  const BoardTitleWidget({
    super.key,
    required this.title,
    required this.description,
    required this.labelButton,
    required this.onButtonPressed,
  });

  final String title;
  final String description;
  final String labelButton;
  final VoidCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.all(kspacing),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      subtitle: Text(description),
      trailing: ElevatedButton.icon(
        onPressed: onButtonPressed,
        icon: Icon(Icons.add),
        label: Text(labelButton),
      ),
    );
  }
}
