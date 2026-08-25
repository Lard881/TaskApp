// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'PlanPal';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription =>
      'PlanPal vous aide à gérer vos tâches, suivre vos progrès et collaborer avec votre équipe, le tout en un seul endroit.';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String taskCountSubtitle(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous avez $countString tâches aujourd\'hui.',
      one: 'Vous avez 1 tâche aujourd\'hui.',
      zero: 'Vous n\'avez aucune tâche aujourd\'hui.',
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navTasks => 'Tâches';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get todaysTasks => 'Tâches du jour';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get noTasksToday =>
      'Aucune tâche aujourd\'hui. Profitez de votre journée !';

  @override
  String get newTask => 'Nouvelle tâche';

  @override
  String get calendar => 'Calendrier';

  @override
  String get analytics => 'Analytique';

  @override
  String get documents => 'Documents';

  @override
  String get comingSoon => 'Bientôt disponible !';

  @override
  String get performanceOverview => 'Vue d\'ensemble des performances';

  @override
  String get completed => 'Terminées';

  @override
  String get inProgress => 'En cours';

  @override
  String get overdue => 'En retard';

  @override
  String get productivity => 'Productivité';

  @override
  String get myTasks => 'Mes tâches';

  @override
  String get noTasksEmpty => 'Aucune tâche ici. Ajoutez-en une !';

  @override
  String get filterAll => 'Toutes';

  @override
  String get filterToday => 'Aujourd\'hui';

  @override
  String get filterUpcoming => 'À venir';

  @override
  String get filterCompleted => 'Terminées';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortDueDateAsc => 'Date d\'échéance (la plus proche)';

  @override
  String get sortDueDateDesc => 'Date d\'échéance (la plus tardive)';

  @override
  String get sortPriorityHighLow => 'Priorité (haute à basse)';

  @override
  String get sortPriorityLowHigh => 'Priorité (basse à haute)';

  @override
  String get sortNameAZ => 'Nom (A–Z)';

  @override
  String get sortNameZA => 'Nom (Z–A)';

  @override
  String get taskNameLabel => 'Nom de la tâche';

  @override
  String get dueDateLabel => 'Date d\'échéance';

  @override
  String get dueTimeLabel => 'Heure d\'échéance';

  @override
  String get priorityLabel => 'Priorité';

  @override
  String get assigneeLabel => 'Responsable (optionnel)';

  @override
  String get descriptionLabel => 'Description (optionnel)';

  @override
  String get saveTask => 'Enregistrer la tâche';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get cancel => 'Annuler';

  @override
  String get allDay => 'Toute la journée';

  @override
  String get priorityHigh => 'Haute';

  @override
  String get priorityMedium => 'Moyenne';

  @override
  String get priorityLow => 'Basse';

  @override
  String get taskNameRequired => 'Le nom de la tâche est obligatoire.';

  @override
  String get taskNameTooLong =>
      'Le nom doit comporter 100 caractères ou moins.';

  @override
  String get dueDateRequired => 'La date d\'échéance est obligatoire.';

  @override
  String get dueTimeRequired => 'L\'heure d\'échéance est obligatoire.';

  @override
  String get priorityRequired => 'La priorité est obligatoire.';

  @override
  String get markComplete => 'Marquer comme terminée';

  @override
  String get reopen => 'Rouvrir';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get taskAdded => 'Tâche ajoutée avec succès.';

  @override
  String get taskUpdated => 'Tâche mise à jour avec succès.';

  @override
  String get taskDeleted => 'Tâche supprimée.';

  @override
  String get taskMarkedComplete => 'Tâche marquée comme terminée.';

  @override
  String get taskReopened => 'Tâche rouverte.';

  @override
  String get deleteTaskConfirm => 'Supprimer cette tâche ?';

  @override
  String get deleteTaskBody => 'Cette action est irréversible.';

  @override
  String get conversations => 'Conversations';

  @override
  String get searchConversations => 'Rechercher des conversations…';

  @override
  String get noConversations => 'Aucune conversation pour l\'instant.';

  @override
  String get noResults => 'Aucun résultat trouvé.';

  @override
  String get typeAMessage => 'Écrire un message…';

  @override
  String get startConversation => 'Démarrer la conversation';

  @override
  String get newConversation => 'Nouvelle conversation';

  @override
  String get searchContacts => 'Rechercher des contacts…';

  @override
  String get noContactsFound => 'Aucun contact trouvé.';

  @override
  String get selectParticipant =>
      'Veuillez sélectionner au moins un participant.';

  @override
  String get groupLimit =>
      'Les conversations de groupe sont limitées à 50 participants.';

  @override
  String get tasksCompleted => 'Tâches terminées';

  @override
  String get activeProjects => 'Projets actifs';

  @override
  String get teamMembers => 'Membres de l\'équipe';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get noRecentActivity => 'Aucune activité récente.';

  @override
  String get editProfileSettings => 'Modifier le profil';

  @override
  String get avatarUpdateFailed =>
      'Impossible de mettre à jour l\'avatar. Réessayez.';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get roleLabel => 'Rôle / Titre (optionnel)';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get phoneLabel => 'Téléphone (optionnel)';

  @override
  String get save => 'Enregistrer';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès.';

  @override
  String get profileSaveFailed =>
      'Impossible d\'enregistrer le profil. Réessayez.';

  @override
  String get firstNameRequired => 'Le prénom est obligatoire.';

  @override
  String get lastNameRequired => 'Le nom est obligatoire.';

  @override
  String get emailRequired => 'L\'e-mail est obligatoire.';

  @override
  String get emailInvalid => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get settings => 'Paramètres';

  @override
  String get accountSettings => 'Compte';

  @override
  String get preferences => 'Préférences';

  @override
  String get supportLegals => 'Support et mentions légales';

  @override
  String get personalProfile => 'Profil personnel';

  @override
  String get notificationPreferences => 'Notifications';

  @override
  String get securityPrivacy => 'Sécurité et confidentialité';

  @override
  String get interfaceTheme => 'Thème de l\'interface';

  @override
  String get appLanguage => 'Langue';

  @override
  String get timeZone => 'Fuseau horaire';

  @override
  String get helpSupport => 'Aide et support';

  @override
  String get about => 'À propos';

  @override
  String get rateOurApp => 'Évaluer l\'application';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get logOutConfirm => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get loggedOut => 'Vous avez été déconnecté.';

  @override
  String get logOutFailed => 'Échec de la déconnexion. Réessayez.';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Selon le système';

  @override
  String get taskReminders => 'Rappels de tâches';

  @override
  String get dueDateAlerts => 'Alertes d\'échéance';

  @override
  String get chatMessages => 'Messages de chat';

  @override
  String get weeklySummary => 'Résumé hebdomadaire';

  @override
  String get prefSaveFailed =>
      'Impossible d\'enregistrer la préférence. Réessayez.';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get biometricLogin => 'Connexion biométrique';

  @override
  String get dataPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get passwordChanged => 'Mot de passe modifié avec succès.';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get passwordLength =>
      'Le mot de passe doit comporter entre 8 et 64 caractères.';

  @override
  String get passwordIncorrect => 'Le mot de passe actuel est incorrect.';

  @override
  String get passwordSaveFailed =>
      'Impossible de mettre à jour le mot de passe. Réessayez.';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get supportEmail => 'support@planpal.app';

  @override
  String get noEmailApp =>
      'Aucune application e-mail trouvée. Écrivez directement à support@planpal.app.';

  @override
  String get helpLoadFailed =>
      'Impossible de charger l\'aide. Réessayez plus tard.';

  @override
  String get storeOpenFailed =>
      'Impossible d\'ouvrir la boutique. Réessayez plus tard.';

  @override
  String get somethingWentWrong => 'Une erreur s\'est produite. Réessayez.';

  @override
  String get changesSaveFailed =>
      'Les modifications n\'ont pas pu être enregistrées. Réessayez.';

  @override
  String get dataLoadFailed =>
      'Impossible de charger les données. Démarrage depuis zéro.';

  @override
  String get faqTitle => 'Questions fréquentes';

  @override
  String get activityCreated => 'créée';

  @override
  String get activityUpdated => 'mise à jour';

  @override
  String get activityCompleted => 'terminée';

  @override
  String get deletedTask => '[Tâche supprimée]';

  @override
  String get noMessagesYet => 'Aucun message pour l\'instant. Dites bonjour !';

  @override
  String get quickActions => 'Actions rapides';
}
