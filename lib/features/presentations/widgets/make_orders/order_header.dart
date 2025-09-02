import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../managers/auths/auth_bloc.dart';
import '../custom_container.dart';

class OrderHeader extends StatelessWidget {
  const OrderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current)=> previous.userRestaurant != current.userRestaurant,
            builder: (context, state) => Text(
              state.userRestaurant?.restaurant.name ?? 'Click Menu Zen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kspacing * 2),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                fillColor: const Color(0xFFF6F6F6),
                filled: true,
                hintText: 'Rechercher',
                hintStyle: const TextStyle(color: Color(0xFF999999)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
