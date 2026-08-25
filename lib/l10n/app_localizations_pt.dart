// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'PlanPal';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription =>
      'O PlanPal ajuda você a gerenciar tarefas, acompanhar o progresso e colaborar com sua equipe, tudo em um só lugar.';

  @override
  String get goodMorning => 'Bom dia';

  @override
  String get goodAfternoon => 'Boa tarde';

  @override
  String get goodEvening => 'Boa noite';

  @override
  String taskCountSubtitle(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você tem $countString tarefas para hoje.',
      one: 'Você tem 1 tarefa para hoje.',
      zero: 'Você não tem tarefas para hoje.',
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Início';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Configurações';

  @override
  String get todaysTasks => 'Tarefas de hoje';

  @override
  String get viewAll => 'Ver tudo';

  @override
  String get noTasksToday => 'Sem tarefas hoje. Aproveite o dia!';

  @override
  String get newTask => 'Nova tarefa';

  @override
  String get calendar => 'Calendário';

  @override
  String get analytics => 'Análises';

  @override
  String get documents => 'Documentos';

  @override
  String get comingSoon => 'Em breve!';

  @override
  String get performanceOverview => 'Visão geral de desempenho';

  @override
  String get completed => 'Concluídas';

  @override
  String get inProgress => 'Em andamento';

  @override
  String get overdue => 'Atrasadas';

  @override
  String get productivity => 'Produtividade';

  @override
  String get myTasks => 'Minhas tarefas';

  @override
  String get noTasksEmpty => 'Sem tarefas aqui. Adicione uma!';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterToday => 'Hoje';

  @override
  String get filterUpcoming => 'Próximas';

  @override
  String get filterCompleted => 'Concluídas';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortDueDateAsc => 'Data de vencimento (mais próxima primeiro)';

  @override
  String get sortDueDateDesc => 'Data de vencimento (mais distante primeiro)';

  @override
  String get sortPriorityHighLow => 'Prioridade (alta para baixa)';

  @override
  String get sortPriorityLowHigh => 'Prioridade (baixa para alta)';

  @override
  String get sortNameAZ => 'Nome (A–Z)';

  @override
  String get sortNameZA => 'Nome (Z–A)';

  @override
  String get taskNameLabel => 'Nome da tarefa';

  @override
  String get dueDateLabel => 'Data de vencimento';

  @override
  String get dueTimeLabel => 'Hora de vencimento';

  @override
  String get priorityLabel => 'Prioridade';

  @override
  String get assigneeLabel => 'Responsável (opcional)';

  @override
  String get descriptionLabel => 'Descrição (opcional)';

  @override
  String get saveTask => 'Salvar tarefa';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get cancel => 'Cancelar';

  @override
  String get allDay => 'O dia todo';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityMedium => 'Média';

  @override
  String get priorityLow => 'Baixa';

  @override
  String get taskNameRequired => 'O nome da tarefa é obrigatório.';

  @override
  String get taskNameTooLong => 'O nome deve ter no máximo 100 caracteres.';

  @override
  String get dueDateRequired => 'A data de vencimento é obrigatória.';

  @override
  String get dueTimeRequired => 'A hora de vencimento é obrigatória.';

  @override
  String get priorityRequired => 'A prioridade é obrigatória.';

  @override
  String get markComplete => 'Marcar como concluída';

  @override
  String get reopen => 'Reabrir';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get taskAdded => 'Tarefa adicionada com sucesso.';

  @override
  String get taskUpdated => 'Tarefa atualizada com sucesso.';

  @override
  String get taskDeleted => 'Tarefa excluída.';

  @override
  String get taskMarkedComplete => 'Tarefa marcada como concluída.';

  @override
  String get taskReopened => 'Tarefa reaberta.';

  @override
  String get deleteTaskConfirm => 'Excluir esta tarefa?';

  @override
  String get deleteTaskBody => 'Esta ação não pode ser desfeita.';

  @override
  String get conversations => 'Conversas';

  @override
  String get searchConversations => 'Pesquisar conversas…';

  @override
  String get noConversations => 'Nenhuma conversa ainda.';

  @override
  String get noResults => 'Nenhum resultado encontrado.';

  @override
  String get typeAMessage => 'Digite uma mensagem…';

  @override
  String get startConversation => 'Iniciar conversa';

  @override
  String get newConversation => 'Nova conversa';

  @override
  String get searchContacts => 'Pesquisar contatos…';

  @override
  String get noContactsFound => 'Nenhum contato encontrado.';

  @override
  String get selectParticipant => 'Selecione pelo menos um participante.';

  @override
  String get groupLimit =>
      'Conversas em grupo são limitadas a 50 participantes.';

  @override
  String get tasksCompleted => 'Tarefas concluídas';

  @override
  String get activeProjects => 'Projetos ativos';

  @override
  String get teamMembers => 'Membros da equipe';

  @override
  String get recentActivity => 'Atividade recente';

  @override
  String get noRecentActivity => 'Sem atividade recente.';

  @override
  String get editProfileSettings => 'Editar perfil';

  @override
  String get avatarUpdateFailed =>
      'Não foi possível atualizar o avatar. Tente novamente.';

  @override
  String get firstNameLabel => 'Nome';

  @override
  String get lastNameLabel => 'Sobrenome';

  @override
  String get roleLabel => 'Cargo / Título (opcional)';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get phoneLabel => 'Telefone (opcional)';

  @override
  String get save => 'Salvar';

  @override
  String get profileUpdated => 'Perfil atualizado com sucesso.';

  @override
  String get profileSaveFailed =>
      'Não foi possível salvar o perfil. Tente novamente.';

  @override
  String get firstNameRequired => 'O nome é obrigatório.';

  @override
  String get lastNameRequired => 'O sobrenome é obrigatório.';

  @override
  String get emailRequired => 'O e-mail é obrigatório.';

  @override
  String get emailInvalid => 'Insira um endereço de e-mail válido.';

  @override
  String get settings => 'Configurações';

  @override
  String get accountSettings => 'Conta';

  @override
  String get preferences => 'Preferências';

  @override
  String get supportLegals => 'Suporte e jurídico';

  @override
  String get personalProfile => 'Perfil pessoal';

  @override
  String get notificationPreferences => 'Notificações';

  @override
  String get securityPrivacy => 'Segurança e privacidade';

  @override
  String get interfaceTheme => 'Tema da interface';

  @override
  String get appLanguage => 'Idioma';

  @override
  String get timeZone => 'Fuso horário';

  @override
  String get helpSupport => 'Ajuda e suporte';

  @override
  String get about => 'Sobre';

  @override
  String get rateOurApp => 'Avaliar o app';

  @override
  String get logOut => 'Sair';

  @override
  String get logOutConfirm => 'Tem certeza que deseja sair?';

  @override
  String get loggedOut => 'Você saiu da conta.';

  @override
  String get logOutFailed => 'Falha ao sair. Tente novamente.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Padrão do sistema';

  @override
  String get taskReminders => 'Lembretes de tarefas';

  @override
  String get dueDateAlerts => 'Alertas de vencimento';

  @override
  String get chatMessages => 'Mensagens de chat';

  @override
  String get weeklySummary => 'Resumo semanal';

  @override
  String get prefSaveFailed =>
      'Não foi possível salvar a preferência. Tente novamente.';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get biometricLogin => 'Login biométrico';

  @override
  String get dataPrivacyPolicy => 'Política de privacidade';

  @override
  String get currentPassword => 'Senha atual';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get confirmPassword => 'Confirmar nova senha';

  @override
  String get passwordChanged => 'Senha alterada com sucesso.';

  @override
  String get passwordMismatch => 'As senhas não coincidem.';

  @override
  String get passwordLength => 'A senha deve ter entre 8 e 64 caracteres.';

  @override
  String get passwordIncorrect => 'A senha atual está incorreta.';

  @override
  String get passwordSaveFailed =>
      'Não foi possível atualizar a senha. Tente novamente.';

  @override
  String get contactSupport => 'Contatar suporte';

  @override
  String get supportEmail => 'support@planpal.app';

  @override
  String get noEmailApp =>
      'Nenhum app de e-mail encontrado. Envie um e-mail para support@planpal.app diretamente.';

  @override
  String get helpLoadFailed =>
      'Não foi possível carregar o conteúdo de ajuda. Tente mais tarde.';

  @override
  String get storeOpenFailed =>
      'Não foi possível abrir a loja. Tente mais tarde.';

  @override
  String get somethingWentWrong => 'Algo deu errado. Tente novamente.';

  @override
  String get changesSaveFailed =>
      'Não foi possível salvar as alterações. Tente novamente.';

  @override
  String get dataLoadFailed =>
      'Não foi possível carregar os dados salvos. Iniciando do zero.';

  @override
  String get faqTitle => 'Perguntas frequentes';

  @override
  String get activityCreated => 'criada';

  @override
  String get activityUpdated => 'atualizada';

  @override
  String get activityCompleted => 'concluída';

  @override
  String get deletedTask => '[Tarefa excluída]';

  @override
  String get noMessagesYet => 'Nenhuma mensagem ainda. Diga olá!';

  @override
  String get quickActions => 'Ações rápidas';
}
