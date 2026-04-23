import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import 'package:domain/entities/kitchen_entity.dart';
import 'package:domain/entities/user_entity.dart';
import '../managers/kitchens/kitchens_bloc.dart';
import '../managers/users/users_bloc.dart';
import '../widgets/loading_widget.dart';
import '../widgets/screen_header_widget.dart';

@RoutePage()
class KitchensScreen extends StatefulWidget {
  const KitchensScreen({super.key});

  @override
  State<KitchensScreen> createState() => _KitchensScreenState();
}

class _KitchensScreenState extends State<KitchensScreen> {
  @override
  void initState() {
    super.initState();
    context.read<KitchensBloc>().add(const KitchensFetched());
    context.read<UsersBloc>().add(const UsersFetched());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(kspacing * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Gestion des Cuisines',
              description: 'Gérer les cuisines et assigner des cuisiniers',
              onAddPressed: _showAddKitchenDialog,
              showLanguage: false,
            ),
            const SizedBox(height: kspacing * 2),
            Expanded(
              child: BlocBuilder<KitchensBloc, KitchensState>(
                builder: (context, state) {
                  switch (state.status) {
                    case BlocStatus.loading:
                      return const LoadingWidget();
                    case BlocStatus.loaded:
                      if (state.kitchens.isEmpty) {
                        return const Center(
                          child: Text('Aucune cuisine trouvée'),
                        );
                      }
                      return ListView.separated(
                        itemCount: state.kitchens.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final kitchen = state.kitchens[index];
                          return _KitchenTile(kitchen: kitchen);
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

  void _showAddKitchenDialog() {
    showDialog(
      context: context,
      builder: (_) => _KitchenFormDialog(
        title: 'Ajouter une cuisine',
        onSave: (kitchen) {
          context.read<KitchensBloc>().add(KitchenCreated(kitchen));
        },
      ),
    );
  }
}

class _KitchenTile extends StatelessWidget {
  const _KitchenTile({required this.kitchen});

  final KitchenEntity kitchen;

  @override
  Widget build(BuildContext context) {
    final hasCooks = kitchen.cooks.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: kspacing / 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kspacing * 2,
          vertical: kspacing,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: kitchen.active ? Colors.green : Colors.grey,
              child: const Icon(Icons.kitchen, color: Colors.white),
            ),
            const SizedBox(width: kspacing * 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        kitchen.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: kspacing),
                      _StatusChip(active: kitchen.active),
                    ],
                  ),
                  const SizedBox(height: kspacing / 2),
                  if (hasCooks)
                    Wrap(
                      spacing: kspacing,
                      runSpacing: kspacing / 2,
                      children: kitchen.cooks
                          .map((u) => _CookChip(user: u))
                          .toList(),
                    )
                  else
                    Text(
                      'Aucun cuisinier assigné',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.blue),
                  tooltip: 'Assigner / retirer un cuisinier',
                  onPressed: () => _showAssignCookDialog(context, kitchen),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(context, kitchen),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(context, kitchen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, KitchenEntity kitchen) {
    showDialog(
      context: context,
      builder: (_) => _KitchenFormDialog(
        title: 'Modifier la cuisine',
        kitchen: kitchen,
        onSave: (updated) {
          context.read<KitchensBloc>().add(KitchenUpdated(updated));
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, KitchenEntity kitchen) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Supprimer la cuisine "${kitchen.name}" ?\n'
          'Les items liés seront désassignés automatiquement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<KitchensBloc>().add(KitchenDeleted(kitchen.id!));
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAssignCookDialog(BuildContext context, KitchenEntity kitchen) {
    showDialog(
      context: context,
      builder: (_) => _AssignCookDialog(kitchen: kitchen),
    );
  }
}

class _KitchenFormDialog extends StatefulWidget {
  const _KitchenFormDialog({
    required this.title,
    this.kitchen,
    required this.onSave,
  });

  final String title;
  final KitchenEntity? kitchen;
  final void Function(KitchenEntity) onSave;

  @override
  State<_KitchenFormDialog> createState() => _KitchenFormDialogState();
}

class _KitchenFormDialogState extends State<_KitchenFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.kitchen?.name);
    _active = widget.kitchen?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom de la cuisine'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: kspacing),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
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
            if (_formKey.currentState?.validate() == true) {
              widget.onSave(
                KitchenEntity(
                  id: widget.kitchen?.id,
                  name: _nameCtrl.text.trim(),
                  active: _active,
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _AssignCookDialog extends StatefulWidget {
  const _AssignCookDialog({required this.kitchen});

  final KitchenEntity kitchen;

  @override
  State<_AssignCookDialog> createState() => _AssignCookDialogState();
}

class _AssignCookDialogState extends State<_AssignCookDialog> {
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cuisiniers — ${widget.kitchen.name}'),
      content: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          final cooks = state.users
              .where((u) => u.role == Role.cook || u.roleName == 'cook')
              .toList();

          if (cooks.isEmpty) {
            return const Text(
              'Aucun cuisinier disponible.\n'
              'Assignez le rôle "cook" à un utilisateur d\'abord.',
            );
          }

          return DropdownButtonFormField<int>(
            initialValue: _selectedUserId,
            decoration: const InputDecoration(
              labelText: 'Sélectionner un cuisinier',
            ),
            items: cooks
                .map(
                  (u) => DropdownMenuItem(
                    value: u.id,
                    child: Text(u.fullName ?? u.username),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedUserId = v),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _selectedUserId == null
              ? null
              : () {
                  context.read<KitchensBloc>().add(
                    KitchenCookAssigned(
                      kitchenId: widget.kitchen.id!,
                      userId: _selectedUserId!,
                    ),
                  );
                  Navigator.pop(context);
                },
          child: const Text('Assigner'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: _selectedUserId == null
              ? null
              : () {
                  context.read<KitchensBloc>().add(
                    KitchenCookRemoved(
                      kitchenId: widget.kitchen.id!,
                      userId: _selectedUserId!,
                    ),
                  );
                  Navigator.pop(context);
                },
          child: const Text('Retirer'),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          color: active ? Colors.green.shade800 : Colors.grey.shade700,
        ),
      ),
      backgroundColor: active
          ? Colors.green.withValues(alpha: 0.12)
          : Colors.grey.withValues(alpha: 0.15),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _CookChip extends StatelessWidget {
  const _CookChip({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final label = user.fullName ?? user.username;
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          label[0].toUpperCase(),
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      ),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
