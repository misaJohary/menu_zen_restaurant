import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';

import '../managers/auths/auth_bloc.dart';
import '../managers/languages/languages_bloc.dart';
import 'logo.dart';

/// Shared header widget used across management screens.
///
/// Shows the restaurant logo, a title/description, a circular add button,
/// an optional search field, and an optional language-flag button.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.description,
    required this.onAddPressed,
    this.searchController,
    this.showLanguage = true,
  });

  final String title;
  final String description;
  final VoidCallback onAddPressed;

  /// When non-null a search [TextField] is rendered in the actions row.
  final TextEditingController? searchController;

  /// Whether to show the language-flag button. Set to false for screens
  /// whose content is not multilingual (e.g. kitchens, users).
  final bool showLanguage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isPortrait = MediaQuery.sizeOf(context).width < 900;

        final titleContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.userRestaurant != null)
              Logo(imageUrl: state.userRestaurant!.restaurant.logo)
            else
              const SizedBox(height: 40),
            const SizedBox(width: kspacing * 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        );

        final actionsContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF91C14F),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
            if (searchController != null) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kspacing * 2),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF999999),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Rechercher',
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                  ),
                ),
              ),
            ],
            if (showLanguage) ...[
              const SizedBox(width: 12),
              const _LanguageFlagButton(),
            ],
          ],
        );

        if (isPortrait) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleContent,
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: actionsContent,
              ),
            ],
          );
        }

        return Row(children: [titleContent, const Spacer(), actionsContent]);
      },
    );
  }
}

class _LanguageFlagButton extends StatelessWidget {
  const _LanguageFlagButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguagesBloc, LanguagesState>(
      builder: (context, state) {
        final langFlag = state.selectedLanguage?.code == 'en' ? '🇺🇸' : '🇫🇷';
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(langFlag, style: const TextStyle(fontSize: 20)),
        );
      },
    );
  }
}
