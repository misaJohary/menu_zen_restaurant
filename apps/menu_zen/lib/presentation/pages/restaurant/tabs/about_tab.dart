import 'package:design_system/design_system.dart';
import 'package:domain/entities/opening_hours_entity.dart';
import 'package:domain/entities/restaurant_detail_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/generated/app_localizations.dart';

class AboutTab extends StatelessWidget {
  final RestaurantDetailPublicEntity detail;
  const AboutTab({super.key, required this.detail});

  static List<String> _weekdays(AppLocalizations l10n) => [
        l10n.weekdayMonday,
        l10n.weekdayTuesday,
        l10n.weekdayWednesday,
        l10n.weekdayThursday,
        l10n.weekdayFriday,
        l10n.weekdaySaturday,
        l10n.weekdaySunday,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasLocation = detail.lat != null && detail.long != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xxxl,
      ),
      children: [
        if (hasLocation) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: SizedBox(
              height: 160,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(detail.lat!, detail.long!),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.menuzen.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(detail.lat!, detail.long!),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          PhosphorIconsFill.mapPin,
                          color: AppColors.terracotta,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        if (detail.city.isNotEmpty)
          _InfoRow(
            icon: PhosphorIconsRegular.mapPin,
            label: detail.city,
            onTap: hasLocation
                ? () => _openMaps(detail.lat!, detail.long!, detail.name)
                : null,
          ),
        if (detail.phone.isNotEmpty)
          _InfoRow(
            icon: PhosphorIconsRegular.phone,
            label: detail.phone,
            onTap: () => _dial(detail.phone),
          ),
        if (detail.email.isNotEmpty)
          _InfoRow(
            icon: PhosphorIconsRegular.envelope,
            label: detail.email,
            onTap: () => _email(detail.email),
          ),
        if (detail.openingHours != null &&
            detail.openingHours!.periods.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          Text(l10n.aboutOpeningHours, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          _HoursTable(hours: detail.openingHours!),
        ],
        if (detail.languages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          Text(l10n.aboutLanguagesSpoken, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.xs,
            children: [
              for (final code in detail.languages)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    code.toUpperCase(),
                    style: textTheme.labelMedium,
                  ),
                ),
            ],
          ),
        ],
        if (detail.socialMedia.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          Text(l10n.aboutSocialMedia, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          for (final url in detail.socialMedia)
            _InfoRow(
              icon: PhosphorIconsRegular.link,
              label: url,
              onTap: () => _openUrl(url),
            ),
        ],
      ],
    );
  }

  Future<void> _dial(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _email(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMaps(double lat, double long, String label) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$long',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _InfoRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (onTap != null)
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}

class _HoursTable extends StatelessWidget {
  final OpeningHoursEntity hours;
  const _HoursTable({required this.hours});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weekdays = AboutTab._weekdays(l10n);
    final today = DateTime.now().weekday - 1;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(7, (i) {
        final slots = hours.periods[i] ?? const <OpeningHoursSlotEntity>[];
        final isToday = i == today;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: Text(
                  weekdays[i],
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  slots.isEmpty
                      ? l10n.detailStatusClosed
                      : slots
                            .map((s) => l10n.aboutHoursRange(s.open, s.close))
                            .join(', '),
                  style: textTheme.bodyMedium?.copyWith(
                    color: slots.isEmpty
                        ? scheme.onSurface.withValues(alpha: 0.5)
                        : scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
