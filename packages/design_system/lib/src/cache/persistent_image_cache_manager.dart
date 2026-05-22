import 'package:file/file.dart' as fp;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// `flutter_cache_manager` defaults to `getTemporaryDirectory()` for the
/// actual on-disk image files. On Android/iOS that location is OS-clearable
/// and may not survive a fresh launch — so cached images can vanish even
/// when the Drift cache (in app documents) survives. We pin both the cache
/// files and the metadata DB to a persistent location so offline images
/// come back on a fresh launch.
///
/// Pass `PersistentImageCacheManager.instance` to every `CachedNetworkImage`
/// and `CachedNetworkImageProvider` in the app.
class PersistentImageCacheManager extends CacheManager with ImageCacheManager {
  static const _cacheKey = 'menu_zen_image_cache';

  static final PersistentImageCacheManager instance =
      PersistentImageCacheManager._();

  PersistentImageCacheManager._()
      : super(
          Config(
            _cacheKey,
            stalePeriod: const Duration(days: 60),
            maxNrOfCacheObjects: 1000,
            fileSystem: _PersistentFileSystem(_cacheKey),
          ),
        );
}

class _PersistentFileSystem implements FileSystem {
  _PersistentFileSystem(this._cacheKey)
      : _fileDir = _createDirectory(_cacheKey);

  final String _cacheKey;
  final Future<fp.Directory> _fileDir;

  static Future<fp.Directory> _createDirectory(String key) async {
    final baseDir = await getApplicationDocumentsDirectory();
    const fs = LocalFileSystem();
    final dir = fs.directory(p.join(baseDir.path, key));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<fp.File> createFile(String name) async {
    final dir = await _fileDir;
    if (!await dir.exists()) {
      await _createDirectory(_cacheKey);
    }
    return dir.childFile(name);
  }
}
