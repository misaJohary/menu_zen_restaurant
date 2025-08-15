import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:logger/logger.dart';

import '../../../core/injection/dependencies_injection.dart';
import '../../../core/services/photon_geocoding_service.dart';
import '../../datasources/models/user_model.dart';
import '../../domains/entities/user_entity.dart';
import '../managers/restaurant/restaurant_bloc.dart';

class UserRegistrationController extends ChangeNotifier {
  final formKey = GlobalKey<FormBuilderState>();

  final BuildContext context;

  UserRegistrationController(this.context);

  void validate() {
    final currentState = formKey.currentState;
    // currentState?.patchValue({
    //   'username': 'Joe',
    //   'role': 'super_admin',
    //   'password': '12345&Six'
    // });
    // final json = currentState!.fields.map((key, value) => MapEntry(key, value.value));
    // json['role']= 'super_admin';
    // Logger().e(currentState.fields.map((key, value) => MapEntry(key, value.value)));
    //   final user = UserModel.fromJson(
    //       json
    //   );
    //   Logger().e(user);
    //   context.read<RestaurantBloc>().add(
    //     RestaurantUserInfoFilled(user.copyWith(roles: Role.admin)),
    //   );
    if (formKey.currentState?.saveAndValidate() ?? false) {
      //username, name, email, phone, password, confirm_password
      final json = currentState!.fields.map((key, value) => MapEntry(key, value.value));
      json['roles']= 'admin';
      final user = UserModel.fromJson(
        json
      );
      Logger().e(user);
      context.read<RestaurantBloc>().add(
        RestaurantUserInfoFilled(user),
      );
    }
  }
}
