import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/login_controller.dart';

import '../../../core/config/base_url_config.dart';
import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../../core/injection/dependencies_injection.dart';
import '../../../core/services/ws_service.dart';
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
  bool? _isConnected;
  bool _isChecking = false;
  String _currentBaseUrl = '';

  @override
  void initState() {
    super.initState();
    controller = LoginController(context);
    _currentBaseUrl = BaseUrlConfig.current;
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final baseUrl = _currentBaseUrl;
    if (baseUrl.isEmpty) {
      setState(() {
        _isConnected = false;
      });
      return;
    }
    setState(() {
      _isChecking = true;
    });
    final isConnected = await _pingBaseUrl(baseUrl);
    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _isConnected = isConnected;
    });
  }

  Future<bool> _pingBaseUrl(String baseUrl) async {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return false;
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 3),
        receiveTimeout: Duration(seconds: 3),
        sendTimeout: Duration(seconds: 3),
        validateStatus: (status) => status != null,
      ),
    );
    try {
      final response = await dio.get('/');
      return response.statusCode != null;
    } on DioException catch (e) {
      return e.response != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _openBaseUrlDialog() async {
    final controller = TextEditingController(text: _currentBaseUrl);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Server Base URL'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Base URL',
              hintText: 'https://example.com/api',
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    final normalized = result.trim();
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid URL.')),
      );
      return;
    }
    await _applyBaseUrl(normalized);
  }

  Future<void> _applyBaseUrl(String value) async {
    await BaseUrlConfig.set(value);
    final normalized = BaseUrlConfig.current;
    if (getIt.isRegistered<Dio>(instanceName: 'withInterceptor')) {
      getIt<Dio>(instanceName: 'withInterceptor').options.baseUrl = normalized;
    }
    if (getIt.isRegistered<Dio>(instanceName: 'noInterceptor')) {
      getIt<Dio>(instanceName: 'noInterceptor').options.baseUrl = normalized;
    }
    if (getIt.isRegistered<RestaurantWebSocketService>()) {
      getIt<RestaurantWebSocketService>().updateBaseUrl(normalized);
    }
    if (!mounted) return;
    setState(() {
      _currentBaseUrl = normalized;
    });
    await _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
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
                          SnackBar(
                            content: Text('Login failed, please try again'),
                          ),
                        );
                      }
                    },
                  ),
                  BlocListener<AuthBloc, AuthState>(
                    listenWhen: (previous, current) {
                      return previous.status != current.status;
                    },
                    listener: (context, state) {
                      if (state.status == BlocStatus.loaded &&
                          state.authStatus == AuthStatus.authenticated) {
                        context.router.replaceAll([const MainRoute()]);
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
                                      RegistrationRoute(),
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
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  tooltip: 'Settings',
                  onPressed: _openBaseUrlDialog,
                  icon: Icon(Icons.settings),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isChecking)
                      SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: (_isConnected ?? false)
                              ? Colors.green
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    SizedBox(width: 8),
                    Text(
                      _isChecking
                          ? 'Checking connection...'
                          : (_isConnected ?? false)
                              ? 'Connected'
                              : 'Disconnected',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
