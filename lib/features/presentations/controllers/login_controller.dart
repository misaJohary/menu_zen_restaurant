import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../datasources/login_params.dart';
import '../managers/auths/auth_bloc.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormBuilderState>();

  final BuildContext context;

  LoginController(this.context);

  validate() {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      // Perform login action
      final username = formKey.currentState?.fields['username']?.value;
      final password = formKey.currentState?.fields['password']?.value;

      context.read<AuthBloc>().add(
        AuthLoggedIn(LoginParams(username: username, password: password)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields correctly')),
      );
    }
  }
}
