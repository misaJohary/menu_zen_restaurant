import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

/// `flutter_map` tile provider backed by our persistent image cache. Tiles
/// fetched while online survive across app restarts — without this, the
/// default `cached_network_image` cache lives in `getTemporaryDirectory()`
/// and can be wiped by the OS while the Drift cache remains.
class CachedTileProvider extends TileProvider {
  CachedTileProvider({super.headers});

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      headers: headers,
      cacheManager: PersistentImageCacheManager.instance,
    );
  }
}
