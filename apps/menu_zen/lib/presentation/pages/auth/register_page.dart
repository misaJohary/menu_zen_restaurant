import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/navigation/route_paths.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        email: _emailCtl.text.trim(),
        password: _passwordCtl.text,
        fullName: _fullNameCtl.text.trim().isEmpty
            ? null
            : _fullNameCtl.text.trim(),
        phone: _phoneCtl.text.trim().isEmpty ? null : _phoneCtl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // Pop back to the page that launched the auth flow.
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.profile);
              }
            } else if (state is AuthUnauthenticated &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
            }
          },
          builder: (context, state) {
            final submitting = state is AuthSubmitting;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.authCreateAccount, style: textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.authCreateAccountSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _fullNameCtl,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.authFullName,
                        prefixIcon: const Icon(PhosphorIconsRegular.user),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _emailCtl,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.authEmail,
                        prefixIcon: const Icon(PhosphorIconsRegular.envelope),
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return l10n.authValidationEmail;
                        if (!value.contains('@') || !value.contains('.')) {
                          return l10n.authValidationEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _phoneCtl,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.authPhoneOptional,
                        prefixIcon: const Icon(PhosphorIconsRegular.phone),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _passwordCtl,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.authPassword,
                        helperText: l10n.authPasswordHelper,
                        prefixIcon: const Icon(PhosphorIconsRegular.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? PhosphorIconsRegular.eye
                                : PhosphorIconsRegular.eyeSlash,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.authValidationPasswordRequired;
                        }
                        if (v.length < 8) {
                          return l10n.authValidationPasswordLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.authCreateAccount),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
