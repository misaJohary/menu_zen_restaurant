import 'dart:math' as math;

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
  bool _obscurePassword = true;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid URL.')));
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
      backgroundColor: Colors.white,
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
                      } else if (state.authStatus ==
                          AuthStatus.unauthenticated) {
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
                      // Left side with images
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/background_green.png',
                                fit: BoxFit.contain,
                              ),

                              Center(
                                child: SizedBox(
                                  width: 400,
                                  height: 600,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: -90,
                                        child: Image.asset(
                                          'assets/images/riz_au_poulet.png',
                                          width: 300,
                                        ),
                                      ),
                                      Positioned(
                                        top: 200,
                                        left: -80,
                                        child: Image.asset(
                                          'assets/images/plat_2.png',
                                          width: 330,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 30,
                                        right: -10,
                                        child: Image.asset(
                                          'assets/images/salade_de_legume.png',
                                          width: 180,
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: -70,
                                        child: Image.asset(
                                          'assets/images/leaf_1.png',
                                          width: 70,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -80,
                                        right: -70,
                                        child: Image.asset(
                                          'assets/images/leaf_1.png',
                                          width: 70,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        left: -70,
                                        child: Transform.rotate(
                                          angle: math.pi / 6,
                                          child: Image.asset(
                                            'assets/images/leaf_1.png',
                                            width: 40,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -50,
                                        right: -80,
                                        child: Transform.rotate(
                                          angle: math.pi / 6,
                                          child: Image.asset(
                                            'assets/images/leaf_1.png',
                                            width: 40,
                                          ),
                                        ),
                                      ),
                                      // Positioned(top: 80, right: 120, child: Image.asset('assets/images/leaf_2.png', width: 30)),
                                      // Positioned(bottom: 220, left: 100, child: Image.asset('assets/images/leaf_3.png', width: 40)),
                                      // Positioned(bottom: -30, right: -10, child: Image.asset('assets/images/leaf_4.png', width: 50)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right side with form
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: 380,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Logo(isBig: true),
                                ),
                                SizedBox(height: 60),
                                Text(
                                  'Nom d\'utilisateur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                FormBuilderTextField(
                                  name: 'username',
                                  decoration: InputDecoration(
                                    hintText: 'rakoto.nomenjanahary',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                  ]),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Mot de passe',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                FormBuilderTextField(
                                  name: 'password',
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: '* * * * * * *',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: FormBuilderValidators.required(),
                                ),
                                SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    if (state.status == BlocStatus.loading) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return ElevatedButton(
                                      onPressed: controller.validate,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        minimumSize: Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'SE CONNECTER',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Vous n'avez pas encore de compte ? ",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        context.router.push(
                                          RegistrationRoute(),
                                        );
                                      },
                                      child: Text(
                                        "S'inscrire",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                          decorationColor: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
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
