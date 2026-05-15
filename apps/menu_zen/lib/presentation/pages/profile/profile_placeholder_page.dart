import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: PhosphorIconsDuotone.user,
          title: 'Profile coming soon',
          body: 'Account, favorites, and preferences will live here.',
        ),
      ),
    );
  }
}
