import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/login_controller.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../../core/navigation/app_router.gr.dart';
import '../managers/auths/auth_bloc.dart';
import '../widgets/logo.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = LoginController(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          //width: MediaQuery.sizeOf(context).width * .3,
          child: MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthState>(
                listenWhen: (previous, current) {
                  return previous.authStatus != current.authStatus;
                },
                listener: (context, state) {
                  if (state.authStatus == AuthStatus.authenticated) {
                    context.read<AuthBloc>().add(AuthUserGot());
                  } else if (state.authStatus == AuthStatus.unauthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed, please try again')),
                    );
                  }
                },
              ),
              BlocListener<AuthBloc, AuthState>(
                listenWhen: (previous, current) {
                  return previous.status != current.status;
                },
                listener: (context, state) {
                  if (state.status == BlocStatus.loaded) {
                    context.router.reevaluateGuards();
                    // context.router.pushAndPopUntil(
                    //   MainRoute(),
                    //   predicate: (_) =>
                    //       false, // This predicate ensures all previous routes are removed
                    // );
                  }
                },
              ),
            ],
            child: FormBuilder(
              key: controller.formKey,
              child: Row(
                children: [
                  Expanded(child: Center(child: Logo(isBig: true))),
                  //Spacer(),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 400,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //SizedBox(height: kspacing*5,),
                            FormBuilderTextField(
                              name: 'username',
                              decoration: InputDecoration(
                                labelText: 'Nom d\'utilisateur',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                            FormBuilderTextField(
                              name: 'password',
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                              ),
                              obscureText: true,
                              validator: FormBuilderValidators.required(),
                            ),
                            SizedBox(height: kspacing * 3),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state.status == BlocStatus.loading) {
                                  return CircularProgressIndicator();
                                }
                                return ElevatedButton(
                                  onPressed: controller.validate,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(600, 60),
                                  ),
                                  child: Text('Se connecter'),
                                );
                              },
                            ),
                            SizedBox(height: kspacing * 3),
                            ElevatedButton(
                              onPressed: () {
                                context.router.push(
                                  RestaurantRegistrationRoute(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(600, 60),
                                backgroundColor: Colors.black54,
                              ),
                              child: Text('S\'inscrire'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
