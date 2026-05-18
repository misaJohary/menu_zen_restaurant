import 'package:design_system/design_system.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/navigation/route_paths.dart';
import 'search_result_card.dart';

/// Map view with a draggable bottom sheet showing the same results as the
/// list mode. Tapping a pin centers the map and scrolls the sheet to that
/// card; horizontally swiping the sheet pans the map.
class SearchMapView extends StatefulWidget {
  final List<RestaurantPublicEntity> items;
  final LatLng origin;

  const SearchMapView({super.key, required this.items, required this.origin});

  @override
  State<SearchMapView> createState() => _SearchMapViewState();
}

class _SearchMapViewState extends State<SearchMapView> {
  final MapController _map = MapController();
  late final PageController _sheet = PageController(viewportFraction: 0.86);
  int _selected = 0;

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  List<RestaurantPublicEntity> get _located =>
      widget.items.where((r) => r.lat != null && r.long != null).toList();

  @override
  Widget build(BuildContext context) {
    final located = _located;

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: widget.origin,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'mg.menuzen.menu_zen',
            ),
            MarkerLayer(
              markers: [
                for (var i = 0; i < located.length; i++)
                  Marker(
                    point: LatLng(located[i].lat!, located[i].long!),
                    width: 44,
                    height: 44,
                    child: _PinMarker(
                      selected: i == _selected,
                      onTap: () => _selectIndex(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (located.isEmpty)
          const Positioned(
            top: AppSpacing.m,
            left: AppSpacing.m,
            right: AppSpacing.m,
            child: _MapMessage(text: 'No mapped results in this area.'),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _sheet,
              itemCount: located.length,
              onPageChanged: _selectIndex,
              padEnds: false,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s,
                    AppSpacing.s,
                    AppSpacing.s,
                    AppSpacing.m,
                  ),
                  child: SearchResultCard(
                    restaurant: located[index],
                    variant: RestaurantCardVariant.horizontal,
                    onTap: () => context.push(
                      RoutePaths.restaurantDetail(located[index].id),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _selectIndex(int index) {
    if (index < 0 || index >= _located.length) return;
    setState(() => _selected = index);
    final r = _located[index];
    _map.move(LatLng(r.lat!, r.long!), _map.camera.zoom);
    if (_sheet.hasClients) {
      _sheet.animateToPage(
        index,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

class _PinMarker extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  const _PinMarker({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          PhosphorIconsFill.forkKnife,
          size: 20,
          color: selected ? Colors.white : scheme.primary,
        ),
      ),
    );
  }
}

class _MapMessage extends StatelessWidget {
  final String text;
  const _MapMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        child: Text(text),
      ),
    );
  }
}
