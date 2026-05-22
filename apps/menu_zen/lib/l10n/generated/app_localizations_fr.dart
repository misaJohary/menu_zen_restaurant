// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Menu Zen';

  @override
  String get navDiscover => 'Découvrir';

  @override
  String get navSearch => 'Rechercher';

  @override
  String get navBookings => 'Réservations';

  @override
  String get navProfile => 'Profil';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get commonApply => 'Appliquer';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonKeep => 'Conserver';

  @override
  String get commonAnonymous => 'Anonyme';

  @override
  String get commonYou => 'Vous';

  @override
  String get commonComingSoon => 'Bientôt disponible';

  @override
  String get commonReachKitchenError => 'Impossible de joindre la cuisine.';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authSignInSubtitle =>
      'Connectez-vous avec votre e-mail ou téléphone pour continuer.';

  @override
  String get authEmailOrPhone => 'E-mail ou téléphone';

  @override
  String get authValidationEmailOrPhone =>
      'Veuillez saisir votre e-mail ou téléphone';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authValidationPassword => 'Veuillez saisir votre mot de passe';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authNoAccount => 'Pas encore de compte ?';

  @override
  String get authCreateOne => 'Créer un compte';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authCreateAccountSubtitle =>
      'Parlez-nous un peu de vous pour commencer.';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authValidationEmail => 'Veuillez saisir votre e-mail';

  @override
  String get authValidationEmailInvalid => 'Veuillez saisir un e-mail valide';

  @override
  String get authPhoneOptional => 'Téléphone (facultatif)';

  @override
  String get authPasswordHelper => 'Au moins 8 caractères';

  @override
  String get authValidationPasswordRequired =>
      'Veuillez saisir un mot de passe';

  @override
  String get authValidationPasswordLength =>
      'Le mot de passe doit comporter au moins 8 caractères';

  @override
  String get discoverGreeting => 'Bonsoir.';

  @override
  String discoverBrowsingCity(String city) {
    return 'Vous parcourez $city';
  }

  @override
  String get discoverNearYou => 'Près de vous';

  @override
  String get discoverSearchHint => 'Rechercher restaurants, plats…';

  @override
  String get discoverNewOnMenuZen => 'Nouveau sur Menu Zen';

  @override
  String get discoverPickedForYou => 'Sélectionné pour vous';

  @override
  String get discoverTrendingThisWeek => 'Tendance cette semaine';

  @override
  String get moodCozy => 'Cosy';

  @override
  String get moodQuickBite => 'Sur le pouce';

  @override
  String get moodDateNight => 'Soirée en duo';

  @override
  String get moodFamily => 'En famille';

  @override
  String get moodOutdoor => 'En terrasse';

  @override
  String get moodVegetarian => 'Végétarien';

  @override
  String get searchHint => 'Rechercher des restaurants';

  @override
  String get searchModeList => 'Liste';

  @override
  String get searchModeMap => 'Carte';

  @override
  String get searchNoMatches => 'Aucun résultat';

  @override
  String get searchNoMatchesBody =>
      'Essayez d\'élargir le rayon ou de retirer des filtres.';

  @override
  String get filtersTitle => 'Filtres';

  @override
  String get filtersCuisine => 'Cuisine';

  @override
  String get filtersDistance => 'Distance';

  @override
  String get filtersDistanceAny => 'Toutes';

  @override
  String filtersDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get filtersCapabilities => 'Services';

  @override
  String get filtersDietary => 'Régime';

  @override
  String get capabilityReservations => 'Réservations';

  @override
  String get capabilityDelivers => 'Livraison';

  @override
  String get capabilityTakeaway => 'À emporter';

  @override
  String get dietaryVeg => 'Végé';

  @override
  String get dietaryVegan => 'Vegan';

  @override
  String get dietaryHalal => 'Halal';

  @override
  String get dietaryGlutenFree => 'Sans gluten';

  @override
  String get cuisineFastFood => 'Restauration rapide';

  @override
  String get cuisineCasual => 'Décontracté';

  @override
  String get cuisineFineDining => 'Gastronomique';

  @override
  String get cuisineCasualDining => 'Restauration décontractée';

  @override
  String get favoritesTitle => 'Mes favoris';

  @override
  String get favoritesEmptyTitle => 'Vos favoris vivent ici.';

  @override
  String get favoritesEmptyBody =>
      'Appuyez sur ♡ pour ajouter un coup de cœur.';

  @override
  String get favoritesEmptyAction => 'Explorer les restaurants';

  @override
  String get favoritesErrorTitle => 'Impossible de charger vos favoris.';

  @override
  String get favoritesSignedOutTitle => 'Connectez-vous pour voir vos favoris';

  @override
  String get favoritesSignedOutBody =>
      'Enregistrez les adresses que vous aimez et retrouvez-les en un clic.';

  @override
  String get favoritesSignedOutAction => 'Se connecter';

  @override
  String get favoriteSaveTooltip => 'Enregistrer';

  @override
  String get favoriteRemoveTooltip => 'Retirer des favoris';

  @override
  String get profileSignInTitle => 'Connectez-vous à Menu Zen';

  @override
  String get profileSignInBody =>
      'Accédez à vos favoris, réservations et commandes.';

  @override
  String get profileSignInAction => 'Se connecter';

  @override
  String get profileFavorites => 'Favoris';

  @override
  String get profileFavoritesSubtitle => 'Les restaurants enregistrés';

  @override
  String get profileReservationsOrders => 'Réservations et commandes';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileSignOutDialogTitle => 'Se déconnecter ?';

  @override
  String get profileSignOutDialogBody =>
      'Vous devrez vous reconnecter pour ajouter des favoris, réserver une table ou commander.';

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
  String get languageSheetTitle => 'Choisir la langue';

  @override
  String get tabPhotos => 'Photos';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabReserve => 'Réserver';

  @override
  String get tabReviews => 'Avis';

  @override
  String get tabAbout => 'À propos';

  @override
  String get photosEmptyTitle => 'Aucune photo';

  @override
  String get photosEmptyBody =>
      'Ce restaurant n\'a pas encore partagé de photos.';

  @override
  String photosCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get menuEmptyTitle => 'Menu bientôt disponible';

  @override
  String get menuEmptyBody => 'Rien n\'est encore publié à déguster.';

  @override
  String get menuLanguage => 'Langue du menu';

  @override
  String get menuOtherCategory => 'Autre';

  @override
  String menuSectionFallback(int index) {
    return 'Section $index';
  }

  @override
  String get menuItemUntitled => 'Plat sans titre';

  @override
  String get menuItemUnavailable => 'Indisponible';

  @override
  String menuItemPrice(String price) {
    return 'Ar $price';
  }

  @override
  String menuItemAddToCart(String total) {
    return 'Ajouter au panier · Ar $total';
  }

  @override
  String get reserveChooseDate => 'Choisir une date';

  @override
  String get reservePartySize => 'Nombre de convives';

  @override
  String get reservePickTime => 'Choisir un horaire';

  @override
  String get reserveNoTimes => 'Aucun horaire disponible ce jour-là.';

  @override
  String reserveCta(int count, String date, String time) {
    return 'Réserver pour $count · $date à $time';
  }

  @override
  String reserveGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count convives',
      one: '$count convive',
    );
    return '$_temp0';
  }

  @override
  String get reviewsEmptyTitle => 'Aucun avis pour l\'instant';

  @override
  String get reviewsEmptyBody =>
      'Soyez le premier à partager votre expérience.';

  @override
  String get reviewsEmptyAction => 'Écrire un avis';

  @override
  String get reviewWriteEditTitle => 'Modifier votre avis';

  @override
  String get reviewWriteCreateTitle => 'Partagez votre expérience';

  @override
  String get reviewWriteEditSubtitle =>
      'Modifiez votre note ou votre commentaire.';

  @override
  String get reviewWriteCreateSubtitle =>
      'Aidez d\'autres convives à choisir leur prochaine adresse.';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis',
      one: '$count avis',
    );
    return '$_temp0';
  }

  @override
  String get reviewSignInSnack => 'Connectez-vous pour partager un avis.';

  @override
  String get reviewPostedSnack => 'Avis publié — merci !';

  @override
  String get reviewUpdatedSnack => 'Avis mis à jour.';

  @override
  String get reviewDeletedSnack => 'Avis supprimé.';

  @override
  String get reviewDeleteDialogTitle => 'Supprimer cet avis ?';

  @override
  String get reviewDeleteDialogBody =>
      'Votre note et votre commentaire seront retirés de la page du restaurant.';

  @override
  String get reviewComposerEditTitle => 'Modifier votre avis';

  @override
  String get reviewComposerCreateTitle => 'Noter ce restaurant';

  @override
  String get reviewCommentLabel => 'Racontez votre visite';

  @override
  String get reviewCommentHint =>
      'Qu\'avez-vous aimé ? Que pourrait-on améliorer ?';

  @override
  String get reviewSaveChanges => 'Enregistrer';

  @override
  String get reviewPostReview => 'Publier l\'avis';

  @override
  String get reviewRating1 => 'Décevant';

  @override
  String get reviewRating2 => 'En dessous des attentes';

  @override
  String get reviewRating3 => 'Bien';

  @override
  String get reviewRating4 => 'Très bien';

  @override
  String get reviewRating5 => 'Excellent';

  @override
  String get reviewRatingNone => 'Touchez une étoile pour noter';

  @override
  String reviewStarSemantic(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '$count étoile',
    );
    return '$_temp0';
  }

  @override
  String get aboutOpeningHours => 'Horaires d\'ouverture';

  @override
  String get aboutLanguagesSpoken => 'Langues parlées';

  @override
  String get aboutSocialMedia => 'Réseaux sociaux';

  @override
  String aboutHoursRange(String open, String close) {
    return '$open – $close';
  }

  @override
  String get weekdayMonday => 'Lundi';

  @override
  String get weekdayTuesday => 'Mardi';

  @override
  String get weekdayWednesday => 'Mercredi';

  @override
  String get weekdayThursday => 'Jeudi';

  @override
  String get weekdayFriday => 'Vendredi';

  @override
  String get weekdaySaturday => 'Samedi';

  @override
  String get weekdaySunday => 'Dimanche';

  @override
  String get detailReserve => 'Réserver';

  @override
  String get detailOrderDelivery => 'Commander en livraison';

  @override
  String get detailStatusOpen => 'Ouvert';

  @override
  String detailStatusOpenUntil(String time) {
    return 'Ouvert · jusqu\'à $time';
  }

  @override
  String get detailStatusClosed => 'Fermé';

  @override
  String detailStatusClosesAt(String time) {
    return 'Ferme à $time';
  }

  @override
  String detailStatusClosedOpensAt(String day, String time) {
    return 'Fermé · ouvre $day $time';
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
  String get bookingsPlaceholderTitle => 'Réservations bientôt disponibles';

  @override
  String get bookingsPlaceholderBody =>
      'Vos réservations et commandes apparaîtront ici.';

  @override
  String get reservationRequestTitle => 'Demander une réservation';

  @override
  String get reservationDetailTitle => 'Réservation';

  @override
  String get reservationsTitle => 'Mes réservations';

  @override
  String get reservationsTabAll => 'Toutes';

  @override
  String get reservationStatusWaiting => 'En attente';

  @override
  String get reservationStatusAccepted => 'Acceptée';

  @override
  String get reservationStatusRefused => 'Refusée';

  @override
  String get reservationStatusCanceled => 'Annulée';

  @override
  String get reservationDateLabel => 'Date';

  @override
  String get reservationTimeLabel => 'Heure';

  @override
  String get reservationPartySizeLabel => 'Nombre de convives';

  @override
  String get reservationPhoneLabel => 'Téléphone';

  @override
  String get reservationPhoneRequired =>
      'Veuillez saisir un numéro de téléphone';

  @override
  String get reservationPhoneInvalid => 'Saisissez un numéro valide';

  @override
  String get reservationNoteLabel => 'Demandes particulières';

  @override
  String get reservationNoteHint =>
      'Allergies, occasion, préférences de placement…';

  @override
  String get reservationOpeningHoursMissing =>
      'Ce restaurant n\'a pas publié ses horaires.';

  @override
  String get reservationMoreDates => 'Plus…';

  @override
  String get reservationMoreParty => 'Plus…';

  @override
  String get reservationPickDateFirst =>
      'Choisissez une date pour voir les créneaux.';

  @override
  String get reservationNoTimes => 'Aucun créneau ce jour-là.';

  @override
  String get reservationSubmit => 'Envoyer la demande';

  @override
  String get reservationSubmitHint =>
      'Le restaurant confirmera votre demande sous peu.';

  @override
  String get reservationSuccessToast =>
      'Demande envoyée — le restaurant confirmera bientôt.';

  @override
  String get reservationErrorPastTime => 'Veuillez choisir une heure future.';

  @override
  String get reservationRequestedAt => 'Demandée le';

  @override
  String get reservationCancel => 'Annuler la réservation';

  @override
  String get reservationCancelDialogTitle => 'Annuler cette réservation ?';

  @override
  String get reservationCancelDialogBody =>
      'Vous pourrez en demander une autre plus tard.';

  @override
  String get reservationRefusedBanner =>
      'Cette réservation a été refusée par le restaurant.';

  @override
  String reservationTablesAssigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables attribuées',
      one: '$count table attribuée',
    );
    return '$_temp0';
  }

  @override
  String get reservationsEmptyTitle => 'Aucune réservation';

  @override
  String get reservationsEmptyBody =>
      'Trouvez un restaurant qui vous plaît et demandez une table.';

  @override
  String get reservationsEmptyAction => 'Explorer les restaurants';

  @override
  String get reservationsEmptyFiltered => 'Rien pour ce filtre.';

  @override
  String get reservationsErrorTitle =>
      'Impossible de charger vos réservations.';

  @override
  String get reservationSignedOutTitle => 'Connectez-vous pour réserver';

  @override
  String get reservationSignedOutBody =>
      'Créez un compte ou connectez-vous pour demander une table.';

  @override
  String get reservationSignedOutAction => 'Se connecter';

  @override
  String get orderRequestTitle => 'Commander en livraison';

  @override
  String get orderDetailTitle => 'Commande';

  @override
  String get ordersTitle => 'Mes commandes';

  @override
  String get ordersTabAll => 'Toutes';

  @override
  String get orderStatusCreated => 'Passée';

  @override
  String get orderStatusInPreparation => 'En préparation';

  @override
  String get orderStatusReady => 'Prête';

  @override
  String get orderStatusServed => 'Livrée';

  @override
  String get orderStatusCancelled => 'Annulée';

  @override
  String get orderStepItemsTitle => 'Choisir les plats';

  @override
  String get orderStepAddressTitle => 'Adresse de livraison';

  @override
  String get orderStepNotesTitle => 'Mot pour le livreur';

  @override
  String get orderStepPhoneTitle => 'Confirmer le téléphone';

  @override
  String get orderStepAddressHeadline => 'Où devons-nous livrer ?';

  @override
  String get orderStepAddressBody =>
      'Donnez assez de détails pour que le livreur vous trouve (immeuble, portail, étage).';

  @override
  String get orderStepNotesHeadline => 'Quelque chose à préciser ?';

  @override
  String get orderStepNotesBody =>
      'Facultatif. Code de portail, instructions de sonnette, allergies, etc.';

  @override
  String get orderStepPhoneHeadline => 'Téléphone pour la livraison';

  @override
  String get orderStepPhoneBody =>
      'Le livreur pourra vous appeler en arrivant.';

  @override
  String get orderItemsEmptyTitle => 'Rien à commander pour l\'instant';

  @override
  String get orderItemsEmptyBody =>
      'Ce restaurant n\'a pas encore publié de plats.';

  @override
  String get orderItemAdd => 'Ajouter';

  @override
  String get orderAddressLabel => 'Adresse de livraison';

  @override
  String get orderAddressHint => 'Lot II A 23 bis, Antananarivo 101';

  @override
  String get orderAddressRequired => 'Veuillez saisir une adresse de livraison';

  @override
  String get orderNotesLabel => 'Mot pour le livreur';

  @override
  String get orderNotesHint => 'Sonner deux fois, code portail 4321…';

  @override
  String get orderPhoneLabel => 'Téléphone';

  @override
  String get orderPhoneHint => '+261 34 12 345 67';

  @override
  String get orderPhoneRequired => 'Veuillez saisir un numéro de téléphone';

  @override
  String get orderPhoneInvalid => 'Saisissez un numéro valide';

  @override
  String get orderBack => 'Retour';

  @override
  String get orderNext => 'Suivant';

  @override
  String get orderPlaceOrder => 'Passer la commande';

  @override
  String get orderTotalLabel => 'Total';

  @override
  String get orderSummaryTitle => 'Résumé de la commande';

  @override
  String orderSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '$count article',
    );
    return '$_temp0';
  }

  @override
  String orderCardId(int id) {
    return 'Commande #$id';
  }

  @override
  String get orderSuccessToast =>
      'Commande envoyée — le restaurant commence la préparation.';

  @override
  String get orderSignedOutTitle => 'Connectez-vous pour commander';

  @override
  String get orderSignedOutBody =>
      'Créez un compte ou connectez-vous pour passer une commande.';

  @override
  String get orderSignedOutAction => 'Se connecter';

  @override
  String get ordersEmptyTitle => 'Aucune commande';

  @override
  String get ordersEmptyBody =>
      'Parcourez les restaurants et lancez votre première livraison.';

  @override
  String get ordersEmptyAction => 'Explorer les restaurants';

  @override
  String get ordersEmptyFiltered => 'Rien pour ce filtre.';

  @override
  String get ordersErrorTitle => 'Impossible de charger vos commandes.';

  @override
  String get orderCancel => 'Annuler la commande';

  @override
  String get orderCancelDialogTitle => 'Annuler cette commande ?';

  @override
  String get orderCancelDialogBody =>
      'L\'annulation n\'est possible que tant que la commande n\'est pas commencée.';

  @override
  String get orderCancelTooLate =>
      'Trop tard pour annuler — contactez directement le restaurant.';
}
