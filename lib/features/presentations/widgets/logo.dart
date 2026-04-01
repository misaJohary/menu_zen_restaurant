import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/constants.dart';
import '../managers/auths/auth_bloc.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.isBig = false, this.imageUrl});

  final bool? isBig;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        height: isBig! ? 70 : 40,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => _buildDefaultLogo(context),
      );
    }
    return _buildDefaultLogo(context);
  }

  Widget _buildDefaultLogo(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final fallbackName = authState.userRestaurant?.restaurant.name;

    if (fallbackName != null && fallbackName.trim().isNotEmpty) {
      return Container(
        width: isBig! ? 70 : 40,
        height: isBig! ? 70 : 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primaryColor, const Color(0xFF9181F4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          fallbackName.trim()[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isBig! ? 36 : 22,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Click Menu',
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: isBig! ? 24 : 14,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ZEN ',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: isBig! ? 40 : 22,
              ),
            ),
            Image.asset('assets/images/leaf.png', width: isBig! ? 40 : 22),
          ],
        ),
      ],
    );
  }
}
