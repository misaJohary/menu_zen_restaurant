import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:logger/logger.dart';

import '../../../core/injection/dependencies_injection.dart';
import '../../../core/services/photon_geocoding_service.dart';
import 'package:data/models/restaurant_model.dart';
import '../managers/restaurant/restaurant_bloc.dart';

class RestaurantRegistrationController extends ChangeNotifier {
  final formKey = GlobalKey<FormBuilderState>();

  late PhotonFeature currentSelectedAdresss;

  final BuildContext context;

  RestaurantRegistrationController(this.context);

  void setCurrentSelectedAddress(PhotonFeature feature) {
    currentSelectedAdresss = feature;
  }

  void validate() {
    try {
      final currentState = formKey.currentState;
      if (currentState?.saveAndValidate() ?? false) {
        final restaurant = RestaurantModel.fromJson(
          currentState!.fields.map((key, value) => MapEntry(key, value.value)),
        );
        final restWithCoord = restaurant.copyWith(
          lat: currentSelectedAdresss.geometry.coordinates[1],
          long: currentSelectedAdresss.geometry.coordinates[0],
        );
        context.read<RestaurantBloc>().add(RestaurantInfoFilled(restWithCoord));
      }
    } catch (error) {
      Logger().e(error.toString());
    }
  }

  Future<PhotonResponse> searchAddress(String query) async {
    final service = getIt<PhotonGeocodingService>();
    final results = await service.search(query);
    return results;
  }
}
