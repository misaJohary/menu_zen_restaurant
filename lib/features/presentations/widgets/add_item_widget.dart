import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../core/constants/constants.dart';

class AddItemWidget extends StatelessWidget {
  const AddItemWidget({
    super.key,
    required this.title,
    required this.formBuilderFields,
    required this.formKey,
    this.confirmationButton,
    this.cancelButton,
  });

  final String title;
  final List<Widget> formBuilderFields;
  final GlobalKey formKey;
  final Widget? confirmationButton;
  final Widget? cancelButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kspacing * 2),
        child: FormBuilder(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              ...formBuilderFields,
              Row(
                children: [
                  ...confirmationButton != null ? [confirmationButton!, SizedBox(width: kspacing * 2)] : [],
                  ...cancelButton != null ? [cancelButton!] : [],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
