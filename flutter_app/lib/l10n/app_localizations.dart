import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ru'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Wellbeing Monitor',
      'navDashboard': 'Dashboard',
      'navAdd': 'Add',
      'navHistory': 'History',
      'navTips': 'Tips',
      'dashboardWellbeingTitle': 'Wellbeing Index',
      'dashboardWellbeingSubtitleEmpty':
          'No data yet. Add your first mood entry.',
      'dashboardWellbeingSubtitle':
          'Based on your latest mood, stress and energy.',
      'dashboardMoodOverTime': 'Mood Over Time',
      'dashboardMoodNotEnough': 'Not enough data',
      'dashboardMoodNotEnoughSubtitle':
          'At least two entries are needed to show the chart.',
      'dashboardLatestEntry': 'Latest Entry',
      'addTitle': 'How do you feel today?',
      'addSubtitle':
          'Track your mood, stress and energy to see your wellbeing trends.',
      'addMoodLabel': 'Mood',
      'addMoodDesc': 'How positive and calm you feel overall.',
      'addStressLabel': 'Stress',
      'addStressDesc': 'How tense, worried or overloaded you feel.',
      'addEnergyLabel': 'Energy',
      'addEnergyDesc':
          'How awake, motivated and physically active you feel.',
      'addOptionalNote': 'Optional note',
      'addOptionalNoteHint': 'Add a short note about your day…',
      'addCategoryTitle': 'Category (optional)',
      'addCategoryNone': 'No specific category',
      'addCategoryWork': 'Work',
      'addCategoryRelationships': 'Relationships',
      'addCategoryHealth': 'Health',
      'addSleepActivityTitle': 'Sleep & activity (optional)',
      'addSleepLabel': 'Sleep (hours)',
      'addActivityLabel': 'Activity (minutes)',
      'addChangeDate': 'Change',
      'addSave': 'Save',
      'historyEmptyTitle': 'No mood entries yet',
      'historyEmptySubtitle':
          'Start by adding how you feel today to see your history here.',
      'historyFiltersTitle': 'Filters',
      'historyFiltersDate': 'Date range',
      'historyFiltersCategory': 'Category',
      'historyFiltersMoods': 'Mood range',
      'historyFiltersStress': 'Stress range',
      'historyFiltersEnergy': 'Energy range',
      'historyFiltersFrom': 'From',
      'historyFiltersTo': 'To',
      'historyFiltersAny': 'Any',
      'historyNoResults': 'No entries match current filters.',
      'analyticsTitle': 'Analytics',
      'analyticsMoodStress': 'Mood vs stress',
      'analyticsMoodSleep': 'Mood vs sleep',
      'analyticsWeekly': 'Weekly overview',
      'tipsTodayTitle': 'Today\'s guidance',
      'tipsTodaySubtitle':
          'Short tips based on your wellbeing to help you feel better.',
      'tipsPersonalTip': 'Personal tip',
      'tipsIndexPrefix': 'Wellbeing Index: ',
      'tipsIndexHigh': 'You\'re doing great',
      'tipsIndexMedium': 'You\'re in the middle zone',
      'tipsIndexLow': 'You might need extra care',
      'goalsTitle': 'Goals',
      'goalsStreak': 'Current streak',
      'goalsStreakDays': 'days in a row',
      'goalsStressWeekOk': 'Stress has stayed below target this week.',
      'goalsStressWeekHigh':
          'Stress is above target on several days this week.',
      'moodLabel': 'Mood',
      'stressLabel': 'Stress',
      'energyLabel': 'Energy',
      'historyEntrySubtitle': 'Mood history entry',
      'errorPrefix': 'Error: ',
      'settingsTitle': 'Settings',
      'settingsLanguage': 'Language',
      'settingsAppearance': 'Appearance',
      'settingsThemeSystem': 'System',
      'settingsThemeLight': 'Light',
      'settingsThemeDark': 'Dark',
      'settingsAbout': 'About',
      'settingsAboutBody': 'Track mood, stress and energy. Data syncs with your own backend.',
      'settingsApiHint': 'Backend URL is auto-selected per platform. Override with --dart-define=API_BASE_URL=…',
      'settingsVersion': 'Version',
      'languageEnglish': 'English',
      'languageRussian': 'Русский',
      'editEntry': 'Edit',
      'deleteEntry': 'Delete',
      'entryDeleted': 'Entry deleted',
      'entryUpdated': 'Entry updated',
      'entrySaved': 'Mood entry saved',
      'quickAddTitle': 'Quick add',
      'quickAddSubtitle': 'Same as last time',
      'compareTitle': 'This week vs last week',
      'thisWeek': 'This week',
      'lastWeek': 'Last week',
      'deleteConfirmTitle': 'Delete entry?',
      'deleteConfirmMessage': 'This action cannot be undone.',
      'cancel': 'Cancel',
      'tipsForYou': 'For you',
      'tipsCategoryAll': 'All',
      'tipsCategoryBreathing': 'Breathing',
      'tipsCategoryMovement': 'Movement',
      'tipsCategorySleep': 'Sleep',
      'tipsCategoryMindset': 'Mindset',
      'tipsCategoryQuickBreaks': 'Quick breaks',
      'tipsSaved': 'Saved',
      'tipsWhyHelp': 'Why it helps',
      'tipsHowToDo': 'How to do it',
      'tipsSave': 'Save',
      'tipsSavedLabel': 'Saved',
      'tipsStartBreathing': 'Start 2 min breathing',
      'tipsLogWalk': 'Log a walk',
      'tipsBreathTitle': '4-7-8 breathing',
      'tipsBreathSubtitle': 'Follow the phases. About 2 minutes, 4 cycles.',
      'tipsBreathStart': 'Start',
      'tipsBreathInhale': 'Inhale',
      'tipsBreathHold': 'Hold',
      'tipsBreathExhale': 'Exhale',
      'tipsBreathCycle': 'Cycle',
      'tipsMyTips': 'My tips',
      'tipsLogWalkConfirm': 'Add a 15 min walk to today?',
      'tipsLogWalkDone': 'Walk logged',
    },
    'ru': {
      'appTitle': 'Монитор благополучия',
      'navDashboard': 'Главная',
      'navAdd': 'Запись',
      'navHistory': 'История',
      'navTips': 'Советы',
      'dashboardWellbeingTitle': 'Индекс благополучия',
      'dashboardWellbeingSubtitleEmpty':
          'Пока нет данных. Добавьте первую запись о настроении.',
      'dashboardWellbeingSubtitle':
          'Основано на вашем последнем настроении, стрессе и энергии.',
      'dashboardMoodOverTime': 'Настроение во времени',
      'dashboardMoodNotEnough': 'Недостаточно данных',
      'dashboardMoodNotEnoughSubtitle':
          'Нужно хотя бы две записи, чтобы показать график.',
      'dashboardLatestEntry': 'Последняя запись',
      'addTitle': 'Как вы чувствуете себя сегодня?',
      'addSubtitle':
          'Отслеживайте настроение, стресс и энергию, чтобы видеть динамику.',
      'addMoodLabel': 'Настроение',
      'addMoodDesc': 'Насколько вы чувствуете себя спокойным и позитивным.',
      'addStressLabel': 'Стресс',
      'addStressDesc': 'Насколько вы напряжены, тревожны или перегружены.',
      'addEnergyLabel': 'Энергия',
      'addEnergyDesc':
          'Насколько вы бодры, мотивированы и физически активны.',
      'addOptionalNote': 'Дополнительная заметка',
      'addOptionalNoteHint': 'Коротко опишите, как прошёл день…',
      'addCategoryTitle': 'Категория (необязательно)',
      'addCategoryNone': 'Без категории',
      'addCategoryWork': 'Работа',
      'addCategoryRelationships': 'Отношения',
      'addCategoryHealth': 'Здоровье',
      'addSleepActivityTitle': 'Сон и активность (необязательно)',
      'addSleepLabel': 'Сон (часов)',
      'addActivityLabel': 'Активность (минут)',
      'addChangeDate': 'Изменить',
      'addSave': 'Сохранить',
      'historyEmptyTitle': 'Пока нет записей',
      'historyEmptySubtitle':
          'Начните с первой записи о самочувствии, и здесь появится история.',
      'historyFiltersTitle': 'Фильтры',
      'historyFiltersDate': 'Диапазон дат',
      'historyFiltersCategory': 'Категория',
      'historyFiltersMoods': 'Диапазон настроения',
      'historyFiltersStress': 'Диапазон стресса',
      'historyFiltersEnergy': 'Диапазон энергии',
      'historyFiltersFrom': 'С',
      'historyFiltersTo': 'По',
      'historyFiltersAny': 'Любая',
      'historyNoResults': 'Нет записей, подходящих под текущие фильтры.',
      'analyticsTitle': 'Аналитика',
      'analyticsMoodStress': 'Настроение и стресс',
      'analyticsMoodSleep': 'Настроение и сон',
      'analyticsWeekly': 'Недельный обзор',
      'tipsTodayTitle': 'Рекомендации на сегодня',
      'tipsTodaySubtitle':
          'Короткие советы на основе вашего состояния, чтобы помочь чувствовать себя лучше.',
      'tipsPersonalTip': 'Персональный совет',
      'tipsIndexPrefix': 'Индекс благополучия: ',
      'tipsIndexHigh': 'У вас всё хорошо',
      'tipsIndexMedium': 'Состояние в среднем диапазоне',
      'tipsIndexLow': 'Сейчас вам может понадобиться больше заботы о себе',
      'goalsTitle': 'Цели',
      'goalsStreak': 'Текущая серия',
      'goalsStreakDays': 'дней подряд',
      'goalsStressWeekOk':
          'Стресс на этой неделе в пределах целевого уровня.',
      'goalsStressWeekHigh':
          'Стресс выше целевого уровня несколько дней на этой неделе.',
      'moodLabel': 'Настроение',
      'stressLabel': 'Стресс',
      'energyLabel': 'Энергия',
      'historyEntrySubtitle': 'Запись истории настроения',
      'errorPrefix': 'Ошибка: ',
      'settingsTitle': 'Настройки',
      'settingsLanguage': 'Язык',
      'settingsAppearance': 'Оформление',
      'settingsThemeSystem': 'Как в системе',
      'settingsThemeLight': 'Светлая',
      'settingsThemeDark': 'Тёмная',
      'settingsAbout': 'О приложении',
      'settingsAboutBody': 'Учёт настроения, стресса и энергии. Данные синхронизируются с вашим сервером.',
      'settingsApiHint': 'Адрес API подбирается под платформу. Свой URL: --dart-define=API_BASE_URL=…',
      'settingsVersion': 'Версия',
      'languageEnglish': 'English',
      'languageRussian': 'Русский',
      'editEntry': 'Изменить',
      'deleteEntry': 'Удалить',
      'entryDeleted': 'Запись удалена',
      'entryUpdated': 'Запись обновлена',
      'entrySaved': 'Запись о настроении сохранена',
      'quickAddTitle': 'Быстрая запись',
      'quickAddSubtitle': 'Как в прошлый раз',
      'compareTitle': 'Эта неделя и прошлая',
      'thisWeek': 'Эта неделя',
      'lastWeek': 'Прошлая неделя',
      'deleteConfirmTitle': 'Удалить запись?',
      'deleteConfirmMessage': 'Действие нельзя отменить.',
      'cancel': 'Отмена',
      'tipsForYou': 'Для вас',
      'tipsCategoryAll': 'Все',
      'tipsCategoryBreathing': 'Дыхание',
      'tipsCategoryMovement': 'Движение',
      'tipsCategorySleep': 'Сон',
      'tipsCategoryMindset': 'Настрой',
      'tipsCategoryQuickBreaks': 'Быстрые перерывы',
      'tipsSaved': 'Избранное',
      'tipsWhyHelp': 'Почему это помогает',
      'tipsHowToDo': 'Как делать',
      'tipsSave': 'Сохранить',
      'tipsSavedLabel': 'Сохранено',
      'tipsStartBreathing': 'Запустить дыхание 2 мин',
      'tipsLogWalk': 'Записать прогулку',
      'tipsBreathTitle': 'Дыхание 4-7-8',
      'tipsBreathSubtitle': 'Следуйте фазам. Около 2 минут, 4 цикла.',
      'tipsBreathStart': 'Старт',
      'tipsBreathInhale': 'Вдох',
      'tipsBreathHold': 'Задержка',
      'tipsBreathExhale': 'Выдох',
      'tipsBreathCycle': 'Цикл',
      'tipsMyTips': 'Мои советы',
      'tipsLogWalkConfirm': 'Добавить прогулку 15 мин на сегодня?',
      'tipsLogWalkDone': 'Прогулка добавлена',
    },
  };

  String _text(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  String get appTitle => _text('appTitle');
  String get navDashboard => _text('navDashboard');
  String get navAdd => _text('navAdd');
  String get navHistory => _text('navHistory');
  String get navTips => _text('navTips');

  String get dashboardWellbeingTitle => _text('dashboardWellbeingTitle');
  String get dashboardWellbeingSubtitleEmpty =>
      _text('dashboardWellbeingSubtitleEmpty');
  String get dashboardWellbeingSubtitle =>
      _text('dashboardWellbeingSubtitle');
  String get dashboardMoodOverTime => _text('dashboardMoodOverTime');
  String get dashboardMoodNotEnough => _text('dashboardMoodNotEnough');
  String get dashboardMoodNotEnoughSubtitle =>
      _text('dashboardMoodNotEnoughSubtitle');
  String get dashboardLatestEntry => _text('dashboardLatestEntry');

  String get addTitle => _text('addTitle');
  String get addSubtitle => _text('addSubtitle');
  String get addMoodLabel => _text('addMoodLabel');
  String get addMoodDesc => _text('addMoodDesc');
  String get addStressLabel => _text('addStressLabel');
  String get addStressDesc => _text('addStressDesc');
  String get addEnergyLabel => _text('addEnergyLabel');
  String get addEnergyDesc => _text('addEnergyDesc');
  String get addOptionalNote => _text('addOptionalNote');
  String get addOptionalNoteHint => _text('addOptionalNoteHint');
  String get addCategoryTitle => _text('addCategoryTitle');
  String get addCategoryNone => _text('addCategoryNone');
  String get addCategoryWork => _text('addCategoryWork');
  String get addCategoryRelationships => _text('addCategoryRelationships');
  String get addCategoryHealth => _text('addCategoryHealth');
  String get addSleepActivityTitle => _text('addSleepActivityTitle');
  String get addSleepLabel => _text('addSleepLabel');
  String get addActivityLabel => _text('addActivityLabel');
  String get addChangeDate => _text('addChangeDate');
  String get addSave => _text('addSave');

  String get historyEmptyTitle => _text('historyEmptyTitle');
  String get historyEmptySubtitle => _text('historyEmptySubtitle');
  String get historyFiltersTitle => _text('historyFiltersTitle');
  String get historyFiltersDate => _text('historyFiltersDate');
  String get historyFiltersCategory => _text('historyFiltersCategory');
  String get historyFiltersMoods => _text('historyFiltersMoods');
  String get historyFiltersStress => _text('historyFiltersStress');
  String get historyFiltersEnergy => _text('historyFiltersEnergy');
  String get historyFiltersFrom => _text('historyFiltersFrom');
  String get historyFiltersTo => _text('historyFiltersTo');
  String get historyFiltersAny => _text('historyFiltersAny');
  String get historyNoResults => _text('historyNoResults');

  String get analyticsTitle => _text('analyticsTitle');
  String get analyticsMoodStress => _text('analyticsMoodStress');
  String get analyticsMoodSleep => _text('analyticsMoodSleep');
  String get analyticsWeekly => _text('analyticsWeekly');

  String get tipsTodayTitle => _text('tipsTodayTitle');
  String get tipsTodaySubtitle => _text('tipsTodaySubtitle');
  String get tipsPersonalTip => _text('tipsPersonalTip');
  String get tipsIndexPrefix => _text('tipsIndexPrefix');
  String get tipsIndexHigh => _text('tipsIndexHigh');
  String get tipsIndexMedium => _text('tipsIndexMedium');
  String get tipsIndexLow => _text('tipsIndexLow');

  String get goalsTitle => _text('goalsTitle');
  String get goalsStreak => _text('goalsStreak');
  String get goalsStreakDays => _text('goalsStreakDays');
  String get goalsStressWeekOk => _text('goalsStressWeekOk');
  String get goalsStressWeekHigh => _text('goalsStressWeekHigh');

  String get moodLabel => _text('moodLabel');
  String get stressLabel => _text('stressLabel');
  String get energyLabel => _text('energyLabel');
  String get historyEntrySubtitle => _text('historyEntrySubtitle');
  String get errorPrefix => _text('errorPrefix');

  String get settingsTitle => _text('settingsTitle');
  String get settingsLanguage => _text('settingsLanguage');
  String get settingsAppearance => _text('settingsAppearance');
  String get settingsThemeSystem => _text('settingsThemeSystem');
  String get settingsThemeLight => _text('settingsThemeLight');
  String get settingsThemeDark => _text('settingsThemeDark');
  String get settingsAbout => _text('settingsAbout');
  String get settingsAboutBody => _text('settingsAboutBody');
  String get settingsApiHint => _text('settingsApiHint');
  String get settingsVersion => _text('settingsVersion');
  String get languageEnglish => _text('languageEnglish');
  String get languageRussian => _text('languageRussian');
  String get editEntry => _text('editEntry');
  String get deleteEntry => _text('deleteEntry');
  String get entryDeleted => _text('entryDeleted');
  String get entryUpdated => _text('entryUpdated');
  String get entrySaved => _text('entrySaved');
  String get quickAddTitle => _text('quickAddTitle');
  String get quickAddSubtitle => _text('quickAddSubtitle');
  String get compareTitle => _text('compareTitle');
  String get thisWeek => _text('thisWeek');
  String get lastWeek => _text('lastWeek');
  String get deleteConfirmTitle => _text('deleteConfirmTitle');
  String get deleteConfirmMessage => _text('deleteConfirmMessage');
  String get cancel => _text('cancel');

  String get tipsForYou => _text('tipsForYou');
  String get tipsCategoryAll => _text('tipsCategoryAll');
  String get tipsCategoryBreathing => _text('tipsCategoryBreathing');
  String get tipsCategoryMovement => _text('tipsCategoryMovement');
  String get tipsCategorySleep => _text('tipsCategorySleep');
  String get tipsCategoryMindset => _text('tipsCategoryMindset');
  String get tipsCategoryQuickBreaks => _text('tipsCategoryQuickBreaks');
  String get tipsSaved => _text('tipsSaved');
  String get tipsWhyHelp => _text('tipsWhyHelp');
  String get tipsHowToDo => _text('tipsHowToDo');
  String get tipsSave => _text('tipsSave');
  String get tipsSavedLabel => _text('tipsSavedLabel');
  String get tipsStartBreathing => _text('tipsStartBreathing');
  String get tipsLogWalk => _text('tipsLogWalk');
  String get tipsBreathTitle => _text('tipsBreathTitle');
  String get tipsBreathSubtitle => _text('tipsBreathSubtitle');
  String get tipsBreathStart => _text('tipsBreathStart');
  String get tipsBreathInhale => _text('tipsBreathInhale');
  String get tipsBreathHold => _text('tipsBreathHold');
  String get tipsBreathExhale => _text('tipsBreathExhale');
  String get tipsBreathCycle => _text('tipsBreathCycle');
  String get tipsMyTips => _text('tipsMyTips');
  String get tipsLogWalkConfirm => _text('tipsLogWalkConfirm');
  String get tipsLogWalkDone => _text('tipsLogWalkDone');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .map((e) => e.languageCode)
          .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

