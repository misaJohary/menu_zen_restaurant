/// Observes real internet reachability for the customer app.
///
/// `onlineStream` emits whenever connectivity changes.
/// `isOnline()` performs a fresh check (raw connectivity + optional probe).
abstract class ConnectivityService {
  Stream<bool> get onlineStream;

  Future<bool> isOnline();
}
