/// Time-based TTLs for the offline read cache.
///
/// When a cached row's `cachedAt` is older than the bucket's TTL we don't
/// hand it back from the local datasource — the repository will treat the
/// cache as empty and either fetch fresh or surface an offline error.
class CachePolicy {
  const CachePolicy._();

  /// Restaurants, menus, menu items, restaurant details, reviews.
  static const Duration publicReadTtl = Duration(days: 7);

  /// Customer orders / reservations history (rarely changes; status updates
  /// flow in on the next online refresh).
  static const Duration customerHistoryTtl = Duration(days: 30);

  /// Favourites list — stable, refreshed on every online sync.
  static const Duration favoritesTtl = Duration(days: 30);
}
