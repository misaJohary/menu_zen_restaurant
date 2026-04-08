import 'package:flutter/material.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/main_controller.dart';

import '../../../core/constants/constants.dart';
import 'logo.dart';
import 'nav_links.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../managers/auths/auth_bloc.dart';

class MainNavigationPannelWidget extends StatelessWidget {
  const MainNavigationPannelWidget({
    super.key,
    required this.currentRoute,
    required this.controller,
    required this.onHidePressed,
  });

  final String currentRoute;
  final MainController controller;
  final VoidCallback onHidePressed;

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      controller.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final role = state.userRestaurant?.user.role;
        return Container(
          width: 280,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: kspacing * 3,
                  vertical: kspacing * 5,
                ),
                child: const Logo(),
              ),
              const SizedBox(height: kspacing * 2),
              ...navLinks(currentRoute, role),
              const Spacer(),
              Padding(
                padding: EdgeInsets.all(kspacing * 3),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _confirmLogout(context);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'DÉCONNEXION',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: kspacing * 2),
            ],
          ),
        );
      },
    );
  }
}
