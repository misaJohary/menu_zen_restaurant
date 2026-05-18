// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Menu Zen';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navSearch => 'Search';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonShare => 'Share';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonKeep => 'Keep';

  @override
  String get commonAnonymous => 'Anonymous';

  @override
  String get commonYou => 'You';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get commonReachKitchenError => 'We couldn\'t reach the kitchen.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInSubtitle =>
      'Sign in with your email or phone to continue.';

  @override
  String get authEmailOrPhone => 'Email or phone';

  @override
  String get authValidationEmailOrPhone => 'Please enter your email or phone';

  @override
  String get authPassword => 'Password';

  @override
  String get authValidationPassword => 'Please enter your password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authCreateOne => 'Create one';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authCreateAccountSubtitle =>
      'Tell us a bit about you to get started.';

  @override
  String get authFullName => 'Full name';

  @override
  String get authEmail => 'Email';

  @override
  String get authValidationEmail => 'Please enter your email';

  @override
  String get authValidationEmailInvalid => 'Please enter a valid email';

  @override
  String get authPhoneOptional => 'Phone (optional)';

  @override
  String get authPasswordHelper => 'At least 8 characters';

  @override
  String get authValidationPasswordRequired => 'Please enter a password';

  @override
  String get authValidationPasswordLength =>
      'Password must be at least 8 characters';

  @override
  String get discoverGreeting => 'Good evening.';

  @override
  String discoverBrowsingCity(String city) {
    return 'Browsing $city';
  }

  @override
  String get discoverNearYou => 'Near you';

  @override
  String get discoverSearchHint => 'Search restaurants, dishes…';

  @override
  String get discoverNewOnMenuZen => 'New on Menu Zen';

  @override
  String get discoverPickedForYou => 'Picked for you';

  @override
  String get discoverTrendingThisWeek => 'Trending this week';

  @override
  String get moodCozy => 'Cozy';

  @override
  String get moodQuickBite => 'Quick bite';

  @override
  String get moodDateNight => 'Date night';

  @override
  String get moodFamily => 'Family';

  @override
  String get moodOutdoor => 'Outdoor';

  @override
  String get moodVegetarian => 'Vegetarian';

  @override
  String get searchHint => 'Search restaurants';

  @override
  String get searchModeList => 'List';

  @override
  String get searchModeMap => 'Map';

  @override
  String get searchNoMatches => 'No matches yet';

  @override
  String get searchNoMatchesBody =>
      'Try widening the radius or clearing some filters.';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersCuisine => 'Cuisine';

  @override
  String get filtersDistance => 'Distance';

  @override
  String get filtersDistanceAny => 'Any';

  @override
  String filtersDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get filtersCapabilities => 'Capabilities';

  @override
  String get filtersDietary => 'Dietary';

  @override
  String get capabilityReservations => 'Reservations';

  @override
  String get capabilityDelivers => 'Delivers';

  @override
  String get capabilityTakeaway => 'Takeaway';

  @override
  String get dietaryVeg => 'Veg';

  @override
  String get dietaryVegan => 'Vegan';

  @override
  String get dietaryHalal => 'Halal';

  @override
  String get dietaryGlutenFree => 'Gluten-free';

  @override
  String get cuisineFastFood => 'Fast food';

  @override
  String get cuisineCasual => 'Casual';

  @override
  String get cuisineFineDining => 'Fine dining';

  @override
  String get cuisineCasualDining => 'Casual dining';

  @override
  String get favoritesTitle => 'My favorites';

  @override
  String get favoritesEmptyTitle => 'Your favorites live here.';

  @override
  String get favoritesEmptyBody => 'Tap ♡ on a place you love.';

  @override
  String get favoritesEmptyAction => 'Explore restaurants';

  @override
  String get favoritesErrorTitle => 'We couldn\'t load your favorites.';

  @override
  String get favoritesSignedOutTitle => 'Sign in to see your favorites';

  @override
  String get favoritesSignedOutBody =>
      'Save the places you love and find them in one tap.';

  @override
  String get favoritesSignedOutAction => 'Sign in';

  @override
  String get favoriteSaveTooltip => 'Save';

  @override
  String get favoriteRemoveTooltip => 'Remove favorite';

  @override
  String get profileSignInTitle => 'Sign in to Menu Zen';

  @override
  String get profileSignInBody =>
      'Access your favorites, reservations, and orders.';

  @override
  String get profileSignInAction => 'Sign in';

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profileFavoritesSubtitle => 'Restaurants you saved';

  @override
  String get profileReservationsOrders => 'Reservations & orders';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignOutDialogTitle => 'Sign out?';

  @override
  String get profileSignOutDialogBody =>
      'You will need to sign in again to favorite places, reserve a table, or place an order.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageMalagasy => 'Malagasy';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageChinese => '中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageSheetTitle => 'Choose language';

  @override
  String get tabPhotos => 'Photos';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabReserve => 'Reserve';

  @override
  String get tabReviews => 'Reviews';

  @override
  String get tabAbout => 'About';

  @override
  String get photosEmptyTitle => 'No photos yet';

  @override
  String get photosEmptyBody => 'This restaurant has not shared any photos.';

  @override
  String photosCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get menuEmptyTitle => 'Menu coming soon';

  @override
  String get menuEmptyBody => 'We haven\'t published anything to taste yet.';

  @override
  String get menuLanguage => 'Menu language';

  @override
  String get menuOtherCategory => 'Other';

  @override
  String menuSectionFallback(int index) {
    return 'Section $index';
  }

  @override
  String get menuItemUntitled => 'Untitled item';

  @override
  String get menuItemUnavailable => 'Unavailable';

  @override
  String menuItemPrice(String price) {
    return 'Ar $price';
  }

  @override
  String menuItemAddToCart(String total) {
    return 'Add to cart · Ar $total';
  }

  @override
  String get reserveChooseDate => 'Choose a date';

  @override
  String get reservePartySize => 'Party size';

  @override
  String get reservePickTime => 'Pick a time';

  @override
  String get reserveNoTimes => 'No times available on this day.';

  @override
  String reserveCta(int count, String date, String time) {
    return 'Reserve for $count · $date at $time';
  }

  @override
  String reserveGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '$count guest',
    );
    return '$_temp0';
  }

  @override
  String get reviewsEmptyTitle => 'No reviews yet';

  @override
  String get reviewsEmptyBody => 'Be the first to share your experience.';

  @override
  String get reviewsEmptyAction => 'Write a review';

  @override
  String get reviewWriteEditTitle => 'Edit your review';

  @override
  String get reviewWriteCreateTitle => 'Share your experience';

  @override
  String get reviewWriteEditSubtitle => 'Update your rating or comment.';

  @override
  String get reviewWriteCreateSubtitle =>
      'Help other diners pick their next spot.';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '$count review',
    );
    return '$_temp0';
  }

  @override
  String get reviewSignInSnack => 'Sign in to share a review.';

  @override
  String get reviewPostedSnack => 'Review posted — thanks!';

  @override
  String get reviewUpdatedSnack => 'Review updated.';

  @override
  String get reviewDeletedSnack => 'Review deleted.';

  @override
  String get reviewDeleteDialogTitle => 'Delete this review?';

  @override
  String get reviewDeleteDialogBody =>
      'Your rating and comment will be removed from the restaurant page.';

  @override
  String get reviewComposerEditTitle => 'Edit your review';

  @override
  String get reviewComposerCreateTitle => 'Rate this restaurant';

  @override
  String get reviewCommentLabel => 'Tell others about your visit';

  @override
  String get reviewCommentHint => 'What did you love? What could improve?';

  @override
  String get reviewSaveChanges => 'Save changes';

  @override
  String get reviewPostReview => 'Post review';

  @override
  String get reviewRating1 => 'Disappointing';

  @override
  String get reviewRating2 => 'Below expectations';

  @override
  String get reviewRating3 => 'Good';

  @override
  String get reviewRating4 => 'Great';

  @override
  String get reviewRating5 => 'Excellent';

  @override
  String get reviewRatingNone => 'Tap a star to rate';

  @override
  String reviewStarSemantic(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '$count star',
    );
    return '$_temp0';
  }

  @override
  String get aboutOpeningHours => 'Opening hours';

  @override
  String get aboutLanguagesSpoken => 'Languages spoken';

  @override
  String get aboutSocialMedia => 'Social media';

  @override
  String aboutHoursRange(String open, String close) {
    return '$open – $close';
  }

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get detailReserve => 'Reserve';

  @override
  String get detailOrderDelivery => 'Order delivery';

  @override
  String get detailStatusOpen => 'Open';

  @override
  String detailStatusOpenUntil(String time) {
    return 'Open · until $time';
  }

  @override
  String get detailStatusClosed => 'Closed';

  @override
  String detailStatusClosesAt(String time) {
    return 'Closes $time';
  }

  @override
  String detailStatusClosedOpensAt(String day, String time) {
    return 'Closed · opens $day $time';
  }

  @override
  String distanceMeters(int meters) {
    return '$meters m';
  }

  @override
  String distanceKilometersShort(String km) {
    return '$km km';
  }

  @override
  String distanceKilometersRound(int km) {
    return '$km km';
  }

  @override
  String get bookingsPlaceholderTitle => 'Bookings coming soon';

  @override
  String get bookingsPlaceholderBody =>
      'Your reservations and orders will live here.';
}
