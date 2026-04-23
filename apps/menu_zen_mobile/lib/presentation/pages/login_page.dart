import 'package:data/config/base_url_config.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:domain/params/login_params.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/enums/bloc_status.dart';
import '../../core/injection/dependencies_injection.dart';
import '../../core/services/background_order_service.dart';
import '../bloc/auth/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool? _isConnected;
  bool _isChecking = false;
  String _currentBaseUrl = '';

  @override
  void initState() {
    super.initState();
    _currentBaseUrl = BaseUrlConfig.current;
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    if (_currentBaseUrl.isEmpty) {
      setState(() => _isConnected = false);
      return;
    }
    setState(() => _isChecking = true);
    final ok = await _ping(_currentBaseUrl);
    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _isConnected = ok;
    });
  }

  Future<bool> _ping(String baseUrl) async {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        validateStatus: (s) => s != null,
      ),
    );
    try {
      final res = await dio.get('/');
      return res.statusCode != null;
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
      builder: (ctx) => AlertDialog(
        title: const Text('URL du serveur'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'http://192.168.1.10:8000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final trimmed = result.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL invalide')));
      return;
    }
    await BaseUrlConfig.set(trimmed);
    // Keep the background-service isolate in sync — it reads this key directly.
    await SharedPreferencesAsync().setString(kWsBaseUrlKey, trimmed);
    if (getIt.isRegistered<Dio>(instanceName: 'withInterceptor')) {
      getIt<Dio>(instanceName: 'withInterceptor').options.baseUrl =
          BaseUrlConfig.current;
    }
    if (getIt.isRegistered<Dio>(instanceName: 'noInterceptor')) {
      getIt<Dio>(instanceName: 'noInterceptor').options.baseUrl =
          BaseUrlConfig.current;
    }
    if (!mounted) return;
    setState(() => _currentBaseUrl = BaseUrlConfig.current);
    await _checkConnection();
  }

  void _submit() {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final username = _formKey.currentState?.fields['username']?.value;
      final password = _formKey.currentState?.fields['password']?.value;
      context.read<AuthBloc>().add(
        AuthLoggedIn(LoginParams(username: username, password: password)),
      );
    }
  }

  GlobalKey<FormBuilderState> get formKey => _formKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => prev.authStatus != curr.authStatus,
            listener: (context, state) {
              if (state.authStatus == AuthStatus.authenticated) {
                context.read<AuthBloc>().add(const AuthUserGot());
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == BlocStatus.loaded &&
                  state.authStatus == AuthStatus.authenticated) {
                context.go('/main/commande');
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // ── Main content ───────────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // Title
                    Text(
                      'Click Menu\nZen',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Username
                            const _FieldLabel('IDENTIFIANT'),
                            const SizedBox(height: 8),
                            FormBuilderTextField(
                              name: 'username',
                              decoration: _inputDecoration(
                                hint: 'Votre ID employé',
                                icon: Icons.badge_outlined,
                              ),
                              validator: FormBuilderValidators.required(),
                            ),
                            const SizedBox(height: 20),

                            // Password
                            const _FieldLabel('MOT DE PASSE'),
                            const SizedBox(height: 8),
                            FormBuilderTextField(
                              name: 'password',
                              obscureText: _obscurePassword,
                              decoration: _inputDecoration(
                                hint: '• • • • • • • •',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              validator: FormBuilderValidators.required(),
                            ),
                            const SizedBox(height: 20),

                            // Inline error banner
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (prev, curr) =>
                                  prev.status != curr.status ||
                                  prev.errorMessage != curr.errorMessage,
                              builder: (context, state) {
                                if (state.status != BlocStatus.failed ||
                                    state.errorMessage == null) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ErrorBanner(
                                    message: state.errorMessage!,
                                  ),
                                );
                              },
                            ),

                            // Submit button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state.status == BlocStatus.loading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return ElevatedButton.icon(
                                  onPressed: _submit,
                                  icon: const Icon(Icons.login, size: 20),
                                  label: const Text(
                                    'SE CONNECTER',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(
                                      double.infinity,
                                      52,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: Text(
                        'SYSTÈME DE GESTION HÔTELLERIE V2.4',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == 2 ? primaryColor : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Settings button (hidden, double-tap to open) ───────────────
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onDoubleTap: _openBaseUrlDialog,
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(width: 48, height: 48),
                  ),
                ),
              ),
            ),

            // ── Connection indicator ───────────────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ConnectionIndicator(
                  isChecking: _isChecking,
                  isConnected: _isConnected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.black87,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

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

class _ConnectionIndicator extends StatelessWidget {
  final bool isChecking;
  final bool? isConnected;

  const _ConnectionIndicator({
    required this.isChecking,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isChecking)
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          )
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: (isConnected ?? false) ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          isChecking
              ? 'Vérification...'
              : (isConnected ?? false)
              ? 'Connecté'
              : 'Déconnecté',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
