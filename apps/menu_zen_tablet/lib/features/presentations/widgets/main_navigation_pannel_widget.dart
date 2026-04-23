import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';
import 'logo.dart';
import 'nav_links.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../managers/auths/auth_bloc.dart';

class MainNavigationPannelWidget extends StatelessWidget {
  const MainNavigationPannelWidget({
    super.key,
    required this.currentRoute,
    required this.onHidePressed,
  });

  final String currentRoute;
  final VoidCallback onHidePressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final role = state.userRestaurant?.user.role;
        final user = state.userRestaurant?.user;

        final fullName =
            user?.fullName ??
            '${user?.firstname ?? ''} ${user?.lastname ?? ''}'.trim();
        final displayName = fullName.isNotEmpty
            ? fullName
            : (user?.username ?? '');
        final initials = displayName.isNotEmpty
            ? displayName
                  .split(' ')
                  .map((n) => n[0])
                  .take(2)
                  .join()
                  .toUpperCase()
            : '?';

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
                padding: EdgeInsets.symmetric(
                  horizontal: kspacing * 3,
                  vertical: kspacing * 3,
                ),
                child: _UserProfileTile(
                  initials: initials,
                  displayName: displayName,
                  onTap: () => context.router.push(const ProfileRoute()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserProfileTile extends StatefulWidget {
  const _UserProfileTile({
    required this.initials,
    required this.displayName,
    required this.onTap,
  });

  final String initials;
  final String displayName;
  final VoidCallback onTap;

  @override
  State<_UserProfileTile> createState() => _UserProfileTileState();
}

class _UserProfileTileState extends State<_UserProfileTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: kspacing * 2,
            vertical: kspacing * 2,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? primaryColor.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.initials,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: kspacing * 2),
              Expanded(
                child: Text(
                  widget.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: grey),
            ],
          ),
        ),
      ),
    );
  }
}
