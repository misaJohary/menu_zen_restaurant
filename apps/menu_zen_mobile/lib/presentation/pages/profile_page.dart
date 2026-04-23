import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../bloc/auth/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.authStatus != curr.authStatus,
      listener: (context, state) {
        if (state.authStatus == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Profil',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.userRestaurant?.user;
            final restaurant = state.userRestaurant?.restaurant;
            final initials = user != null && user.username.isNotEmpty
                ? user.username[0].toUpperCase()
                : '?';
            final displayName =
                user?.fullName ??
                [user?.firstname, user?.lastname]
                    .where((s) => s != null && s.isNotEmpty)
                    .join(' ')
                    .trim()
                    .let((s) => s.isNotEmpty ? s : null) ??
                user?.username ??
                '—';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Avatar
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: primaryColor,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display name
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user?.roleName != null)
                    Text(
                      user!.roleName!,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 28),

                  // Info card
                  _InfoCard(
                    items: [
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Identifiant',
                        value: user?.username ?? '—',
                      ),
                      if (user?.email != null && user!.email!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email!,
                        ),
                      if (user?.phone != null && user!.phone!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Téléphone',
                          value: user.phone!,
                        ),
                      // if (user?.roleName != null &&
                      //     user!.roleName!.isNotEmpty)
                      //   _InfoRow(
                      //     icon: Icons.work_outline,
                      //     label: 'Rôle',
                      //     value: user.roleName!,
                      //   ),
                      if (restaurant != null)
                        _InfoRow(
                          icon: Icons.restaurant_outlined,
                          label: 'Restaurant',
                          value: restaurant.name,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.read<AuthBloc>().add(AuthLoggedOut()),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'SE DÉCONNECTER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(height: 1, indent: 56, color: Colors.grey.shade100),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension _LetExtension<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}
