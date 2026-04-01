import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../domains/entities/restaurant_entity.dart';
import '../../domains/entities/user_entity.dart';
import '../../domains/entities/user_restaurant_entity.dart';
import '../managers/auths/auth_bloc.dart';
import '../widgets/custom_container.dart';
import '../../datasources/models/restaurant_model.dart';
import '../../datasources/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/injection/dependencies_injection.dart';
import '../../domains/repositories/image_repository.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user info on entry
    context.read<AuthBloc>().add(AuthUserGot());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), elevation: 0),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == BlocStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.userRestaurant == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 64, color: grey),
                    SizedBox(height: kspacing * 2),
                    Text(
                      'Aucune information utilisateur disponible',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: grey),
                    ),
                    SizedBox(height: kspacing * 3),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthUserGot());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Rafraîchir'),
                    ),
                  ],
                ),
              );
            }
            final userRestaurant = state.userRestaurant!;
            return _ProfileView(
              userRestaurant: userRestaurant,
              onLogout: () {
                context.read<AuthBloc>().add(AuthLoggedOut());
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.userRestaurant, required this.onLogout});

  final UserRestaurantEntity userRestaurant;
  final VoidCallback onLogout;

  String _getRoleDisplayName(Role role) {
    switch (role) {
      case Role.superAdmin:
        return 'Super Administrateur';
      case Role.admin:
        return 'Administrateur';
      case Role.server:
        return 'Serveur';
      case Role.cashier:
        return 'Caissier';
      case Role.cook:
        return 'Cuisinier';
    }
  }

  Color _getRoleColor(Role role) {
    switch (role) {
      case Role.superAdmin:
        return Colors.purple.shade100;
      case Role.admin:
        return Colors.blue.shade100;
      case Role.server:
        return Colors.green.shade100;
      case Role.cashier:
        return Colors.orange.shade100;
      case Role.cook:
        return Colors.red.shade100;
    }
  }

  Color _getRoleTextColor(Role role) {
    switch (role) {
      case Role.superAdmin:
        return Colors.purple.shade800;
      case Role.admin:
        return Colors.blue.shade800;
      case Role.server:
        return Colors.green.shade800;
      case Role.cashier:
        return Colors.orange.shade800;
      case Role.cook:
        return Colors.red.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userRestaurant.user;
    final restaurant = userRestaurant.restaurant;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? kspacing * 4 : kspacing * 2),
      child: isTablet
          ? _buildTabletLayout(context, user, restaurant)
          : _buildMobileLayout(context, user, restaurant),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    UserEntity user,
    RestaurantEntity restaurant,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Info Card - Left Side
        Expanded(
          flex: 1,
          child: _UserInfoCard(
            user: user,
            getRoleDisplayName: _getRoleDisplayName,
            getRoleColor: _getRoleColor,
            getRoleTextColor: _getRoleTextColor,
            onLogout: onLogout,
          ),
        ),
        SizedBox(width: kspacing * 3),
        // Restaurant Info Card - Right Side
        Expanded(flex: 1, child: _RestaurantInfoCard(restaurant: restaurant)),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    UserEntity user,
    RestaurantEntity restaurant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _UserInfoCard(
          user: user,
          getRoleDisplayName: _getRoleDisplayName,
          getRoleColor: _getRoleColor,
          getRoleTextColor: _getRoleTextColor,
          onLogout: onLogout,
        ),
        SizedBox(height: kspacing * 3),
        _RestaurantInfoCard(restaurant: restaurant),
      ],
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({
    required this.user,
    required this.getRoleDisplayName,
    required this.getRoleColor,
    required this.getRoleTextColor,
    required this.onLogout,
  });

  final UserEntity user;
  final String Function(Role) getRoleDisplayName;
  final Color Function(Role) getRoleColor;
  final Color Function(Role) getRoleTextColor;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final actualFullName =
        user.fullName ??
        '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim();
    final displayName = actualFullName.isNotEmpty
        ? actualFullName
        : user.username;

    final initials = displayName.isNotEmpty
        ? displayName.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : user.username[0].toUpperCase();

    return CustomContainer(
      padding: EdgeInsets.all(kspacing * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar and Name
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: kspacing * 3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: kspacing),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: kspacing * 2,
                        vertical: kspacing,
                      ),
                      decoration: BoxDecoration(
                        color: getRoleColor(user.role ?? Role.admin),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getRoleDisplayName(user.role ?? Role.admin),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: getRoleTextColor(user.role ?? Role.admin),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: kspacing * 4),
          SizedBox(height: kspacing * 4),
          // User Details
          _SectionTitle(
            title: 'Informations Personnelles',
            onEdit: () {
              showDialog(
                context: context,
                builder: (_) => _EditUserDialog(
                  user: UserModel.fromEntity(user),
                  bloc: context.read<AuthBloc>(),
                ),
              );
            },
          ),
          SizedBox(height: kspacing * 2),
          _InfoTile(
            icon: Icons.person_outline,
            label: 'Nom d\'utilisateur',
            value: user.username,
          ),
          if (user.email != null)
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email!,
            ),
          if (user.phone != null)
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: user.phone!,
            ),
          SizedBox(height: kspacing * 4),
          // Action Button
          ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: kspacing * 2),
              minimumSize: const Size(double.infinity, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantInfoCard extends StatelessWidget {
  const _RestaurantInfoCard({required this.restaurant});

  final RestaurantEntity restaurant;

  Future<void> _updateLogo(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Appareil photo"),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Galerie"),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final file = await picker.pickImage(source: source);
      if (file != null) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        try {
          final imageRepo = getIt<ImageRepository>();
          final result = await imageRepo.uploadImage(file);
          
          if (!context.mounted) return;
          Navigator.pop(context); // close loading dialog
          
          if (result.isSuccess) {
            final logoUrl = result.getSuccess;
            final updatedRestaurant = RestaurantModel.fromEntity(restaurant).copyWith(logo: logoUrl);
            context.read<AuthBloc>().add(AuthRestaurantUpdated(updatedRestaurant));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erreur lors de l\'upload de l\'image')),
            );
          }
        } catch (e) {
          if (!context.mounted) return;
          Navigator.pop(context); // close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur inattendue')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: EdgeInsets.all(kspacing * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Header with Logo
          Row(
            children: [
              GestureDetector(
                onTap: () => _updateLogo(context),
                child: Stack(
                  children: [
                    if (restaurant.logo != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: restaurant.logo!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.restaurant, size: 40),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.restaurant, size: 40),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.restaurant, size: 40, color: primaryColor),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(Icons.edit, size: 16, color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: kspacing * 3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (restaurant.type != null) ...[
                      SizedBox(height: kspacing),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: kspacing * 2,
                          vertical: kspacing,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          restaurant.type!,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Cover Image if available
          if (restaurant.cover != null) ...[
            SizedBox(height: kspacing * 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: restaurant.cover!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            ),
          ],
          SizedBox(height: kspacing * 4),
          SizedBox(height: kspacing * 4),
          // Restaurant Details
          _SectionTitle(
            title: 'Informations du Restaurant',
            onEdit: () {
              showDialog(
                context: context,
                builder: (_) => _EditRestaurantDialog(
                  restaurant: RestaurantModel.fromEntity(restaurant),
                  bloc: context.read<AuthBloc>(),
                ),
              );
            },
          ),
          SizedBox(height: kspacing * 2),
          if (restaurant.description != null)
            _InfoTile(
              icon: Icons.description_outlined,
              label: 'Description',
              value: restaurant.description!,
              maxLines: 3,
            ),
          _InfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: restaurant.email,
          ),
          _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: restaurant.phone,
          ),
          _InfoTile(
            icon: Icons.location_city_outlined,
            label: 'Ville',
            value: restaurant.city,
          ),
          if (restaurant.lat != null && restaurant.long != null) ...[
            SizedBox(height: kspacing * 2),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: grey),
                SizedBox(width: kspacing),
                Expanded(
                  child: Text(
                    '${restaurant.lat!.toStringAsFixed(6)}, ${restaurant.long!.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
          if (restaurant.languages != null &&
              restaurant.languages!.isNotEmpty) ...[
            SizedBox(height: kspacing * 2),
            Wrap(
              spacing: kspacing,
              runSpacing: kspacing,
              children: [
                Icon(Icons.language_outlined, size: 20, color: grey),
                ...restaurant.languages!.map(
                  (lang) => Chip(
                    label: Text(lang),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ],
          if (restaurant.socialMedia != null &&
              restaurant.socialMedia!.isNotEmpty) ...[
            SizedBox(height: kspacing * 3),
            _SectionTitle(title: 'Réseaux Sociaux'),
            SizedBox(height: kspacing * 2),
            Wrap(
              spacing: kspacing,
              runSpacing: kspacing,
              children: restaurant.socialMedia!
                  .map(
                    (social) => Chip(
                      avatar: const Icon(Icons.link, size: 16),
                      label: Text(social),
                      backgroundColor: Colors.purple.shade50,
                      labelStyle: TextStyle(color: Colors.purple.shade900),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.onEdit});

  final String title;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: kspacing * 2),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (onEdit != null) ...[
          const Spacer(),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: primaryColor,
          ),
        ],
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: kspacing * 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: grey),
          SizedBox(width: kspacing * 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: kspacing / 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({required this.user, required this.bloc});

  final UserModel user;
  final AuthBloc bloc;

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late TextEditingController _firstnameCtrl;
  late TextEditingController _lastnameCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _firstnameCtrl = TextEditingController(text: widget.user.firstname);
    _lastnameCtrl = TextEditingController(text: widget.user.lastname);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _firstnameCtrl.dispose();
    _lastnameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le profil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _firstnameCtrl,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            SizedBox(height: kspacing),
            TextField(
              controller: _lastnameCtrl,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            SizedBox(height: kspacing),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedUser = widget.user.copyWith(
              firstname: _firstnameCtrl.text,
              lastname: _lastnameCtrl.text,
              phone: _phoneCtrl.text,
            );
            widget.bloc.add(AuthUserUpdated(updatedUser));
            Navigator.pop(context);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _EditRestaurantDialog extends StatefulWidget {
  const _EditRestaurantDialog({required this.restaurant, required this.bloc});

  final RestaurantModel restaurant;
  final AuthBloc bloc;

  @override
  State<_EditRestaurantDialog> createState() => _EditRestaurantDialogState();
}

class _EditRestaurantDialogState extends State<_EditRestaurantDialog> {
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.restaurant.phone);
    _emailCtrl = TextEditingController(text: widget.restaurant.email);
    _descriptionCtrl = TextEditingController(
      text: widget.restaurant.description,
    );
    _cityCtrl = TextEditingController(text: widget.restaurant.city);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descriptionCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le restaurant'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Téléphone du restaurant',
              ),
            ),
            SizedBox(height: kspacing),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email du restaurant',
              ),
            ),
            SizedBox(height: kspacing),
            TextField(
              controller: _cityCtrl,
              decoration: const InputDecoration(labelText: 'Ville'),
            ),
            SizedBox(height: kspacing),
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedRestaurant = widget.restaurant.copyWith(
              phone: _phoneCtrl.text,
              email: _emailCtrl.text,
              city: _cityCtrl.text,
              description: _descriptionCtrl.text,
            );
            widget.bloc.add(AuthRestaurantUpdated(updatedRestaurant));
            Navigator.pop(context);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
