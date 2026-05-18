import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/entities/customer_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/navigation/route_paths.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/locale/locale_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => switch (state) {
            AuthInitial() || AuthSubmitting() => const Center(
              child: CircularProgressIndicator(),
            ),
            AuthUnauthenticated() => const _SignedOutView(),
            AuthAuthenticated(:final customer) => _ProfileView(
              customer: customer,
            ),
          },
        ),
      ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      children: [
        EmptyState(
          icon: PhosphorIconsDuotone.user,
          title: l10n.profileSignInTitle,
          body: l10n.profileSignInBody,
          actionLabel: l10n.profileSignInAction,
          onAction: () => context.push(RoutePaths.authLogin),
        ),
        const SizedBox(height: AppSpacing.xl),
        _LanguageTile(),
      ],
    );
  }
}

class _ProfileView extends StatelessWidget {
  final CustomerEntity customer;

  const _ProfileView({required this.customer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      children: [
        Row(
          children: [
            _Avatar(customer: customer),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName?.isNotEmpty == true
                        ? customer.fullName!
                        : customer.email,
                    style: textTheme.titleLarge,
                  ),
                  if (customer.fullName?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      customer.email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  if (customer.phone?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      customer.phone!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionTile(
          icon: PhosphorIconsRegular.heart,
          label: l10n.profileFavorites,
          subtitle: l10n.profileFavoritesSubtitle,
          onTap: () => context.push(RoutePaths.favorites),
        ),
        _SectionTile(
          icon: PhosphorIconsRegular.bookmarkSimple,
          label: l10n.profileReservationsOrders,
          subtitle: l10n.commonComingSoon,
          enabled: false,
        ),
        _LanguageTile(),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context),
          icon: const Icon(PhosphorIconsRegular.signOut),
          label: Text(l10n.profileSignOut),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileSignOutDialogTitle),
        content: Text(l10n.profileSignOutDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(AuthSignedOut());
    }
  }
}

class _Avatar extends StatelessWidget {
  final CustomerEntity customer;

  const _Avatar({required this.customer});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = _initialsFor(customer);
    final url = customer.avatar;
    return ClipOval(
      child: SizedBox(
        width: 72,
        height: 72,
        child: url != null && url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    _initialsAvatar(initials, scheme),
              )
            : _initialsAvatar(initials, scheme),
      ),
    );
  }

  Widget _initialsAvatar(String initials, ColorScheme scheme) {
    return Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initialsFor(CustomerEntity c) {
    final name = (c.fullName?.isNotEmpty == true ? c.fullName! : c.email)
        .trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+')).take(2);
    return parts
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
        .join();
  }
}

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const _SectionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, selected) {
        final activeCode = context.read<LocaleCubit>().resolve().languageCode;
        return _SectionTile(
          icon: PhosphorIconsRegular.translate,
          label: l10n.profileLanguage,
          subtitle: _languageNameFor(l10n, activeCode),
          onTap: () => _openLanguageSheet(context),
        );
      },
    );
  }

  Future<void> _openLanguageSheet(BuildContext context) async {
    final cubit = context.read<LocaleCubit>();
    final picked = await showModalBottomSheet<_LanguageChoice>(
      context: context,
      showDragHandle: true,
      builder: (_) => _LanguageSheet(active: cubit.state),
    );
    if (picked == null) return;
    await cubit.setLocale(picked.locale);
  }
}

class _LanguageSheet extends StatelessWidget {
  final Locale? active;
  const _LanguageSheet({required this.active});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.languageSheetTitle, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.m),
            RadioGroup<String>(
              groupValue: active?.languageCode,
              onChanged: (code) {
                if (code == null) return;
                Navigator.of(context).pop(_LanguageChoice(Locale(code)));
              },
              child: Column(
                children: [
                  for (final locale in LocaleCubit.supported)
                    RadioListTile<String>(
                      value: locale.languageCode,
                      title: Text(_languageNameFor(l10n, locale.languageCode)),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChoice {
  final Locale locale;
  const _LanguageChoice(this.locale);
}

String _languageNameFor(AppLocalizations l10n, String code) {
  switch (code) {
    case 'en':
      return l10n.languageEnglish;
    case 'fr':
      return l10n.languageFrench;
    case 'mg':
      return l10n.languageMalagasy;
    default:
      return code.toUpperCase();
  }
}
