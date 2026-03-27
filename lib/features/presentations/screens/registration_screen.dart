import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:menu_zen_restaurant/core/services/photon_geocoding_service.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/user_registration_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/logo.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../controllers/restaurant_more_info_controller.dart';
import '../controllers/restaurant_registration_controller.dart';
import 'package:menu_zen_restaurant/core/navigation/app_router.gr.dart'
    as app_router;

import '../managers/auths/auth_bloc.dart';
import '../managers/languages/languages_bloc.dart';
import '../managers/restaurant/restaurant_bloc.dart';

@RoutePage()
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 4, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LanguagesBloc>().add(LanguagesFetched());
  }

  Widget _buildStepperItem({
    required String title,
    required bool isActive,
    required String number,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? primaryColor : Colors.grey.shade300,
                ),
                child: Center(
                  child: isActive
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(number,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(
                      painter: DashedLinePainter(
                          color: isActive ? primaryColor : Colors.grey.shade300),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive ? primaryColor : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (!isLast) const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.pageView(
      routes: [
        app_router.RestaurantForm(),
        app_router.RestaurantCustomizeForm(),
        app_router.UserForm(),
      ],
      builder: (context, child, _) {
        final tabsRouter = AutoTabsRouter.of(context);
        return MultiBlocListener(
          listeners: [
            BlocListener<RestaurantBloc, RestaurantState>(
              listenWhen: (previous, current) =>
                  previous.navigationNonce != current.navigationNonce,
              listener: (context, state) {
                final index = tabsRouter.activeIndex;
                if (index == 0 && state.restaurantFilled) {
                  tabsRouter.setActiveIndex(1);
                } else if (index == 1 && state.restaurantMoreInfoFilled) {
                  tabsRouter.setActiveIndex(2);
                } else if (index == 2 && state.userFilled) {
                  context.read<RestaurantBloc>().add(const RestaurantCreated());
                }
              },
            ),

            BlocListener<RestaurantBloc, RestaurantState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                if (state.status == BlocStatus.loaded) {
                  context.read<AuthBloc>().add(AuthUserGot());
                }
              },
            ),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (previous, current) {
                return previous.status != current.status;
              },
              listener: (context, state) {
                if (state.status == BlocStatus.loaded) {
                  context.router.reevaluateGuards();
                } else if (state.status == BlocStatus.failed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la connexion')),
                  );
                }
              },
            ),
          ],
          child: Scaffold(
            backgroundColor: const Color(0xFFF2F8E8),
            body: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Logo(isBig: false),
                      const SizedBox(height: 60),
                      const Text('Créer un compte',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 60),
                      _buildStepperItem(
                        title: 'Informations restaurant',
                        isActive: tabsRouter.activeIndex >= 0,
                        number: '01',
                        isLast: false,
                      ),
                      _buildStepperItem(
                        title: 'Catégories & Langues',
                        isActive: tabsRouter.activeIndex >= 1,
                        number: 'O2',
                        isLast: false,
                      ),
                      _buildStepperItem(
                        title: 'Informations utilisateurs',
                        isActive: tabsRouter.activeIndex >= 2,
                        number: 'O3',
                        isLast: true,
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => context.router.replaceAll([app_router.LoginRoute()]),
                        child: Row(
                          children: [
                            Icon(Icons.login_outlined, color: primaryColor),
                            const SizedBox(width: 8),
                            Text('SE CONNECTER',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
    ),
  );
}

InputDecoration _defaultInputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
  );
}

@RoutePage()
class RestaurantCustomizeForm extends StatefulWidget {
  const RestaurantCustomizeForm({super.key});

  @override
  State<RestaurantCustomizeForm> createState() =>
      _RestaurantCustomizeFormState();
}

class _RestaurantCustomizeFormState extends State<RestaurantCustomizeForm> {
  late RestaurantMoreInfoController controller;

  @override
  void initState() {
    super.initState();
    controller = RestaurantMoreInfoController(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: FormBuilder(
        key: controller.formKey,
        child: Center(
          child: SizedBox(
            width: 700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélectionner la catégorie et la langue utilise pour le menu',
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade500, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 30),
                _buildLabel('Catégorie'),
                FormBuilderDropdown(
                  name: 'type',
                  decoration: _defaultInputDecoration(hintText: 'Sélectionner catégorie(s)'),
                  validator: FormBuilderValidators.required(),
                  items: RestaurantType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                _buildLabel('Langue du menu'),
                BlocBuilder<LanguagesBloc, LanguagesState>(
                  builder: (context, langState) {
                    final selectedLang = langState.languages;
                    return FormBuilderFilterChips<String>(
                      name: 'languages',
                      initialValue: ['fr'],
                      spacing: 12,
                      runSpacing: 12,
                      decoration: const InputDecoration(border: InputBorder.none),
                      options: selectedLang.map((lang) {
                        return FormBuilderChipOption(
                          value: lang.code,
                          avatar: _getAvatarForLang(lang.code),
                          child: Text('  ${lang.name}  ', style: const TextStyle(fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                      //selectedRowColor: primaryColor.withOpacity(0.1),
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      checkmarkColor: primaryColor,
                    );
                  },
                ),
                const SizedBox(height: 300),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                         AutoTabsRouter.of(context).setActiveIndex(0);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        backgroundColor: primaryColor.withOpacity(0.2),
                        foregroundColor: primaryColor,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('PRÉCÉDENT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: controller.validate,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('SUIVANT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _getAvatarForLang(String code) {
    if (code.toLowerCase().startsWith('en')) return const Text('🇺🇸');
    if (code.toLowerCase().startsWith('fr')) return const Text('🇫🇷');
    if (code.toLowerCase().startsWith('zh')) return const Text('🇨🇳');
    return null;
  }
}

@RoutePage()
class RestaurantForm extends StatefulWidget {
  const RestaurantForm({super.key});

  @override
  State<RestaurantForm> createState() => _RestaurantFormState();
}

class _RestaurantFormState extends State<RestaurantForm> {
  late RestaurantRegistrationController controller;

  @override
  void initState() {
    super.initState();
    controller = RestaurantRegistrationController(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: FormBuilder(
        key: controller.formKey,
        child: Center(
          child: SizedBox(
            width: 700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Veuillez entrer les informations de votre restaurant',
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade500, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 30),
                _buildLabel('Nom de l\'établissement'),
                FormBuilderTextField(
                  autofocus: true,
                  name: 'name',
                  decoration: _defaultInputDecoration(hintText: 'Menu Zen Restaurant'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(
                      20,
                      errorText: 'Name must be less than 20 characters',
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Description'),
                FormBuilderTextField(
                  name: 'description',
                  maxLines: 4,
                  decoration: _defaultInputDecoration(hintText: 'Description....'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.maxLength(
                      100,
                      errorText: 'Name must be less than 100 characters',
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Email'),
                FormBuilderTextField(
                  name: 'email',
                  decoration: _defaultInputDecoration(hintText: 'menuzen@gmail.com'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Téléphone'),
                FormBuilderTextField(
                  name: 'phone',
                  initialValue: '+261 ',
                  decoration: _defaultInputDecoration(hintText: '+261 | '),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.phoneNumber(),
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Ville'),
                TypeAheadField<PhotonFeature>(
                  debounceDuration: const Duration(milliseconds: 1000),
                  emptyBuilder: (context) {
                    return const ListTile(title: Text('No results found'));
                  },
                  hideOnError: true,
                  suggestionsCallback: (search) async {
                    final response = await controller.searchAddress(search);
                    return response.features;
                  },
                  builder: (context, controllerTypeAhead, focusNode) {
                    return FormBuilderTextField(
                      name: 'city',
                      controller: controllerTypeAhead,
                      focusNode: focusNode,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      decoration: _defaultInputDecoration(hintText: 'Toliara'),
                    );
                  },
                  itemBuilder: (context, city) {
                    return ListTile(
                      title: Text(city.properties.name ?? ''),
                      subtitle: Text(city.properties.city ?? ''),
                    );
                  },
                  onSelected: (city) {
                    controller.setCurrentSelectedAddress(city);
                    controller.formKey.currentState?.fields['ville']?.didChange(
                      [
                            city.properties.name,
                            city.properties.city,
                            city.properties.state,
                            city.properties.country,
                            city.properties.postcode,
                          ]
                          .where((value) => value != null && value.isNotEmpty)
                          .join(', '),
                    );
                  },
                ),
                const SizedBox(height: 48),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(250, 50),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: controller.validate,
                    child: const Text('SUIVANT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@RoutePage()
class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  late UserRegistrationController controller;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    controller = UserRegistrationController(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: FormBuilder(
        key: controller.formKey,
        child: Center(
          child: SizedBox(
            width: 700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Veuillez entrer votre information en tant que gérant du restaurant',
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade500, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 30),
                _buildLabel('Nom d\'utilisateur'),
                FormBuilderTextField(
                  name: 'username',
                  decoration: _defaultInputDecoration(hintText: 'amel.jane'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(
                      20,
                      errorText: 'Name must be less than 20 characters',
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Nom complet'),
                FormBuilderTextField(
                  name: 'name',
                  decoration: _defaultInputDecoration(hintText: 'Jane Amel'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.maxLength(
                      50,
                      errorText: 'Name must be less than 100 characters',
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Email'),
                FormBuilderTextField(
                  name: 'email',
                  decoration: _defaultInputDecoration(hintText: 'amel@gmail.com'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Téléphone'),
                FormBuilderTextField(
                  name: 'phone',
                  initialValue: '+261 ',
                  decoration: _defaultInputDecoration(hintText: '+261 | '),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.phoneNumber(),
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Mot de passe'),
                FormBuilderTextField(
                  name: 'password',
                  obscureText: _obscurePassword,
                  decoration: _defaultInputDecoration(hintText: '********').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.password(
                      minSpecialCharCount: 0,
                      minUppercaseCount: 0,
                      minNumberCount: 0,
                    ),
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 24),
                _buildLabel('Confirmation de Mot de passe'),
                FormBuilderTextField(
                  name: 'confirm_password',
                  obscureText: _obscureConfirmPassword,
                  decoration: _defaultInputDecoration(hintText: '********').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (pass) {
                    if (pass !=
                        controller
                            .formKey
                            .currentState
                            ?.fields['password']
                            ?.value) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                BlocBuilder<RestaurantBloc, RestaurantState>(
                  builder: (context, state) {
                    if (state.status == BlocStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            AutoTabsRouter.of(context).setActiveIndex(1);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 50),
                            backgroundColor: primaryColor.withOpacity(0.2),
                            foregroundColor: primaryColor,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text('PRÉCÉDENT', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: controller.validate,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 50),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text('ENREGISTRER', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
