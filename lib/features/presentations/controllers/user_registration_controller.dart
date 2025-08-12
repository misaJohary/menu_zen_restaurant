import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../core/injection/dependencies_injection.dart';
import '../../../core/services/photon_geocoding_service.dart';

class UserRegistrationController extends ChangeNotifier {
  final formKey = GlobalKey<FormBuilderState>();

  final BuildContext context;

  UserRegistrationController(this.context);

  void validate() {
    if (formKey.currentState?.saveAndValidate() ?? false) {}
  }
}
