import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/constants/constants.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:menu_zen_restaurant/features/domains/entities/category_entity.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/category_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/auths/auth_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/categories/categories_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/languages/languages_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/category_card.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/category_dialog.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/loading_widget.dart';

@RoutePage()
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoriesController controller;

  @override
  void initState() {
    super.initState();
    controller = CategoriesController(context: context)..addFetchEvent();
  }

  void _showCategoryDialog({CategoryEntity? category}) {
    if (category != null) {
      controller.showField(true, entity: category);
    } else {
      controller.resetThemeColor;
      controller.showField(true);
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          CategoryDialog(controller: controller, category: category),
    ).then((_) {
      // Potentially reset fields if canceled
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F8E9,
      ), // Light green background from mockup
      body: BlocListener<CategoriesBloc, CategoriesState>(
        listenWhen: (previous, current) =>
            previous.editStatus != current.editStatus,
        listener: (context, state) {
          if (state.editStatus == BlocStatus.loaded) {
            controller.addFetchEvent();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(kspacing * 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: kspacing * 6),
              Expanded(
                child: BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.loading:
                        return const LoadingWidget();
                      case BlocStatus.loaded:
                        if (state.categories.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Aucune catégorie trouvée."),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _showCategoryDialog(),
                                  child: const Text("Ajouter une catégorie"),
                                ),
                              ],
                            ),
                          );
                        }
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 1.5,
                              ),
                          itemCount: state.categories.length,
                          itemBuilder: (context, index) {
                            final category = state.categories[index];
                            return CategoryCard(
                              category: category,
                              onEdit: () =>
                                  _showCategoryDialog(category: category),
                            );
                          },
                        );
                      case BlocStatus.failed:
                        return const Center(
                          child: Text("Erreur de chargement"),
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.userRestaurant?.user;
        final displayName = user != null
            ? (user.fullName ??
                  '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim())
            : (user?.username ?? '');

        final initials = displayName.isNotEmpty
            ? displayName
                  .split(' ')
                  .where((e) => e.isNotEmpty)
                  .map((n) => n[0])
                  .take(2)
                  .join()
                  .toUpperCase()
            : 'U';

        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gestion des catégories",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Gérer les catégories de tes plats",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showCategoryDialog(),
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                "AJOUTER",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 20,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Text(
                initials,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildIconButton(Icons.search_outlined),
            const SizedBox(width: 12),
            _buildLanguageSelector(),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: Colors.grey, size: 22),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return BlocBuilder<LanguagesBloc, LanguagesState>(
      builder: (context, state) {
        final langName = state.selectedLanguage?.name ?? 'French';
        final langFlag = state.selectedLanguage?.code == 'en' ? '🇺🇸' : '🇫🇷';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(langFlag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                langName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.check, color: primaryColor, size: 16),
            ],
          ),
        );
      },
    );
  }
}
