import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../datasources/models/user_model.dart';
import '../../domains/entities/user_entity.dart';
import '../managers/users/users_bloc.dart';
import '../widgets/board_title_widget.dart';
import '../widgets/loading_widget.dart';

@RoutePage()
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(const UsersFetched());
    context.read<UsersBloc>().add(const RolesFetched());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(kspacing * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoardTitleWidget(
              title: 'Gestion des Utilisateurs',
              description: 'Gèrer les membres de votre équipe',
              labelButton: 'Ajouter un Utilisateur',
              onButtonPressed: () {
                _showAddUserDialog();
              },
            ),
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  switch (state.status) {
                    case BlocStatus.loading:
                      return const LoadingWidget();
                    case BlocStatus.loaded:
                      if (state.users.isEmpty) {
                        return const Center(
                          child: Text('Aucun utilisateur trouvé'),
                        );
                      }
                      return ListView.separated(
                        itemCount: state.users.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(user.username[0].toUpperCase()),
                            ),
                            title: Text(user.fullName ?? user.username),
                            subtitle: Text(
                              'Rôle: ${user.roleName ?? user.role.toString()}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showEditUserDialog(user),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _showDeleteConfirmation(user),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    case BlocStatus.failed:
                      return Center(
                        child: Text(
                          'Erreur: ${state.failure?.message ?? "Erreur inconnue"}',
                        ),
                      );
                    default:
                      return const Center(child: Text('Initialisation...'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => _UserFormDialog(
        title: 'Ajouter un utilisateur',
        onSave: (user) {
          context.read<UsersBloc>().add(UserCreated(user));
        },
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _UserFormDialog(
        title: 'Modifier l\'utilisateur',
        user: user,
        onSave: (updatedUser) {
          context.read<UsersBloc>().add(UserUpdated(updatedUser));
        },
      ),
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${user.username} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UsersBloc>().add(UserDeleted(user.id!));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final String title;
  final UserModel? user;
  final Function(UserModel) onSave;

  const _UserFormDialog({required this.title, this.user, required this.onSave});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _fullNameCtrl;
  late TextEditingController _passwordCtrl;
  Role? _selectedRole;
  int? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user?.username);
    _fullNameCtrl = TextEditingController(text: widget.user?.fullName);
    _passwordCtrl = TextEditingController();
    if (widget.user != null) {
      _selectedRole = widget.user!.role;
      _selectedRoleId = widget.user!.roleId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                ),
                validator: (v) => v?.isEmpty == true ? 'Requis' : null,
              ),
              TextFormField(
                controller: _fullNameCtrl,
                decoration: const InputDecoration(labelText: 'Nom Complet'),
              ),
              if (widget.user == null)
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                ),
              BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  return DropdownButtonFormField<int>(
                    value: _selectedRoleId,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                    items: state.roles.map((role) {
                      return DropdownMenuItem(
                        value: role.id,
                        child: Text(role.name),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedRoleId = v;
                        });
                      }
                    },
                    validator: (v) => v == null ? 'Requis' : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              final user = UserModel(
                id: widget.user?.id,
                username: _usernameCtrl.text,
                fullName: _fullNameCtrl.text,
                password: _passwordCtrl.text.isEmpty
                    ? null
                    : _passwordCtrl.text,
                roleId: _selectedRoleId,
              );
              widget.onSave(user);
              Navigator.pop(context);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
