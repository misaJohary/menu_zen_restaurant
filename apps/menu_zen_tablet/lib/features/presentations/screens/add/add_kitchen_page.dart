import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:domain/entities/kitchen_entity.dart';
import '../../../../core/constants/constants.dart';
import '../../managers/kitchens/kitchens_bloc.dart';

class AddKitchenPage extends StatefulWidget {
  const AddKitchenPage({super.key, this.kitchen});

  final KitchenEntity? kitchen;

  @override
  State<AddKitchenPage> createState() => _AddKitchenPageState();
}

class _AddKitchenPageState extends State<AddKitchenPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  bool get _isEditing => widget.kitchen != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la cuisine' : 'Ajouter une cuisine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kspacing * 4),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'name': widget.kitchen?.name ?? '',
            'active': widget.kitchen?.active ?? true,
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Nom de la cuisine',
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: kspacing * 2),
              FormBuilderSwitch(
                name: 'active',
                title: const Text('Active'),
              ),
              const SizedBox(height: kspacing * 4),
              BlocBuilder<KitchensBloc, KitchensState>(
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: kspacing * 2),
                      ElevatedButton(
                        onPressed: _onSubmit,
                        child: Text(_isEditing ? 'Mettre à jour' : 'Ajouter'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    final values = _formKey.currentState!.value;

    final kitchen = KitchenEntity(
      id: widget.kitchen?.id,
      name: (values['name'] as String).trim(),
      active: values['active'] as bool? ?? true,
    );

    if (_isEditing) {
      context.read<KitchensBloc>().add(KitchenUpdated(kitchen));
    } else {
      context.read<KitchensBloc>().add(KitchenCreated(kitchen));
    }

    Navigator.of(context).pop();
  }
}
