import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/constants/constants.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:menu_zen_restaurant/features/datasources/models/menu_item_update_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_item_entity.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menu_item_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/auths/auth_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/languages/languages_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/menu_item/menu_item_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/loading_widget.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/logo.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/menu_item_card_widget.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/menu_item_dialog.dart';
import 'package:menu_zen_restaurant/core/animations/staggered_fade_in.dart';
import 'package:menu_zen_restaurant/core/animations/hover_scale_card.dart';

@RoutePage()
class MenuItemScreen extends StatefulWidget {
  const MenuItemScreen({super.key});

  @override
  State<MenuItemScreen> createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends State<MenuItemScreen> {
  late MenuItemController controller;

  @override
  void initState() {
    super.initState();
    controller = MenuItemController(context: context)..addFetchEvent();
  }

  void _showMenuItemDialog({MenuItemEntity? menuItem}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          MenuItemDialog(controller: controller, menuItem: menuItem),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: BlocListener<MenuItemBloc, MenuItemState>(
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
                child: BlocBuilder<MenuItemBloc, MenuItemState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.loading:
                        return const LoadingWidget();
                      case BlocStatus.loaded:
                        if (state.menuItems.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Aucun item de menu trouvé."),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _showMenuItemDialog(),
                                  child: const Text("Ajouter un item"),
                                ),
                              ],
                            ),
                          );
                        }
                        return BlocBuilder<LanguagesBloc, LanguagesState>(
                          builder: (context, langState) {
                            final selectedLang =
                                langState.selectedLanguage?.code ?? 'fr';
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final isPortrait = constraints.maxWidth < 600;
                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isPortrait ? 2 : 3,
                                        crossAxisSpacing: 24,
                                        mainAxisSpacing: 24,
                                        childAspectRatio: 1.15,
                                      ),
                                  itemCount: state.menuItems.length,
                                  itemBuilder: (context, index) {
                                    final menu = state.menuItems[index];
                                    return StaggeredFadeIn(
                                      index: index,
                                      child: HoverScaleCard(
                                        borderRadius: 24,
                                        child: MenuItemCardWidget(
                                          menuItem: menu,
                                          selectedLanguage: selectedLang,
                                          onEdit: () => _showMenuItemDialog(
                                            menuItem: menu,
                                          ),
                                          onStatusChanged: (bool value) {
                                            if (menu.active != value) {
                                              context.read<MenuItemBloc>().add(
                                                MenuItemUpdated(
                                                  MenuItemUpdateModel(
                                                    id: menu.id!,
                                                    active: value,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
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
                const Text(
                  "Gestion des items de menus",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Géré les items de menu de ton restaurant",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        );

        final actionsContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showMenuItemDialog(),
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
                backgroundColor: const Color(0xFF91C14F),
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
              backgroundColor: const Color(0xFF91C14F).withOpacity(0.1),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF91C14F),
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
              const Icon(Icons.check, color: Color(0xFF91C14F), size: 16),
            ],
          ),
        );
      },
    );
  }
}
