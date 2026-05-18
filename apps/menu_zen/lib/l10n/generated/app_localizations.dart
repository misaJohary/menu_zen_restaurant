import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('mg'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu Zen'**
  String get appTitle;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get commonKeep;

  /// No description provided for @commonAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get commonAnonymous;

  /// No description provided for @commonYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commonYou;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @commonReachKitchenError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the kitchen.'**
  String get commonReachKitchenError;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email or phone to continue.'**
  String get authSignInSubtitle;

  /// No description provided for @authEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get authEmailOrPhone;

  /// No description provided for @authValidationEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone'**
  String get authValidationEmailOrPhone;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authValidationPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authValidationPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authCreateOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get authCreateOne;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about you to get started.'**
  String get authCreateAccountSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authValidationEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authValidationEmail;

  /// No description provided for @authValidationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get authValidationEmailInvalid;

  /// No description provided for @authPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get authPhoneOptional;

  /// No description provided for @authPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordHelper;

  /// No description provided for @authValidationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get authValidationPasswordRequired;

  /// No description provided for @authValidationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authValidationPasswordLength;

  /// No description provided for @discoverGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good evening.'**
  String get discoverGreeting;

  /// No description provided for @discoverBrowsingCity.
  ///
  /// In en, this message translates to:
  /// **'Browsing {city}'**
  String discoverBrowsingCity(String city);

  /// No description provided for @discoverNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get discoverNearYou;

  /// No description provided for @discoverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants, dishes…'**
  String get discoverSearchHint;

  /// No description provided for @discoverNewOnMenuZen.
  ///
  /// In en, this message translates to:
  /// **'New on Menu Zen'**
  String get discoverNewOnMenuZen;

  /// No description provided for @discoverPickedForYou.
  ///
  /// In en, this message translates to:
  /// **'Picked for you'**
  String get discoverPickedForYou;

  /// No description provided for @discoverTrendingThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Trending this week'**
  String get discoverTrendingThisWeek;

  /// No description provided for @moodCozy.
  ///
  /// In en, this message translates to:
  /// **'Cozy'**
  String get moodCozy;

  /// No description provided for @moodQuickBite.
  ///
  /// In en, this message translates to:
  /// **'Quick bite'**
  String get moodQuickBite;

  /// No description provided for @moodDateNight.
  ///
  /// In en, this message translates to:
  /// **'Date night'**
  String get moodDateNight;

  /// No description provided for @moodFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get moodFamily;

  /// No description provided for @moodOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get moodOutdoor;

  /// No description provided for @moodVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get moodVegetarian;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants'**
  String get searchHint;

  /// No description provided for @searchModeList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get searchModeList;

  /// No description provided for @searchModeMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get searchModeMap;

  /// No description provided for @searchNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get searchNoMatches;

  /// No description provided for @searchNoMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Try widening the radius or clearing some filters.'**
  String get searchNoMatchesBody;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filtersCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get filtersCuisine;

  /// No description provided for @filtersDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get filtersDistance;

  /// No description provided for @filtersDistanceAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filtersDistanceAny;

  /// No description provided for @filtersDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String filtersDistanceKm(String km);

  /// No description provided for @filtersCapabilities.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get filtersCapabilities;

  /// No description provided for @filtersDietary.
  ///
  /// In en, this message translates to:
  /// **'Dietary'**
  String get filtersDietary;

  /// No description provided for @capabilityReservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get capabilityReservations;

  /// No description provided for @capabilityDelivers.
  ///
  /// In en, this message translates to:
  /// **'Delivers'**
  String get capabilityDelivers;

  /// No description provided for @capabilityTakeaway.
  ///
  /// In en, this message translates to:
  /// **'Takeaway'**
  String get capabilityTakeaway;

  /// No description provided for @dietaryVeg.
  ///
  /// In en, this message translates to:
  /// **'Veg'**
  String get dietaryVeg;

  /// No description provided for @dietaryVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietaryVegan;

  /// No description provided for @dietaryHalal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get dietaryHalal;

  /// No description provided for @dietaryGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get dietaryGlutenFree;

  /// No description provided for @cuisineFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast food'**
  String get cuisineFastFood;

  /// No description provided for @cuisineCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get cuisineCasual;

  /// No description provided for @cuisineFineDining.
  ///
  /// In en, this message translates to:
  /// **'Fine dining'**
  String get cuisineFineDining;

  /// No description provided for @cuisineCasualDining.
  ///
  /// In en, this message translates to:
  /// **'Casual dining'**
  String get cuisineCasualDining;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'My favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your favorites live here.'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap ♡ on a place you love.'**
  String get favoritesEmptyBody;

  /// No description provided for @favoritesEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Explore restaurants'**
  String get favoritesEmptyAction;

  /// No description provided for @favoritesErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your favorites.'**
  String get favoritesErrorTitle;

  /// No description provided for @favoritesSignedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your favorites'**
  String get favoritesSignedOutTitle;

  /// No description provided for @favoritesSignedOutBody.
  ///
  /// In en, this message translates to:
  /// **'Save the places you love and find them in one tap.'**
  String get favoritesSignedOutBody;

  /// No description provided for @favoritesSignedOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get favoritesSignedOutAction;

  /// No description provided for @favoriteSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get favoriteSaveTooltip;

  /// No description provided for @favoriteRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get favoriteRemoveTooltip;

  /// No description provided for @profileSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Menu Zen'**
  String get profileSignInTitle;

  /// No description provided for @profileSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Access your favorites, reservations, and orders.'**
  String get profileSignInBody;

  /// No description provided for @profileSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileSignInAction;

  /// No description provided for @profileFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileFavorites;

  /// No description provided for @profileFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurants you saved'**
  String get profileFavoritesSubtitle;

  /// No description provided for @profileReservationsOrders.
  ///
  /// In en, this message translates to:
  /// **'Reservations & orders'**
  String get profileReservationsOrders;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutDialogTitle;

  /// No description provided for @profileSignOutDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to favorite places, reserve a table, or place an order.'**
  String get profileSignOutDialogBody;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageMalagasy.
  ///
  /// In en, this message translates to:
  /// **'Malagasy'**
  String get languageMalagasy;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languageSheetTitle;

  /// No description provided for @tabPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get tabPhotos;

  /// No description provided for @tabMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get tabMenu;

  /// No description provided for @tabReserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get tabReserve;

  /// No description provided for @tabReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get tabReviews;

  /// No description provided for @tabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tabAbout;

  /// No description provided for @photosEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get photosEmptyTitle;

  /// No description provided for @photosEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'This restaurant has not shared any photos.'**
  String get photosEmptyBody;

  /// No description provided for @photosCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String photosCounter(int current, int total);

  /// No description provided for @menuEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu coming soon'**
  String get menuEmptyTitle;

  /// No description provided for @menuEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'We haven\'t published anything to taste yet.'**
  String get menuEmptyBody;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Menu language'**
  String get menuLanguage;

  /// No description provided for @menuOtherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get menuOtherCategory;

  /// No description provided for @menuSectionFallback.
  ///
  /// In en, this message translates to:
  /// **'Section {index}'**
  String menuSectionFallback(int index);

  /// No description provided for @menuItemUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled item'**
  String get menuItemUntitled;

  /// No description provided for @menuItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get menuItemUnavailable;

  /// No description provided for @menuItemPrice.
  ///
  /// In en, this message translates to:
  /// **'Ar {price}'**
  String menuItemPrice(String price);

  /// No description provided for @menuItemAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart · Ar {total}'**
  String menuItemAddToCart(String total);

  /// No description provided for @reserveChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get reserveChooseDate;

  /// No description provided for @reservePartySize.
  ///
  /// In en, this message translates to:
  /// **'Party size'**
  String get reservePartySize;

  /// No description provided for @reservePickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get reservePickTime;

  /// No description provided for @reserveNoTimes.
  ///
  /// In en, this message translates to:
  /// **'No times available on this day.'**
  String get reserveNoTimes;

  /// No description provided for @reserveCta.
  ///
  /// In en, this message translates to:
  /// **'Reserve for {count} · {date} at {time}'**
  String reserveCta(int count, String date, String time);

  /// No description provided for @reserveGuests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} guest} other{{count} guests}}'**
  String reserveGuests(int count);

  /// No description provided for @reviewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsEmptyTitle;

  /// No description provided for @reviewsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your experience.'**
  String get reviewsEmptyBody;

  /// No description provided for @reviewsEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get reviewsEmptyAction;

  /// No description provided for @reviewWriteEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your review'**
  String get reviewWriteEditTitle;

  /// No description provided for @reviewWriteCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get reviewWriteCreateTitle;

  /// No description provided for @reviewWriteEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your rating or comment.'**
  String get reviewWriteEditSubtitle;

  /// No description provided for @reviewWriteCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help other diners pick their next spot.'**
  String get reviewWriteCreateSubtitle;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} review} other{{count} reviews}}'**
  String reviewsCount(int count);

  /// No description provided for @reviewSignInSnack.
  ///
  /// In en, this message translates to:
  /// **'Sign in to share a review.'**
  String get reviewSignInSnack;

  /// No description provided for @reviewPostedSnack.
  ///
  /// In en, this message translates to:
  /// **'Review posted — thanks!'**
  String get reviewPostedSnack;

  /// No description provided for @reviewUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Review updated.'**
  String get reviewUpdatedSnack;

  /// No description provided for @reviewDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Review deleted.'**
  String get reviewDeletedSnack;

  /// No description provided for @reviewDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this review?'**
  String get reviewDeleteDialogTitle;

  /// No description provided for @reviewDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your rating and comment will be removed from the restaurant page.'**
  String get reviewDeleteDialogBody;

  /// No description provided for @reviewComposerEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your review'**
  String get reviewComposerEditTitle;

  /// No description provided for @reviewComposerCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate this restaurant'**
  String get reviewComposerCreateTitle;

  /// No description provided for @reviewCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Tell others about your visit'**
  String get reviewCommentLabel;

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'What did you love? What could improve?'**
  String get reviewCommentHint;

  /// No description provided for @reviewSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get reviewSaveChanges;

  /// No description provided for @reviewPostReview.
  ///
  /// In en, this message translates to:
  /// **'Post review'**
  String get reviewPostReview;

  /// No description provided for @reviewRating1.
  ///
  /// In en, this message translates to:
  /// **'Disappointing'**
  String get reviewRating1;

  /// No description provided for @reviewRating2.
  ///
  /// In en, this message translates to:
  /// **'Below expectations'**
  String get reviewRating2;

  /// No description provided for @reviewRating3.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get reviewRating3;

  /// No description provided for @reviewRating4.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get reviewRating4;

  /// No description provided for @reviewRating5.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get reviewRating5;

  /// No description provided for @reviewRatingNone.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate'**
  String get reviewRatingNone;

  /// No description provided for @reviewStarSemantic.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} star} other{{count} stars}}'**
  String reviewStarSemantic(int count);

  /// No description provided for @aboutOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get aboutOpeningHours;

  /// No description provided for @aboutLanguagesSpoken.
  ///
  /// In en, this message translates to:
  /// **'Languages spoken'**
  String get aboutLanguagesSpoken;

  /// No description provided for @aboutSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get aboutSocialMedia;

  /// No description provided for @aboutHoursRange.
  ///
  /// In en, this message translates to:
  /// **'{open} – {close}'**
  String aboutHoursRange(String open, String close);

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @detailReserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get detailReserve;

  /// No description provided for @detailOrderDelivery.
  ///
  /// In en, this message translates to:
  /// **'Order delivery'**
  String get detailOrderDelivery;

  /// No description provided for @detailStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get detailStatusOpen;

  /// No description provided for @detailStatusOpenUntil.
  ///
  /// In en, this message translates to:
  /// **'Open · until {time}'**
  String detailStatusOpenUntil(String time);

  /// No description provided for @detailStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get detailStatusClosed;

  /// No description provided for @detailStatusClosesAt.
  ///
  /// In en, this message translates to:
  /// **'Closes {time}'**
  String detailStatusClosesAt(String time);

  /// No description provided for @detailStatusClosedOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Closed · opens {day} {time}'**
  String detailStatusClosedOpensAt(String day, String time);

  /// No description provided for @distanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String distanceMeters(int meters);

  /// No description provided for @distanceKilometersShort.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKilometersShort(String km);

  /// No description provided for @distanceKilometersRound.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKilometersRound(int km);

  /// No description provided for @bookingsPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings coming soon'**
  String get bookingsPlaceholderTitle;

  /// No description provided for @bookingsPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Your reservations and orders will live here.'**
  String get bookingsPlaceholderBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
