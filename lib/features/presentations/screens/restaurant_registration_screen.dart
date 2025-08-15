import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:menu_zen_restaurant/core/services/photon_geocoding_service.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/user_registration_controller.dart';

import '../../../core/enums/bloc_status.dart';
import '../controllers/restaurant_registration_controller.dart';
import 'package:menu_zen_restaurant/core/navigation/app_router.gr.dart'
    as app_router;

import '../managers/restaurant/restaurant_bloc.dart';

@RoutePage()
class RestaurantRegistrationScreen extends StatefulWidget {
  const RestaurantRegistrationScreen({super.key});

  @override
  State<RestaurantRegistrationScreen> createState() =>
      _RestaurantRegistrationScreenState();
}

class _RestaurantRegistrationScreenState
    extends State<RestaurantRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.pageView(
      routes: [app_router.RestaurantForm(), app_router.UserForm()],
      builder: (context, child, _) {
        final tabsRouter = AutoTabsRouter.of(context);
        return BlocListener<RestaurantBloc, RestaurantState>(
          listenWhen: (previous, current) =>
              previous.restaurantFilled != current.restaurantFilled ||
              previous.userFilled != current.userFilled,
          listener: (context, state) {
            switch ((state.restaurantFilled, state.userFilled)) {
              case (true, true):
                // Both forms complete - create restaurant
                context.read<RestaurantBloc>().add(RestaurantCreated());
                break;
              case (true, false):
                // Restaurant filled, user not - go to user tab
                tabsRouter.setActiveIndex(1);
                break;
              case (false, true):
                // User filled, restaurant not - go to restaurant tab
                tabsRouter.setActiveIndex(0);
                break;
              case (false, false):
                // Neither filled - could stay on current or go to first tab
                // tabsRouter.setActiveIndex(0); // if needed
                break;
            }
          },
          child: Scaffold(body: child),
        );
      },
    );
  }
}

@RoutePage()
class RestaurantForm extends StatefulWidget {
  const RestaurantForm({super.key});

  @override
  State<RestaurantForm> createState() => _RestaurantFormState();
}

class _RestaurantFormState extends State<RestaurantForm> {
  late RestaurantRegistrationController controller;

  @override
  void initState() {
    super.initState();
    controller = RestaurantRegistrationController(context);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: controller.formKey,
      child: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * .5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Veuillez entrer les informations de votre restaurant',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 24),
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(
                    20,
                    errorText: 'Name must be less than 20 characters',
                  ),
                ]),
              ),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Description'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.maxLength(
                    100,
                    errorText: 'Name must be less than 100 characters',
                  ),
                ]),
              ),
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.email(),
                ]),
              ),
              FormBuilderTextField(
                name: 'phone',
                decoration: const InputDecoration(labelText: 'Téléphone'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.phoneNumber(),
                  FormBuilderValidators.required(),
                ]),
              ),
              TypeAheadField<PhotonFeature>(
                debounceDuration: const Duration(milliseconds: 1000),
                emptyBuilder: (context) {
                  return const ListTile(title: Text('No results found'));
                },
                hideOnError: true,
                suggestionsCallback: (search) async {
                  final response = await controller.searchAddress(search);
                  return response.features;
                },
                builder: (context, controller, focusNode) {
                  return FormBuilderTextField(
                    name: 'city',
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: InputDecoration(labelText: 'Ville'),
                  );
                },
                itemBuilder: (context, city) {
                  return ListTile(
                    title: Text(city.properties.name ?? ''),
                    subtitle: Text(city.properties.city ?? ''),
                  );
                },
                onSelected: (city) {
                  controller.setCurrentSelectedAddress(city);
                  controller.formKey.currentState?.fields['ville']?.didChange(
                    [
                          city.properties.name,
                          city.properties.city,
                          city.properties.state,
                          city.properties.country,
                          city.properties.postcode,
                        ]
                        .where((value) => value != null && value.isNotEmpty)
                        .join(', '),
                  );
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Suivant'),
                onPressed: () {
                  controller.validate();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@RoutePage()
class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  late UserRegistrationController controller;

  @override
  void initState() {
    super.initState();
    controller = UserRegistrationController(context);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: controller.formKey,
      child: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * .5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Veuillez entrer votre information en tant que gérant du restaurant',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 24),
              FormBuilderTextField(
                name: 'username',
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(
                    20,
                    errorText: 'Name must be less than 20 characters',
                  ),
                ]),
              ),
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.maxLength(
                    50,
                    errorText: 'Name must be less than 100 characters',
                  ),
                ]),
              ),
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.email(),
                ]),
              ),
              FormBuilderTextField(
                name: 'phone',
                decoration: const InputDecoration(labelText: 'Téléphone'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.phoneNumber(),
                ]),
              ),
              FormBuilderTextField(
                name: 'password',
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.password(),
                  FormBuilderValidators.required(),
                ]),
              ),
              FormBuilderTextField(
                name: 'confirm_password',
                decoration: const InputDecoration(
                  labelText: 'Confirmation de Mot de passe',
                ),
                validator: (pass) {
                  if (pass !=
                      controller
                          .formKey
                          .currentState
                          ?.fields['password']
                          ?.value) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              BlocBuilder<RestaurantBloc, RestaurantState>(
                builder: (context, state) {
                  switch (state.status) {
                    case BlocStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case BlocStatus.loaded:
                      return const SizedBox.shrink();
                    default:
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('ENREGISTRER'),
                        onPressed: () {
                          controller.validate();
                        },
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
