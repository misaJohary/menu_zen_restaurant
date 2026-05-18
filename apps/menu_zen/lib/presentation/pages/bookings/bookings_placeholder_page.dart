import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../l10n/generated/app_localizations.dart';

class BookingsPlaceholderPage extends StatelessWidget {
  const BookingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: PhosphorIconsDuotone.bookmarkSimple,
          title: l10n.bookingsPlaceholderTitle,
          body: l10n.bookingsPlaceholderBody,
        ),
      ),
    );
  }
}
