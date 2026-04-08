import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:logger/logger.dart';

import '../managers/restaurant/restaurant_bloc.dart';

class RestaurantMoreInfoController extends ChangeNotifier {
  final formKey = GlobalKey<FormBuilderState>();

  final BuildContext context;

  RestaurantMoreInfoController(this.context);

  void validate() {
    try {
      final currentState = formKey.currentState;
      if (currentState?.saveAndValidate() ?? false) {
        final Map<String, dynamic> datas = currentState!.fields.map(
          (key, value) => MapEntry(key, value.value),
        );
        context.read<RestaurantBloc>().add(RestaurantMoreInfoFilled(datas));
      }
    } catch (error) {
      Logger().e(error.toString());
    }
  }
}
