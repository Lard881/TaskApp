// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'PlanPal';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription =>
      'PlanPal te ayuda a gestionar tareas, seguir el progreso y colaborar con tu equipo, todo en un solo lugar.';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String taskCountSubtitle(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tienes $countString tareas para hoy.',
      one: 'Tienes 1 tarea para hoy.',
      zero: 'No tienes tareas para hoy.',
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navTasks => 'Tareas';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get todaysTasks => 'Tareas de hoy';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get noTasksToday => 'Sin tareas hoy. ¡Disfruta tu día!';

  @override
  String get newTask => 'Nueva tarea';

  @override
  String get calendar => 'Calendario';

  @override
  String get analytics => 'Analíticas';

  @override
  String get documents => 'Documentos';

  @override
  String get comingSoon => '¡Próximamente!';

  @override
  String get performanceOverview => 'Resumen de rendimiento';

  @override
  String get completed => 'Completadas';

  @override
  String get inProgress => 'En progreso';

  @override
  String get overdue => 'Vencidas';

  @override
  String get productivity => 'Productividad';

  @override
  String get myTasks => 'Mis tareas';

  @override
  String get noTasksEmpty => 'Sin tareas aquí. ¡Añade una!';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterToday => 'Hoy';

  @override
  String get filterUpcoming => 'Próximas';

  @override
  String get filterCompleted => 'Completadas';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortDueDateAsc => 'Fecha límite (más reciente primero)';

  @override
  String get sortDueDateDesc => 'Fecha límite (más tardía primero)';

  @override
  String get sortPriorityHighLow => 'Prioridad (alta a baja)';

  @override
  String get sortPriorityLowHigh => 'Prioridad (baja a alta)';

  @override
  String get sortNameAZ => 'Nombre (A–Z)';

  @override
  String get sortNameZA => 'Nombre (Z–A)';

  @override
  String get taskNameLabel => 'Nombre de tarea';

  @override
  String get dueDateLabel => 'Fecha límite';

  @override
  String get dueTimeLabel => 'Hora límite';

  @override
  String get priorityLabel => 'Prioridad';

  @override
  String get assigneeLabel => 'Responsable (opcional)';

  @override
  String get descriptionLabel => 'Descripción (opcional)';

  @override
  String get saveTask => 'Guardar tarea';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get cancel => 'Cancelar';

  @override
  String get allDay => 'Todo el día';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityMedium => 'Media';

  @override
  String get priorityLow => 'Baja';

  @override
  String get taskNameRequired => 'El nombre de la tarea es obligatorio.';

  @override
  String get taskNameTooLong => 'El nombre debe tener 100 caracteres o menos.';

  @override
  String get dueDateRequired => 'La fecha límite es obligatoria.';

  @override
  String get dueTimeRequired => 'La hora límite es obligatoria.';

  @override
  String get priorityRequired => 'La prioridad es obligatoria.';

  @override
  String get markComplete => 'Marcar como completada';

  @override
  String get reopen => 'Reabrir';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get taskAdded => 'Tarea añadida correctamente.';

  @override
  String get taskUpdated => 'Tarea actualizada correctamente.';

  @override
  String get taskDeleted => 'Tarea eliminada.';

  @override
  String get taskMarkedComplete => 'Tarea marcada como completada.';

  @override
  String get taskReopened => 'Tarea reabierta.';

  @override
  String get deleteTaskConfirm => '¿Eliminar esta tarea?';

  @override
  String get deleteTaskBody => 'Esta acción no se puede deshacer.';

  @override
  String get conversations => 'Conversaciones';

  @override
  String get searchConversations => 'Buscar conversaciones…';

  @override
  String get noConversations => 'Sin conversaciones aún.';

  @override
  String get noResults => 'Sin resultados.';

  @override
  String get typeAMessage => 'Escribe un mensaje…';

  @override
  String get startConversation => 'Iniciar conversación';

  @override
  String get newConversation => 'Nueva conversación';

  @override
  String get searchContacts => 'Buscar contactos…';

  @override
  String get noContactsFound => 'Sin contactos encontrados.';

  @override
  String get selectParticipant => 'Selecciona al menos un participante.';

  @override
  String get groupLimit => 'Los grupos se limitan a 50 participantes.';

  @override
  String get tasksCompleted => 'Tareas completadas';

  @override
  String get activeProjects => 'Proyectos activos';

  @override
  String get teamMembers => 'Miembros del equipo';

  @override
  String get recentActivity => 'Actividad reciente';

  @override
  String get noRecentActivity => 'Sin actividad reciente.';

  @override
  String get editProfileSettings => 'Editar perfil';

  @override
  String get avatarUpdateFailed =>
      'No se pudo actualizar el avatar. Inténtalo de nuevo.';

  @override
  String get firstNameLabel => 'Nombre';

  @override
  String get lastNameLabel => 'Apellido';

  @override
  String get roleLabel => 'Cargo / Título (opcional)';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get phoneLabel => 'Teléfono (opcional)';

  @override
  String get save => 'Guardar';

  @override
  String get profileUpdated => 'Perfil actualizado correctamente.';

  @override
  String get profileSaveFailed =>
      'No se pudo guardar el perfil. Inténtalo de nuevo.';

  @override
  String get firstNameRequired => 'El nombre es obligatorio.';

  @override
  String get lastNameRequired => 'El apellido es obligatorio.';

  @override
  String get emailRequired => 'El correo electrónico es obligatorio.';

  @override
  String get emailInvalid => 'Introduce un correo electrónico válido.';

  @override
  String get settings => 'Ajustes';

  @override
  String get accountSettings => 'Cuenta';

  @override
  String get preferences => 'Preferencias';

  @override
  String get supportLegals => 'Soporte y legal';

  @override
  String get personalProfile => 'Perfil personal';

  @override
  String get notificationPreferences => 'Notificaciones';

  @override
  String get securityPrivacy => 'Seguridad y privacidad';

  @override
  String get interfaceTheme => 'Tema de interfaz';

  @override
  String get appLanguage => 'Idioma';

  @override
  String get timeZone => 'Zona horaria';

  @override
  String get helpSupport => 'Ayuda y soporte';

  @override
  String get about => 'Acerca de';

  @override
  String get rateOurApp => 'Valora la app';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get logOutConfirm => '¿Seguro que quieres cerrar sesión?';

  @override
  String get loggedOut => 'Sesión cerrada correctamente.';

  @override
  String get logOutFailed => 'Error al cerrar sesión. Inténtalo de nuevo.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Según el sistema';

  @override
  String get taskReminders => 'Recordatorios de tareas';

  @override
  String get dueDateAlerts => 'Alertas de fecha límite';

  @override
  String get chatMessages => 'Mensajes de chat';

  @override
  String get weeklySummary => 'Resumen semanal';

  @override
  String get prefSaveFailed =>
      'No se pudo guardar la preferencia. Inténtalo de nuevo.';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get biometricLogin => 'Acceso biométrico';

  @override
  String get dataPrivacyPolicy => 'Política de privacidad';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar nueva contraseña';

  @override
  String get passwordChanged => 'Contraseña cambiada correctamente.';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get passwordLength =>
      'La contraseña debe tener entre 8 y 64 caracteres.';

  @override
  String get passwordIncorrect => 'La contraseña actual es incorrecta.';

  @override
  String get passwordSaveFailed =>
      'No se pudo actualizar la contraseña. Inténtalo de nuevo.';

  @override
  String get contactSupport => 'Contactar soporte';

  @override
  String get supportEmail => 'support@planpal.app';

  @override
  String get noEmailApp =>
      'No se encontró una app de correo. Escribe a support@planpal.app directamente.';

  @override
  String get helpLoadFailed =>
      'No se pudo cargar el contenido de ayuda. Inténtalo más tarde.';

  @override
  String get storeOpenFailed =>
      'No se pudo abrir la tienda. Inténtalo más tarde.';

  @override
  String get somethingWentWrong => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get changesSaveFailed =>
      'No se pudieron guardar los cambios. Inténtalo de nuevo.';

  @override
  String get dataLoadFailed =>
      'No se pudieron cargar los datos guardados. Empezando de nuevo.';

  @override
  String get faqTitle => 'Preguntas frecuentes';

  @override
  String get activityCreated => 'creada';

  @override
  String get activityUpdated => 'actualizada';

  @override
  String get activityCompleted => 'completada';

  @override
  String get deletedTask => '[Tarea eliminada]';

  @override
  String get noMessagesYet => 'Sin mensajes aún. ¡Saluda!';

  @override
  String get quickActions => 'Acciones rápidas';
}
