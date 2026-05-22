// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get appTitle => 'Menu Zen';

  @override
  String get navDiscover => 'Hijery';

  @override
  String get navSearch => 'Hitady';

  @override
  String get navBookings => 'Famandrihana';

  @override
  String get navProfile => 'Mombako';

  @override
  String get commonTryAgain => 'Andramo indray';

  @override
  String get commonCancel => 'Ajanona';

  @override
  String get commonReset => 'Avereno';

  @override
  String get commonApply => 'Ekena';

  @override
  String get commonShare => 'Zarao';

  @override
  String get commonEdit => 'Hanova';

  @override
  String get commonDelete => 'Fafao';

  @override
  String get commonKeep => 'Tazomy';

  @override
  String get commonAnonymous => 'Tsy fantatra';

  @override
  String get commonYou => 'Ianao';

  @override
  String get commonComingSoon => 'Ho avy tsy ho ela';

  @override
  String get commonReachKitchenError =>
      'Tsy tafiditra amin\'ny lakozia izahay.';

  @override
  String get authWelcomeBack => 'Tongasoa eto indray';

  @override
  String get authSignInSubtitle =>
      'Idiro amin\'ny mailaka na finday hanohizana.';

  @override
  String get authEmailOrPhone => 'Mailaka na finday';

  @override
  String get authValidationEmailOrPhone => 'Ampidiro ny mailaka na finday';

  @override
  String get authPassword => 'Teny miafina';

  @override
  String get authValidationPassword => 'Ampidiro ny teny miafina';

  @override
  String get authSignIn => 'Hiditra';

  @override
  String get authNoAccount => 'Tsy manana kaonty ?';

  @override
  String get authCreateOne => 'Hamorona kaonty';

  @override
  String get authCreateAccount => 'Hamorona kaonty';

  @override
  String get authCreateAccountSubtitle =>
      'Lazao kely momba anao mba hanombohana.';

  @override
  String get authFullName => 'Anarana feno';

  @override
  String get authEmail => 'Mailaka';

  @override
  String get authValidationEmail => 'Ampidiro ny mailakao';

  @override
  String get authValidationEmailInvalid => 'Ampidiro mailaka mety';

  @override
  String get authPhoneOptional => 'Finday (tsy voatery)';

  @override
  String get authPasswordHelper => 'Farafahakeliny 8 marika';

  @override
  String get authValidationPasswordRequired => 'Ampidiro ny teny miafina';

  @override
  String get authValidationPasswordLength =>
      'Tsy maintsy mihoatra na mitovy amin\'ny 8 marika ny teny miafina';

  @override
  String get discoverGreeting => 'Manao ahoana.';

  @override
  String discoverBrowsingCity(String city) {
    return 'Mijery $city';
  }

  @override
  String get discoverNearYou => 'Manakaiky anao';

  @override
  String get discoverSearchHint => 'Mitady toeram-pisakafoanana, sakafo…';

  @override
  String get discoverNewOnMenuZen => 'Vaovao ao amin\'ny Menu Zen';

  @override
  String get discoverPickedForYou => 'Voafantina ho anao';

  @override
  String get discoverTrendingThisWeek => 'Malaza amin\'ity herinandro ity';

  @override
  String get moodCozy => 'Mahafinaritra';

  @override
  String get moodQuickBite => 'Sakafo haingana';

  @override
  String get moodDateNight => 'Hariva miaraka';

  @override
  String get moodFamily => 'Fianakaviana';

  @override
  String get moodOutdoor => 'Ivelany';

  @override
  String get moodVegetarian => 'Anana fotsiny';

  @override
  String get searchHint => 'Hitady toeram-pisakafoanana';

  @override
  String get searchModeList => 'Lisitra';

  @override
  String get searchModeMap => 'Sarintany';

  @override
  String get searchNoMatches => 'Mbola tsy misy valiny';

  @override
  String get searchNoMatchesBody =>
      'Andramo halaina lavidavitra na esory ny sivana sasany.';

  @override
  String get filtersTitle => 'Sivana';

  @override
  String get filtersCuisine => 'Karazana sakafo';

  @override
  String get filtersDistance => 'Halaviran-davitra';

  @override
  String get filtersDistanceAny => 'Daholo';

  @override
  String filtersDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get filtersCapabilities => 'Tolotra';

  @override
  String get filtersDietary => 'Karazana fihinana';

  @override
  String get capabilityReservations => 'Famandrihana';

  @override
  String get capabilityDelivers => 'Fanaterana';

  @override
  String get capabilityTakeaway => 'Atao entina';

  @override
  String get dietaryVeg => 'Anana';

  @override
  String get dietaryVegan => 'Vegan';

  @override
  String get dietaryHalal => 'Halal';

  @override
  String get dietaryGlutenFree => 'Tsy misy gluten';

  @override
  String get cuisineFastFood => 'Sakafo haingana';

  @override
  String get cuisineCasual => 'Tsotra';

  @override
  String get cuisineFineDining => 'Avo lenta';

  @override
  String get cuisineCasualDining => 'Sakafo tsotra';

  @override
  String get favoritesTitle => 'Ireo tiako';

  @override
  String get favoritesEmptyTitle => 'Eto no misy ireo tianao.';

  @override
  String get favoritesEmptyBody => 'Tsindrio ny ♡ amin\'ny toerana tianao.';

  @override
  String get favoritesEmptyAction => 'Hijery toeram-pisakafoanana';

  @override
  String get favoritesErrorTitle => 'Tsy afaka naka ireo tianao izahay.';

  @override
  String get favoritesSignedOutTitle => 'Idiro mba hahitana ireo tianao';

  @override
  String get favoritesSignedOutBody =>
      'Tehirizo ireo toerana tianao ary hitanao indray amin\'ny indray tsindry.';

  @override
  String get favoritesSignedOutAction => 'Hiditra';

  @override
  String get favoriteSaveTooltip => 'Tehirizo';

  @override
  String get favoriteRemoveTooltip => 'Esory amin\'ny tiana';

  @override
  String get profileSignInTitle => 'Idiro ao amin\'ny Menu Zen';

  @override
  String get profileSignInBody =>
      'Idiro amin\'ny tianao, ny famandrihana sy ny baikonao.';

  @override
  String get profileSignInAction => 'Hiditra';

  @override
  String get profileFavorites => 'Tiana';

  @override
  String get profileFavoritesSubtitle =>
      'Ireo toeram-pisakafoanana voatahirinao';

  @override
  String get profileReservationsOrders => 'Famandrihana sy baiko';

  @override
  String get profileLanguage => 'Fiteny';

  @override
  String get profileSignOut => 'Hivoaka';

  @override
  String get profileSignOutDialogTitle => 'Hivoaka ?';

  @override
  String get profileSignOutDialogBody =>
      'Mila miditra indray ianao raha te hanavaka toerana, hamandrika latabatra, na hanao baiko.';

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
  String get languageSheetTitle => 'Misafidiana fiteny';

  @override
  String get tabPhotos => 'Sary';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabReserve => 'Famandrihana';

  @override
  String get tabReviews => 'Hevitra';

  @override
  String get tabAbout => 'Mombamomba';

  @override
  String get photosEmptyTitle => 'Mbola tsy misy sary';

  @override
  String get photosEmptyBody => 'Tsy mbola nizara sary ity toerana ity.';

  @override
  String photosCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get menuEmptyTitle => 'Ho avy tsy ho ela ny menu';

  @override
  String get menuEmptyBody => 'Mbola tsy nisy sakafo navoaka.';

  @override
  String get menuLanguage => 'Fitenin\'ny menu';

  @override
  String get menuOtherCategory => 'Hafa';

  @override
  String menuSectionFallback(int index) {
    return 'Fizarana $index';
  }

  @override
  String get menuItemUntitled => 'Sakafo tsy misy anarana';

  @override
  String get menuItemUnavailable => 'Tsy misy';

  @override
  String menuItemPrice(String price) {
    return 'Ar $price';
  }

  @override
  String menuItemAddToCart(String total) {
    return 'Ampio amin\'ny harona · Ar $total';
  }

  @override
  String get reserveChooseDate => 'Misafidiana daty';

  @override
  String get reservePartySize => 'Isan\'ny mpiantrano';

  @override
  String get reservePickTime => 'Misafidiana ora';

  @override
  String get reserveNoTimes => 'Tsy misy ora azo amin\'ity andro ity.';

  @override
  String reserveCta(int count, String date, String time) {
    return 'Hamandrika ho an\'ny $count · $date amin\'ny $time';
  }

  @override
  String reserveGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'olona $count',
      one: 'olona $count',
    );
    return '$_temp0';
  }

  @override
  String get reviewsEmptyTitle => 'Mbola tsy misy hevitra';

  @override
  String get reviewsEmptyBody =>
      'Aoka ho ianao no voalohany hizara ny traikefanao.';

  @override
  String get reviewsEmptyAction => 'Hanoratra hevitra';

  @override
  String get reviewWriteEditTitle => 'Hanova ny hevitrao';

  @override
  String get reviewWriteCreateTitle => 'Zarao ny traikefanao';

  @override
  String get reviewWriteEditSubtitle =>
      'Avaozy ny naotinao na ny fanehoan-kevitrao.';

  @override
  String get reviewWriteCreateSubtitle =>
      'Manampia ny hafa hisafidy ny manaraka.';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hevitra $count',
      one: 'hevitra $count',
    );
    return '$_temp0';
  }

  @override
  String get reviewSignInSnack => 'Idiro mba hizara hevitra.';

  @override
  String get reviewPostedSnack => 'Voapetraka ny hevitrao — misaotra !';

  @override
  String get reviewUpdatedSnack => 'Voavaozy ny hevitra.';

  @override
  String get reviewDeletedSnack => 'Voafafa ny hevitra.';

  @override
  String get reviewDeleteDialogTitle => 'Fafao ity hevitra ity ?';

  @override
  String get reviewDeleteDialogBody =>
      'Hesorina amin\'ny pejy ny naotinao sy ny fanehoan-kevitrao.';

  @override
  String get reviewComposerEditTitle => 'Hanova ny hevitrao';

  @override
  String get reviewComposerCreateTitle => 'Manaova naoty an\'ity toerana ity';

  @override
  String get reviewCommentLabel => 'Lazao amin\'ny hafa ny tsidikao';

  @override
  String get reviewCommentHint =>
      'Inona no nahafinaritra anao ? Inona no azo atsaraina ?';

  @override
  String get reviewSaveChanges => 'Tehirizo ny fanovana';

  @override
  String get reviewPostReview => 'Apetraho ny hevitra';

  @override
  String get reviewRating1 => 'Tsy nahafa-po';

  @override
  String get reviewRating2 => 'Latsaka ny tokony ho izy';

  @override
  String get reviewRating3 => 'Tsara';

  @override
  String get reviewRating4 => 'Tsara dia tsara';

  @override
  String get reviewRating5 => 'Tena tsara';

  @override
  String get reviewRatingNone => 'Tsindrio kintana iray hanome naoty';

  @override
  String reviewStarSemantic(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kintana $count',
      one: 'kintana $count',
    );
    return '$_temp0';
  }

  @override
  String get aboutOpeningHours => 'Ora misokatra';

  @override
  String get aboutLanguagesSpoken => 'Fiteny resahina';

  @override
  String get aboutSocialMedia => 'Tambazotra sosialy';

  @override
  String aboutHoursRange(String open, String close) {
    return '$open – $close';
  }

  @override
  String get weekdayMonday => 'Alatsinainy';

  @override
  String get weekdayTuesday => 'Talata';

  @override
  String get weekdayWednesday => 'Alarobia';

  @override
  String get weekdayThursday => 'Alakamisy';

  @override
  String get weekdayFriday => 'Zoma';

  @override
  String get weekdaySaturday => 'Sabotsy';

  @override
  String get weekdaySunday => 'Alahady';

  @override
  String get detailReserve => 'Hamandrika';

  @override
  String get detailOrderDelivery => 'Hanafatra fanaterana';

  @override
  String get detailStatusOpen => 'Misokatra';

  @override
  String detailStatusOpenUntil(String time) {
    return 'Misokatra · hatramin\'ny $time';
  }

  @override
  String get detailStatusClosed => 'Mikatona';

  @override
  String detailStatusClosesAt(String time) {
    return 'Mikatona amin\'ny $time';
  }

  @override
  String detailStatusClosedOpensAt(String day, String time) {
    return 'Mikatona · misokatra $day $time';
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
  String get bookingsPlaceholderTitle => 'Famandrihana ho avy tsy ho ela';

  @override
  String get bookingsPlaceholderBody =>
      'Ho eto ny famandrihanao sy ny baikonao.';

  @override
  String get reservationRequestTitle => 'Hangataka famandrihana';

  @override
  String get reservationDetailTitle => 'Famandrihana';

  @override
  String get reservationsTitle => 'Ny famandrihako';

  @override
  String get reservationsTabAll => 'Rehetra';

  @override
  String get reservationStatusWaiting => 'Miandry';

  @override
  String get reservationStatusAccepted => 'Nekena';

  @override
  String get reservationStatusRefused => 'Notsipahina';

  @override
  String get reservationStatusCanceled => 'Nofoanana';

  @override
  String get reservationDateLabel => 'Daty';

  @override
  String get reservationTimeLabel => 'Ora';

  @override
  String get reservationPartySizeLabel => 'Isan\'ny mpiara-misakafo';

  @override
  String get reservationPhoneLabel => 'Finday';

  @override
  String get reservationPhoneRequired => 'Ampidiro ny laharan-finday';

  @override
  String get reservationPhoneInvalid => 'Ampidiro laharana mety';

  @override
  String get reservationNoteLabel => 'Fangatahana manokana';

  @override
  String get reservationNoteHint => 'Allergie, fety, toerana tianao…';

  @override
  String get reservationOpeningHoursMissing =>
      'Tsy nampiavaka ora fisokafana ity trano fisakafoanana ity.';

  @override
  String get reservationMoreDates => 'Hafa…';

  @override
  String get reservationMoreParty => 'Hafa…';

  @override
  String get reservationPickDateFirst =>
      'Misafidiana daty mba hahitana ireo ora.';

  @override
  String get reservationNoTimes => 'Tsy misy ora amin\'io andro io.';

  @override
  String get reservationSubmit => 'Alefa ny fangatahana';

  @override
  String get reservationSubmitHint =>
      'Hanamafy ny fangatahanao ny trano fisakafoanana.';

  @override
  String get reservationSuccessToast =>
      'Voaray ny fangatahana — handefasana valiny tsy ho ela.';

  @override
  String get reservationErrorPastTime => 'Misafidiana ora ho avy.';

  @override
  String get reservationRequestedAt => 'Nangatahina';

  @override
  String get reservationCancel => 'Foano ny famandrihana';

  @override
  String get reservationCancelDialogTitle => 'Foanana ity famandrihana ity?';

  @override
  String get reservationCancelDialogBody =>
      'Afaka mangataka iray hafa ianao avy eo.';

  @override
  String get reservationRefusedBanner =>
      'Notsipahin\'ny trano fisakafoanana ity famandrihana ity.';

  @override
  String reservationTablesAssigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Latabatra $count natokana',
      one: 'Latabatra $count natokana',
    );
    return '$_temp0';
  }

  @override
  String get reservationsEmptyTitle => 'Tsy mbola misy famandrihana';

  @override
  String get reservationsEmptyBody =>
      'Mitadiava trano fisakafoanana ary mangataha latabatra.';

  @override
  String get reservationsEmptyAction => 'Hizaha ireo trano fisakafoanana';

  @override
  String get reservationsEmptyFiltered => 'Tsy misy ho an\'ity sivana ity.';

  @override
  String get reservationsErrorTitle =>
      'Tsy afaka naka ny famandrihanao izahay.';

  @override
  String get reservationSignedOutTitle => 'Midira mba hamandrihana';

  @override
  String get reservationSignedOutBody =>
      'Mamoròna kaonty na midira mba hangataka latabatra.';

  @override
  String get reservationSignedOutAction => 'Hiditra';

  @override
  String get orderRequestTitle => 'Hibaiko ho fanaterana';

  @override
  String get orderDetailTitle => 'Baiko';

  @override
  String get ordersTitle => 'Ny baikoko';

  @override
  String get ordersTabAll => 'Rehetra';

  @override
  String get orderStatusCreated => 'Voaray';

  @override
  String get orderStatusInPreparation => 'Mikarakara';

  @override
  String get orderStatusReady => 'Vonona';

  @override
  String get orderStatusServed => 'Voatatitra';

  @override
  String get orderStatusCancelled => 'Nofoanana';

  @override
  String get orderStepItemsTitle => 'Misafidiana sakafo';

  @override
  String get orderStepAddressTitle => 'Adiresy fanaterana';

  @override
  String get orderStepNotesTitle => 'Hafatra ho an\'ny mpitatitra';

  @override
  String get orderStepPhoneTitle => 'Hamafiso ny laharanao';

  @override
  String get orderStepAddressHeadline => 'Aiza no hanaterana?';

  @override
  String get orderStepAddressBody =>
      'Manomeza antsipiriany hahitan\'ny mpitatitra anao (trano, vavahady, rihana).';

  @override
  String get orderStepNotesHeadline => 'Misy ve ny tianao holazaina?';

  @override
  String get orderStepNotesBody =>
      'Tsy voatery. Kaody vavahady, fampahafantarana, allergie, sns.';

  @override
  String get orderStepPhoneHeadline => 'Laharana ho an\'ny fanaterana';

  @override
  String get orderStepPhoneBody =>
      'Mety hiantso anao ny mpitatitra rehefa tonga.';

  @override
  String get orderItemsEmptyTitle => 'Mbola tsy misy hibaikoana';

  @override
  String get orderItemsEmptyBody =>
      'Mbola tsy nametraka sakafo ity trano fisakafoanana ity.';

  @override
  String get orderItemAdd => 'Ampio';

  @override
  String get orderAddressLabel => 'Adiresy fanaterana';

  @override
  String get orderAddressHint => 'Lot II A 23 bis, Antananarivo 101';

  @override
  String get orderAddressRequired => 'Ampidiro ny adiresy fanaterana';

  @override
  String get orderNotesLabel => 'Hafatra ho an\'ny mpitatitra';

  @override
  String get orderNotesHint => 'Mampaneno indroa, kaody vavahady 4321…';

  @override
  String get orderPhoneLabel => 'Finday';

  @override
  String get orderPhoneHint => '+261 34 12 345 67';

  @override
  String get orderPhoneRequired => 'Ampidiro ny laharan-finday';

  @override
  String get orderPhoneInvalid => 'Ampidiro laharana mety';

  @override
  String get orderBack => 'Hiverina';

  @override
  String get orderNext => 'Manaraka';

  @override
  String get orderPlaceOrder => 'Alefa ny baiko';

  @override
  String get orderTotalLabel => 'Totalin\'ny';

  @override
  String get orderSummaryTitle => 'Famintinan\'ny baiko';

  @override
  String orderSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sakafo $count',
      one: 'Sakafo $count',
    );
    return '$_temp0';
  }

  @override
  String orderCardId(int id) {
    return 'Baiko #$id';
  }

  @override
  String get orderSuccessToast =>
      'Voaray ny baiko — manomboka manomana izy ireo.';

  @override
  String get orderSignedOutTitle => 'Midira mba hibaiko';

  @override
  String get orderSignedOutBody => 'Mamoròna kaonty na midira mba hibaiko.';

  @override
  String get orderSignedOutAction => 'Hiditra';

  @override
  String get ordersEmptyTitle => 'Tsy mbola misy baiko';

  @override
  String get ordersEmptyBody => 'Hizahà trano fisakafoanana ary mibaikoa.';

  @override
  String get ordersEmptyAction => 'Hizaha ireo trano fisakafoanana';

  @override
  String get ordersEmptyFiltered => 'Tsy misy ho an\'ity sivana ity.';

  @override
  String get ordersErrorTitle => 'Tsy afaka naka ny baikonao izahay.';

  @override
  String get orderCancel => 'Foano ny baiko';

  @override
  String get orderCancelDialogTitle => 'Foanana ity baiko ity?';

  @override
  String get orderCancelDialogBody =>
      'Tsy azo foanana intsony raha efa nanomboka.';

  @override
  String get orderCancelTooLate =>
      'Tara loatra ny manafoana — antsoy mivantana ny trano fisakafoanana.';
}
