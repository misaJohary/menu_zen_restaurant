import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/login_controller.dart';

import 'package:data/config/base_url_config.dart';
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

/// Provides a gentle floating animation for decorative
/// food images on the login screen.
class _FloatingImage extends StatefulWidget {
  const _FloatingImage({
    required this.imagePath,
    required this.width,
    this.floatDistance = 10.0,
    this.duration = const Duration(seconds: 3),
  });

  final String imagePath;
  final double width;
  final double floatDistance;
  final Duration duration;

  @override
  State<_FloatingImage> createState() => _FloatingImageState();
}

class _FloatingImageState extends State<_FloatingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _float = Tween<double>(
      begin: -widget.floatDistance,
      end: widget.floatDistance,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _float,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: child,
        );
      },
      child: Image.asset(widget.imagePath, width: widget.width),
    );
  }
}

/// Provides a natural, erratic flying/floating animation for leaves.
class _FlyingLeaf extends StatefulWidget {
  const _FlyingLeaf({
    required this.imagePath,
    required this.width,
    this.duration = const Duration(seconds: 8),
    this.xAmplitude = 20.0,
    this.yAmplitude = 15.0,
    this.rotationAmplitude = 0.3,
    this.initialAngle = 0.0,
    this.phaseOffset = 0.0,
  });

  final String imagePath;
  final double width;
  final Duration duration;
  final double xAmplitude;
  final double yAmplitude;
  final double rotationAmplitude;
  final double initialAngle;
  final double phaseOffset;

  @override
  State<_FlyingLeaf> createState() => _FlyingLeafState();
}

class _FlyingLeafState extends State<_FlyingLeaf>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi + widget.phaseOffset;
        final dx = math.sin(t) * widget.xAmplitude;
        final dy = math.cos(t * 1.5) * widget.yAmplitude;
        final rotation =
            widget.initialAngle + math.sin(t * 0.8) * widget.rotationAmplitude;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(angle: rotation, child: child),
        );
      },
      child: Image.asset(widget.imagePath, width: widget.width),
    );
  }
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late LoginController controller;
  bool? _isConnected;
  bool _isChecking = false;
  String _currentBaseUrl = '';
  bool _obscurePassword = true;

  late final AnimationController _formSlideController;
  late final Animation<Offset> _formSlide;
  late final Animation<double> _formOpacity;

  late final AnimationController _foodScaleController;
  late final Animation<double> _foodScale;
  late final Animation<double> _foodOpacity;

  @override
  void initState() {
    super.initState();
    controller = LoginController(context);
    _currentBaseUrl = BaseUrlConfig.current;
    _checkConnection();

    _formSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _formSlideController,
            curve: Curves.easeOutCubic,
          ),
        );
    _formOpacity = CurvedAnimation(
      parent: _formSlideController,
      curve: Curves.easeOut,
    );

    _foodScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _foodScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _foodScaleController, curve: Curves.elasticOut),
    );
    _foodOpacity = CurvedAnimation(
      parent: _foodScaleController,
      curve: Curves.easeOut,
    );

    _foodScaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formSlideController.forward();
    });
  }

  @override
  void dispose() {
    _formSlideController.dispose();
    _foodScaleController.dispose();
    super.dispose();
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
                              FadeTransition(
                                opacity: _foodOpacity,
                                child: ScaleTransition(
                                  scale: _foodScale,
                                  child: Image.asset(
                                    'assets/images/background_green.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
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
                                        child: _FloatingImage(
                                          imagePath:
                                              'assets/images/riz_au_poulet.png',
                                          width: 300,
                                          floatDistance: 8,
                                          duration: const Duration(
                                            milliseconds: 3200,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 200,
                                        left: -80,
                                        child: _FloatingImage(
                                          imagePath: 'assets/images/plat_2.png',
                                          width: 330,
                                          floatDistance: 12,
                                          duration: const Duration(
                                            milliseconds: 2800,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 30,
                                        right: -10,
                                        child: _FloatingImage(
                                          imagePath:
                                              'assets/images/salade_de_legume.png',
                                          width: 180,
                                          floatDistance: 6,
                                          duration: const Duration(
                                            milliseconds: 3600,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: -70,
                                        child: _FlyingLeaf(
                                          imagePath: 'assets/images/leaf_1.png',
                                          width: 70,
                                          initialAngle: 0.0,
                                          phaseOffset: 1.0,
                                          xAmplitude: 25.0,
                                          yAmplitude: 20.0,
                                          duration: const Duration(seconds: 9),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -80,
                                        right: -70,
                                        child: _FlyingLeaf(
                                          imagePath: 'assets/images/leaf_1.png',
                                          width: 70,
                                          initialAngle: math.pi / 4,
                                          phaseOffset: 3.5,
                                          xAmplitude: 15.0,
                                          yAmplitude: 25.0,
                                          duration: const Duration(seconds: 11),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        left: -70,
                                        child: _FlyingLeaf(
                                          imagePath: 'assets/images/leaf_1.png',
                                          width: 40,
                                          initialAngle: math.pi / 6,
                                          phaseOffset: 2.0,
                                          xAmplitude: 30.0,
                                          yAmplitude: 15.0,
                                          rotationAmplitude: 0.5,
                                          duration: const Duration(seconds: 12),
                                        ),
                                      ),
                                      Positioned(
                                        top: -50,
                                        right: -80,
                                        child: _FlyingLeaf(
                                          imagePath: 'assets/images/leaf_1.png',
                                          width: 40,
                                          initialAngle: math.pi / 6,
                                          phaseOffset: 0.5,
                                          xAmplitude: 20.0,
                                          yAmplitude: 30.0,
                                          rotationAmplitude: 0.4,
                                          duration: const Duration(seconds: 10),
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
                        child: SlideTransition(
                          position: _formSlide,
                          child: FadeTransition(
                            opacity: _formOpacity,
                            child: Center(
                              child: SizedBox(
                                width: 380,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      validator:
                                          FormBuilderValidators.required(),
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
                                    SizedBox(height: 16),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      buildWhen: (prev, curr) =>
                                          prev.status != curr.status ||
                                          prev.errorMessage !=
                                              curr.errorMessage,
                                      builder: (context, state) {
                                        if (state.status != BlocStatus.failed ||
                                            state.errorMessage == null) {
                                          return SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: _LoginErrorBanner(
                                            message: state.errorMessage!,
                                          ),
                                        );
                                      },
                                    ),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        if (state.status ==
                                            BlocStatus.loading) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        return ElevatedButton(
                                          onPressed: controller.validate,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            minimumSize: Size(
                                              double.infinity,
                                              50,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              decoration:
                                                  TextDecoration.underline,
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

class _LoginErrorBanner extends StatelessWidget {
  const _LoginErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
