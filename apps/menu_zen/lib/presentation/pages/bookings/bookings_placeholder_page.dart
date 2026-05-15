import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BookingsPlaceholderPage extends StatelessWidget {
  const BookingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: PhosphorIconsDuotone.bookmarkSimple,
          title: 'Bookings coming soon',
          body: 'Your reservations and orders will live here.',
        ),
      ),
    );
  }
}
