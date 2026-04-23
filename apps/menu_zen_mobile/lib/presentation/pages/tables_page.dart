import 'dart:async';

import 'package:domain/entities/table_entity.dart';
import 'package:domain/entities/table_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/constants.dart';
import '../../core/enums/bloc_status.dart';
import '../bloc/tables/table_bloc.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  TableStatus? _selected;

  @override
  void initState() {
    super.initState();
    context.read<TableBloc>().add(TableFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tables',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          _StatusFilterBar(
            selected: _selected,
            onChanged: (v) => setState(() => _selected = v),
          ),
          Expanded(
            child: BlocBuilder<TableBloc, TableState>(
              builder: (context, state) {
                if (state.status == BlocStatus.loading &&
                    state.tables.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == BlocStatus.failed && state.tables.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Impossible de charger les tables',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              context.read<TableBloc>().add(TableFetched()),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                final visible = _selected == null
                    ? state.tables
                    : state.tables.where((t) => t.status == _selected).toList();
                if (visible.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucune table',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      context.read<TableBloc>().add(TableFetched()),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    itemCount: visible.length,
                    itemBuilder: (context, i) => _TableCard(table: visible[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status helpers ──────────────────────────────────────────────────────────

extension _TableStatusColors on TableStatus {
  Color get accent => switch (this) {
    TableStatus.free => const Color(0xFF22C55E),
    TableStatus.assigned => const Color(0xFF3B82F6),
    TableStatus.waiting => const Color(0xFFF97316),
    TableStatus.dirty => const Color(0xFF9CA3AF),
    TableStatus.reserved => const Color(0xFF8B5CF6),
  };

  String get label => switch (this) {
    TableStatus.free => 'Libre',
    TableStatus.assigned => 'Occupé',
    TableStatus.waiting => 'Attente',
    TableStatus.dirty => 'Nettoyage',
    TableStatus.reserved => 'Réservé',
  };
}

// ─── Status filter bar ───────────────────────────────────────────────────────

class _StatusFilterBar extends StatelessWidget {
  final TableStatus? selected;
  final ValueChanged<TableStatus?> onChanged;

  const _StatusFilterBar({required this.selected, required this.onChanged});

  static const _filters = <TableStatus?>[
    null,
    TableStatus.free,
    TableStatus.waiting,
    TableStatus.assigned,
    TableStatus.reserved,
    TableStatus.dirty,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final s in _filters) ...[
              _FilterChip(
                status: s,
                isSelected: selected == s,
                onTap: () => onChanged(s),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final TableStatus? status;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = status?.label ?? 'Tout';
    final dotColor = status?.accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1F2937) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Table card ──────────────────────────────────────────────────────────────

class _TableCard extends StatefulWidget {
  final TableEntity table;

  const _TableCard({required this.table});

  @override
  State<_TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<_TableCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.table.status == TableStatus.waiting &&
        widget.table.waitingSince != null) {
      _timer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => setState(() {}),
      );
    }
  }

  @override
  void didUpdateWidget(covariant _TableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final needsTimer =
        widget.table.status == TableStatus.waiting &&
        widget.table.waitingSince != null;
    if (needsTimer && _timer == null) {
      _timer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => setState(() {}),
      );
    } else if (!needsTimer && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _elapsed(DateTime? since) {
    if (since == null) return '';
    final m = DateTime.now().difference(since).inMinutes;
    return '$m min\nÉcoulé';
  }

  @override
  Widget build(BuildContext context) {
    final table = widget.table;
    final accent = table.status.accent;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: accent.withValues(alpha: 0.25),
        highlightColor: accent.withValues(alpha: 0.10),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent, width: 1.5),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              _SecondaryLine(table: table, elapsed: _elapsed),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryLine extends StatelessWidget {
  final TableEntity table;
  final String Function(DateTime?) elapsed;

  const _SecondaryLine({required this.table, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final accent = table.status.accent;

    switch (table.status) {
      case TableStatus.free:
        return Text(
          'Disponible',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      case TableStatus.assigned:
        return Text(
          table.server?.username ?? 'Occupé',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      case TableStatus.waiting:
        return Text(
          elapsed(table.waitingSince),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        );
      case TableStatus.dirty:
        return Text(
          'Nettoyage...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        );
      case TableStatus.reserved:
        final name = table.activeReservation?.reservation?.name;
        return Text(
          name == null || name.isEmpty ? 'Réservé' : name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }
}
