import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../domains/entities/language_entity.dart';
import '../../controllers/make_order_controller.dart';
import '../../managers/auths/auth_bloc.dart';
import '../../managers/languages/languages_bloc.dart';
import '../custom_container.dart';

class OrderHeader extends StatefulWidget {
  const OrderHeader({super.key, required this.controller});

  final MakeOrderController controller;

  @override
  State<OrderHeader> createState() => _OrderHeaderState();
}

class _OrderHeaderState extends State<OrderHeader> {
  @override
  void initState() {
    super.initState();
    // Fetch languages when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LanguagesBloc>().add(LanguagesFetched());
    });
  }

  void _onLanguageSelected(LanguageEntity language) {
    context.read<LanguagesBloc>().add(LanguageSelected(language));
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      height: 140,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) =>
                    previous.userRestaurant != current.userRestaurant,
                builder: (context, state) => Text(
                  state.userRestaurant?.restaurant?.name ?? 'Click Menu Zen',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: widget.controller.menuSearchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => widget.controller.submitOrderMenuSearch(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kspacing * 2),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF999999),
                    ),
                    fillColor: const Color(0xFFF6F6F6),
                    filled: true,
                    hintText: 'Rechercher',
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: kspacing),
          // Language selection
          BlocBuilder<LanguagesBloc, LanguagesState>(
            builder: (context, state) {
              if (state.languages.isEmpty) {
                return SizedBox.shrink();
              }

              return SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.languages.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(width: kspacing),
                  itemBuilder: (context, index) {
                    final language = state.languages[index];
                    final isSelected =
                        state.selectedLanguage?.code == language.code;

                    return ChoiceChip(
                      label: Text(language.name),
                      selected: isSelected,
                      onSelected: (_) => _onLanguageSelected(language),
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.3),
                      backgroundColor: const Color(0xFFF6F6F6),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : const Color(0xFF666666),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
