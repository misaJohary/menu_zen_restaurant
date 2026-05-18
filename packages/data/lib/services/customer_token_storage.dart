import 'package:shared_preferences/shared_preferences.dart';

/// Persists the customer JWT. Kept under a dedicated key so a device that
/// also has the staff app installed keeps the two tokens apart.
abstract class CustomerTokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class CustomerTokenStorageImpl implements CustomerTokenStorage {
  static const String _key = 'customer_access_token';

  final SharedPreferencesAsync _prefs;

  CustomerTokenStorageImpl(this._prefs);

  @override
  Future<String?> read() => _prefs.getString(_key);

  @override
  Future<void> write(String token) => _prefs.setString(_key, token);

  @override
  Future<void> clear() => _prefs.remove(_key);
}
