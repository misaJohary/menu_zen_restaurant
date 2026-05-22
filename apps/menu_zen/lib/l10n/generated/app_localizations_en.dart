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

  @override
  String get reservationRequestTitle => 'Request a reservation';

  @override
  String get reservationDetailTitle => 'Reservation';

  @override
  String get reservationsTitle => 'My reservations';

  @override
  String get reservationsTabAll => 'All';

  @override
  String get reservationStatusWaiting => 'Waiting';

  @override
  String get reservationStatusAccepted => 'Accepted';

  @override
  String get reservationStatusRefused => 'Refused';

  @override
  String get reservationStatusCanceled => 'Canceled';

  @override
  String get reservationDateLabel => 'Date';

  @override
  String get reservationTimeLabel => 'Time';

  @override
  String get reservationPartySizeLabel => 'Party size';

  @override
  String get reservationPhoneLabel => 'Phone';

  @override
  String get reservationPhoneRequired => 'Please enter a phone number';

  @override
  String get reservationPhoneInvalid => 'Enter a valid phone number';

  @override
  String get reservationNoteLabel => 'Special requests';

  @override
  String get reservationNoteHint => 'Allergies, occasion, seating preference…';

  @override
  String get reservationOpeningHoursMissing =>
      'This restaurant has not published opening hours.';

  @override
  String get reservationMoreDates => 'More…';

  @override
  String get reservationMoreParty => 'More…';

  @override
  String get reservationPickDateFirst => 'Pick a date to see available times.';

  @override
  String get reservationNoTimes => 'No times available on this day.';

  @override
  String get reservationSubmit => 'Send request';

  @override
  String get reservationSubmitHint =>
      'The restaurant will confirm your request shortly.';

  @override
  String get reservationSuccessToast =>
      'Request sent — the restaurant will confirm shortly.';

  @override
  String get reservationErrorPastTime => 'Please pick a future time.';

  @override
  String get reservationRequestedAt => 'Requested';

  @override
  String get reservationCancel => 'Cancel reservation';

  @override
  String get reservationCancelDialogTitle => 'Cancel this reservation?';

  @override
  String get reservationCancelDialogBody =>
      'You can always request a new one later.';

  @override
  String get reservationRefusedBanner =>
      'This reservation was refused by the restaurant.';

  @override
  String reservationTablesAssigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables assigned',
      one: '$count table assigned',
    );
    return '$_temp0';
  }

  @override
  String get reservationsEmptyTitle => 'No reservations yet';

  @override
  String get reservationsEmptyBody =>
      'Find a place you like and request a table.';

  @override
  String get reservationsEmptyAction => 'Explore restaurants';

  @override
  String get reservationsEmptyFiltered => 'Nothing here for this filter.';

  @override
  String get reservationsErrorTitle => 'We couldn\'t load your reservations.';

  @override
  String get reservationSignedOutTitle => 'Sign in to reserve';

  @override
  String get reservationSignedOutBody =>
      'Create an account or sign in to request a table.';

  @override
  String get reservationSignedOutAction => 'Sign in';

  @override
  String get orderRequestTitle => 'Order delivery';

  @override
  String get orderDetailTitle => 'Order';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersTabAll => 'All';

  @override
  String get orderStatusCreated => 'Placed';

  @override
  String get orderStatusInPreparation => 'Preparing';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusServed => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStepItemsTitle => 'Choose items';

  @override
  String get orderStepAddressTitle => 'Delivery address';

  @override
  String get orderStepNotesTitle => 'Note for the courier';

  @override
  String get orderStepPhoneTitle => 'Confirm your phone';

  @override
  String get orderStepAddressHeadline => 'Where should we bring it?';

  @override
  String get orderStepAddressBody =>
      'Add enough detail for the courier to find you (building, gate, floor).';

  @override
  String get orderStepNotesHeadline => 'Anything we should know?';

  @override
  String get orderStepNotesBody =>
      'Optional. Gate code, bell instructions, allergies, etc.';

  @override
  String get orderStepPhoneHeadline => 'Phone number for delivery';

  @override
  String get orderStepPhoneBody => 'The courier may call you when they arrive.';

  @override
  String get orderItemsEmptyTitle => 'Nothing to order yet';

  @override
  String get orderItemsEmptyBody =>
      'This restaurant hasn\'t published any items yet.';

  @override
  String get orderItemAdd => 'Add';

  @override
  String get orderAddressLabel => 'Delivery address';

  @override
  String get orderAddressHint => 'Lot II A 23 bis, Antananarivo 101';

  @override
  String get orderAddressRequired => 'Please enter a delivery address';

  @override
  String get orderNotesLabel => 'Note for the courier';

  @override
  String get orderNotesHint => 'Ring twice, gate code 4321…';

  @override
  String get orderPhoneLabel => 'Phone';

  @override
  String get orderPhoneHint => '+261 34 12 345 67';

  @override
  String get orderPhoneRequired => 'Please enter a phone number';

  @override
  String get orderPhoneInvalid => 'Enter a valid phone number';

  @override
  String get orderBack => 'Back';

  @override
  String get orderNext => 'Next';

  @override
  String get orderPlaceOrder => 'Place order';

  @override
  String get orderTotalLabel => 'Total';

  @override
  String get orderSummaryTitle => 'Order summary';

  @override
  String orderSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String orderCardId(int id) {
    return 'Order #$id';
  }

  @override
  String get orderSuccessToast =>
      'Order placed — the restaurant will start preparing it.';

  @override
  String get orderSignedOutTitle => 'Sign in to order';

  @override
  String get orderSignedOutBody =>
      'Create an account or sign in to place an order.';

  @override
  String get orderSignedOutAction => 'Sign in';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyBody =>
      'Browse restaurants and place your first delivery.';

  @override
  String get ordersEmptyAction => 'Explore restaurants';

  @override
  String get ordersEmptyFiltered => 'Nothing here for this filter.';

  @override
  String get ordersErrorTitle => 'We couldn\'t load your orders.';

  @override
  String get orderCancel => 'Cancel order';

  @override
  String get orderCancelDialogTitle => 'Cancel this order?';

  @override
  String get orderCancelDialogBody =>
      'You can only cancel while the order is still being placed.';

  @override
  String get orderCancelTooLate =>
      'It\'s too late to cancel — contact the restaurant directly.';
}
