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
      'brandName': 'Serenity',
      'navDashboard': 'Dashboard',
      'navAdd': 'Add',
      'navHistory': 'History',
      'navTips': 'Tips',
      'dashboardWellbeingTitle': 'Wellbeing Index',
      'dashboardWellbeingSubtitleEmpty':
          'No data yet. Add your first mood entry.',
      'dashboardWellbeingSubtitle':
          'Based on your latest mood, stress and energy.',
      'dashboardWellbeingRawFormat': 'Linear score: {n} (same formula as the server)',
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
      'apiErrorNoInternet': 'No internet connection. Check Wi‑Fi or mobile data.',
      'apiErrorTimeout': 'The server took too long to respond. Try again shortly.',
      'apiErrorNetwork': 'Could not reach the server. Check the address in Settings.',
      'apiErrorServer': 'The server returned an error. Try again in a moment.',
      'apiErrorClient': 'The request could not be completed.',
      'apiErrorUnknown': 'Something went wrong. Try again.',
      'errorStateTitle': 'Something went wrong',
      'errorNetworkHint':
          'Check your connection and that the API server is running (see Settings).',
      'errorServerHint': 'The server had a problem. Try again in a moment.',
      'errorRetry': 'Try again',
      'dashboardEmptyTitle': 'No mood data yet',
      'dashboardEmptySubtitle':
          'Add your first entry to see wellbeing, trends and risk on this screen.',
      'dashboardEmptyCta': 'Add mood entry',
      'quickLogTitle': 'Quick mood log',
      'quickLogSubtitle':
          'Prefilled from your last entry — adjust sliders, then save.',
      'quickLogPrimaryCta': 'Customize & save',
      'quickLogSheetSave': 'Save entry',
      'quickLogSheetCancel': 'Cancel',
      'quickLogSheetReset': 'Reset to last entry',
      'quickLogSheetNote': 'Note (optional)',
      'quickLogSheetAdvanced': 'Sleep, activity & category',
      'quickLogSheetSaving': 'Saving…',
      'tipsChipWeek': 'Last 7 days',
      'dashboardGreetingMorning': 'Good morning',
      'dashboardGreetingAfternoon': 'Good afternoon',
      'dashboardGreetingEvening': 'Good evening',
      'dashboardHeroSub':
          'Take a breath — this is your calm space to notice how you feel.',
      'moodJourneyTitle': 'Mood Journey',
      'moodJourneySubtitle':
          'A calm view of your last 7 check-ins — and what patterns show up.',
      'moodJourneyTrendUp': 'Your mood is gently lifting.',
      'moodJourneyTrendDown': 'Your mood feels a bit softer lately.',
      'moodJourneyTrendSteady': 'Your mood looks steady.',
      'moodJourneyStressHint':
          'You often feel calmer when stress stays low.',
      'moodJourneyActivityHint':
          'Days with more activity often feel brighter.',
      'moodJourneyReflectionPrompt':
          'What helped you feel better today? (A quick note is enough.)',
      'dashboardInsightStressDown':
          'Your stress tends to ease after consistent check-ins.',
      'dashboardInsightMoodUp':
          'Your mood often lifts when you keep showing up.',
      'dashboardInsightSteady':
          'Small check-ins help you stay steady through the day.',
      'dashboardInsightConsistency':
          'Consistency creates gentle momentum.',
      'dashboardQuickActionsTitle': 'Quick wellness',
      'quickActionBreathing': 'Breathing',
      'quickActionJournal': 'Journal',
      'quickActionStretch': 'Stretch',
      'quickActionWater': 'Water break',
      'quickActionWalk': 'Walk',
      'dashboardCheckInTitle': 'How are you feeling right now?',
      'checkInOptionCalm': 'Calm',
      'checkInOptionTired': 'Tired',
      'checkInOptionStressed': 'Stressed',
      'checkInOptionMotivated': 'Motivated',
      'checkInSave': 'Save check-in',
      'checkInSaved': 'Check-in saved',
      'todayCompletedActions': 'You completed ',
      'todayCompletedActionsSuffix': ' wellness actions today',
      'todayStreakSuffix': ' day streak',
      'dashboardPracticesTitle': 'Today’s care',
      'dashboardPracticesTracking': 'Check-in and quick practices you finish today',
      'dashboardPracticesProgress': '{done} of {total}',
      'dashboardPracticesStreak': '{n}-day streak',
      'dashboardPracticesStreakSingle': '1-day streak',
      'dashboardPracticesEncourage':
          'Tap a check-in or a quick practice below — each step fills this row.',
      'dashboardPracticeCheckin': 'Check-in',
      'dashboardWellbeingEmptyHeadline': 'No snapshot yet',
      'dashboardWellbeingRingLabel': 'balance (0–100)',
      'dashboardWellbeingScaleTitle': 'How to read the ring',
      'dashboardWellbeingZoneLowShort': '0–33 heavier load',
      'dashboardWellbeingZoneMidShort': '34–66 usual day',
      'dashboardWellbeingZoneHighShort': '67–100 more ease',
      'dashboardWellbeingScaleFootnote':
          'The number mixes your last mood, stress and energy (same as the server). Very low values can happen on hard days — they are a guide, not a diagnosis.',
      'quickActionStretchDetail':
          'A few gentle moves for your neck and shoulders.',
      'quickActionWaterDetail':
          'Drink a glass slowly and reset your posture.',
      'recBenefitBreathing': 'Less tension and a calmer body in about two minutes.',
      'recBenefitWalk': 'A gentle lift in energy and less tension after a short walk.',
      'recBenefitGeneric': 'A small step that helps your state feel more aligned.',
      'recDurBreathing': '2 min',
      'recDurMovement': '10–15 min',
      'recDurQuickBreak': '1–2 min',
      'recDurSleep': '10–15 min',
      'recDurMindset': '1 min',
      'recDurDefault': 'A few minutes',
      'breathUiClose': 'Close',
      'breathUiReadyTitle': '4‑7‑8 breathing',
      'breathUiReadySubtitle':
          'Inhale 4s, hold 7s, exhale 8s — four cycles, about two minutes. Sit comfortably, shoulders relaxed.',
      'breathUiStep1': 'Inhale through the nose for 4 seconds.',
      'breathUiStep2': 'Hold the breath for 7 seconds.',
      'breathUiStep3': 'Exhale slowly through the mouth for 8 seconds.',
      'breathUiSec': 'sec',
      'breathUiCycles': 'Cycles',
      'breathUiStart': 'Begin session',
      'breathUiStop': 'Stop',
      'breathUiDone': 'Session complete',
      'breathUiRunningFooter': 'Follow the ring — it fills as the current phase completes.',
      'wellbeingStateHigh': 'Feeling steady',
      'wellbeingStateMedium': 'Room to recharge',
      'wellbeingStateLow': 'Go gently today',
      'wellbeingHintHigh': 'Your latest check-in looks solid — keep what already helps.',
      'wellbeingHintMedium':
          'Small pauses, sleep and movement usually nudge this number up.',
      'wellbeingHintLow':
          'One short walk, water or breathing can soften the day — pick what feels easiest.',
      'recDetailsExpectedBenefit': 'Expected benefit',
      'recDetailsEstimatedDuration': 'Estimated duration',
      'recDetailsActionSteps': 'Action steps',
      'recDetailsDoneForToday': 'Done for today',
      'recDetailsDismiss': 'Dismiss',
      'recDetailsHelpful': 'Helpful',
      'recDetailsNotHelpful': 'Not for me',
      'recDoneBadge': 'Done',
      'tipsEmptyTitle': 'No recommendations right now',
      'tipsEmptySubtitle':
          'Try a quick breathing session or do a fast check-in.',
      'historyInsightsTitle': 'Insights',
      'historyInsightsSubtitle':
          'Patterns from your check-ins, without the noise.',
      'historyTabList': 'Entries',
      'historyTabAnalytics': 'Trends',
      'historyDailyEntries': 'Your entries',
      'historyWeeklySummary': 'Weekly summary',
      'historyDominantMoodCalm': 'Calm',
      'historyDominantMoodBalanced': 'Balanced',
      'historyDominantMoodAnxious': 'Anxious',
      'historyDominantMoodSubtitle':
          'is your dominant mood across the week',
      'addJournalTitle': 'Journal',
      'dashboardRiskTitle': 'Tomorrow readiness',
      'dashboardRiskLevelHigh': 'Higher load',
      'dashboardRiskLevelModerate': 'Balanced',
      'dashboardRiskLevelLow': 'Gentle pace',
      'dashboardRiskForDate': 'Outlook window: {date}',
      'dashboardRiskSignalsTitle': 'What shaped this score',
      'dashboardRiskMethodNote':
          'This uses recent averages for stress, mood and sleep, plus whether mood has been trending down. It is a simple guide — not a clinical forecast.',
      'dashboardRiskSuggestionInsufficient':
          'Log mood for a few more days to unlock a fuller outlook.',
      'dashboardRiskFactorPattern': '{name} · {impact}',
      'dashboardRiskImpactNegative': 'adds load',
      'dashboardRiskImpactNeutral': 'neutral',
      'dashboardRiskImpactPositive': 'eases load',
      'tipsDashboardTapHint': 'Tap a card for steps and actions',
      'dashboardRiskSuggestionHigh':
          'A short wind‑down tonight can deepen sleep and soften tomorrow.',
      'dashboardRiskSuggestionLow':
          'Your buffer looks healthy — keep the day gentle and consistent.',
      'dashboardRiskExtraForecast': 'Based on your recent patterns.',
      'dashboardRiskExtraHeuristic': 'From sleep and stress in your latest logs.',
      'tipsDashboardSun': 'Morning light for 10 minutes',
      'tipsDashboardCalm': 'Two minutes of slow breathing',
      'tipsDashboardSleep': 'Ease caffeine after 2 pm',
      'tipsPersonalizeHint':
          'Add a mood entry on the home screen to get a personal tip here.',
      'tipsFeedbackThanks': 'Thanks for your feedback',
      'tipsLikeTooltip': 'Helpful',
      'tipsDislikeTooltip': 'Not for me',
      'settingsTitle': 'Settings',
      'settingsLanguage': 'Language',
      'settingsAppearance': 'Appearance',
      'settingsThemeSystem': 'System',
      'settingsThemeLight': 'Light',
      'settingsThemeDark': 'Dark',
      'settingsAbout': 'About',
      'settingsAboutBody': 'Track mood, stress and energy. Data syncs with your own backend.',
      'settingsAboutSerenity':
          'Why Serenity? The name stands for a calm, clear state of mind — like a quiet moment after a deep breath. The app is built to help you notice how you feel without judgment, one small step at a time.',
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
      'brandName': 'Серенити',
      'navDashboard': 'Главная',
      'navAdd': 'Запись',
      'navHistory': 'История',
      'navTips': 'Советы',
      'dashboardWellbeingTitle': 'Индекс благополучия',
      'dashboardWellbeingSubtitleEmpty':
          'Пока нет данных. Добавьте первую запись о настроении.',
      'dashboardWellbeingSubtitle':
          'Основано на вашем последнем настроении, стрессе и энергии.',
      'dashboardWellbeingRawFormat': 'Индекс (как на сервере): {n}',
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
      'apiErrorNoInternet': 'Нет подключения к интернету. Проверьте Wi‑Fi или мобильные данные.',
      'apiErrorTimeout': 'Сервер слишком долго не отвечает. Попробуйте чуть позже.',
      'apiErrorNetwork': 'Не удалось связаться с сервером. Проверьте адрес в настройках.',
      'apiErrorServer': 'Сервер вернул ошибку. Попробуйте ещё раз через минуту.',
      'apiErrorClient': 'Запрос не выполнен.',
      'apiErrorUnknown': 'Что-то пошло не так. Попробуйте снова.',
      'errorStateTitle': 'Что-то пошло не так',
      'errorNetworkHint':
          'Проверьте интернет и что сервер API запущен (см. Настройки).',
      'errorServerHint': 'На сервере ошибка. Попробуйте чуть позже.',
      'errorRetry': 'Повторить',
      'dashboardEmptyTitle': 'Пока нет данных о настроении',
      'dashboardEmptySubtitle':
          'Добавьте первую запись, чтобы здесь появились индекс, графики и риск.',
      'dashboardEmptyCta': 'Добавить запись',
      'quickLogTitle': 'Быстрая запись настроения',
      'quickLogSubtitle':
          'Подставлены значения из последней записи — измените при необходимости и сохраните.',
      'quickLogPrimaryCta': 'Настроить и сохранить',
      'quickLogSheetSave': 'Сохранить запись',
      'quickLogSheetCancel': 'Отмена',
      'quickLogSheetReset': 'Как в последней записи',
      'quickLogSheetNote': 'Заметка (необязательно)',
      'quickLogSheetAdvanced': 'Сон, активность и категория',
      'quickLogSheetSaving': 'Сохранение…',
      'tipsChipWeek': '7 дней',
      'dashboardGreetingMorning': 'Доброе утро',
      'dashboardGreetingAfternoon': 'Добрый день',
      'dashboardGreetingEvening': 'Добрый вечер',
      'dashboardHeroSub':
          'Выдохните — здесь можно спокойно заметить, как вы себя чувствуете.',
      'moodJourneyTitle': 'Путешествие настроения',
      'moodJourneySubtitle':
          'Спокойный взгляд на ваши последние 7 чек‑инов — и заметные паттерны.',
      'moodJourneyTrendUp': 'Настроение мягко поднимается.',
      'moodJourneyTrendDown': 'Настроение стало немного мягче в последнее время.',
      'moodJourneyTrendSteady': 'Настроение выглядит ровным.',
      'moodJourneyStressHint':
          'Часто вы чувствуете себя спокойнее, когда стресс ниже.',
      'moodJourneyActivityHint':
          'В дни с большей активностью настроение обычно светлее.',
      'moodJourneyReflectionPrompt':
          'Что помогло вам почувствовать себя лучше сегодня? (Достаточно пары строк.)',
      'dashboardInsightStressDown':
          'Стресс обычно легче уходит после регулярных чек‑инов.',
      'dashboardInsightMoodUp':
          'Настроение часто поднимается, когда вы не пропускаете.',
      'dashboardInsightSteady':
          'Небольшие чек‑ины помогают оставаться устойчивым в течение дня.',
      'dashboardInsightConsistency': 'Регулярность создаёт мягкий ритм.',
      'dashboardQuickActionsTitle': 'Быстрые практики',
      'quickActionBreathing': 'Дыхание',
      'quickActionJournal': 'Дневник',
      'quickActionStretch': 'Растяжка',
      'quickActionWater': 'Вода',
      'quickActionWalk': 'Прогулка',
      'dashboardCheckInTitle': 'Как вы себя чувствуете прямо сейчас?',
      'checkInOptionCalm': 'Спокойствие',
      'checkInOptionTired': 'Усталость',
      'checkInOptionStressed': 'Стресс',
      'checkInOptionMotivated': 'Вдохновение',
      'checkInSave': 'Сохранить чек‑ин',
      'checkInSaved': 'Чек‑ин сохранён',
      'todayCompletedActions': 'Вы завершили ',
      'todayCompletedActionsSuffix': ' практики сегодня',
      'todayStreakSuffix': ' дневную цепочку',
      'dashboardPracticesTitle': 'Забота о себе сегодня',
      'dashboardPracticesTracking': 'Чек-ин и быстрые практики, которые вы завершили',
      'dashboardPracticesProgress': '{done} из {total}',
      'dashboardPracticesStreak': '{n} дн. подряд',
      'dashboardPracticesStreakSingle': '1 день подряд',
      'dashboardPracticesEncourage':
          'Нажмите чек-ин или практику ниже — каждый шаг заполняет эту строку.',
      'dashboardPracticeCheckin': 'Чек-ин',
      'dashboardWellbeingEmptyHeadline': 'Пока нет снимка',
      'dashboardWellbeingRingLabel': 'баланс (0–100)',
      'dashboardWellbeingScaleTitle': 'Как читать кольцо',
      'dashboardWellbeingZoneLowShort': '0–33 тяжелее',
      'dashboardWellbeingZoneMidShort': '34–66 обычный день',
      'dashboardWellbeingZoneHighShort': '67–100 больше лёгкости',
      'dashboardWellbeingScaleFootnote':
          'Число собирается из последнего настроения, стресса и энергии (как на сервере). Очень низкие значения бывают в трудные дни — это ориентир, не диагноз.',
      'quickActionStretchDetail':
          'Несколько мягких движений для шеи и плеч.',
      'quickActionWaterDetail':
          'Выпейте стакан воды неторопливо и выпрямите спину.',
      'recBenefitBreathing': 'Меньше напряжения и спокойнее тело примерно за две минуты.',
      'recBenefitWalk': 'Мягкий подъём энергии и меньше напряжения после короткой прогулки.',
      'recBenefitGeneric': 'Небольшой шаг, который помогает состоянию выровняться.',
      'recDurBreathing': '2 мин',
      'recDurMovement': '10–15 мин',
      'recDurQuickBreak': '1–2 мин',
      'recDurSleep': '10–15 мин',
      'recDurMindset': '1 мин',
      'recDurDefault': 'Пара минут',
      'breathUiClose': 'Закрыть',
      'breathUiReadyTitle': 'Дыхание 4‑7‑8',
      'breathUiReadySubtitle':
          'Вдох 4 с, задержка 7 с, выдох 8 с — четыре цикла, около двух минут. Сядьте удобно, плечи опущены.',
      'breathUiStep1': 'Вдох через нос 4 секунды.',
      'breathUiStep2': 'Задержка дыхания 7 секунд.',
      'breathUiStep3': 'Медленный выдох через рот 8 секунд.',
      'breathUiSec': 'с',
      'breathUiCycles': 'Циклы',
      'breathUiStart': 'Начать',
      'breathUiStop': 'Стоп',
      'breathUiDone': 'Сессия завершена',
      'breathUiRunningFooter':
          'Следите за кольцом — оно заполняется по мере завершения текущей фазы.',
      'wellbeingStateHigh': 'Сейчас стабильнее',
      'wellbeingStateMedium': 'Есть запас на заботу',
      'wellbeingStateLow': 'День мягче — это нормально',
      'wellbeingHintHigh': 'Последняя запись выглядит ровно — продолжайте то, что помогает.',
      'wellbeingHintMedium':
          'Короткие паузы, сон и движение чаще всего поднимают этот показатель.',
      'wellbeingHintLow':
          'Прогулка, вода или дыхание на пару минут могут смягчить день — выберите самое простое.',
      'recDetailsExpectedBenefit': 'Ожидаемая польза',
      'recDetailsEstimatedDuration': 'Примерная длительность',
      'recDetailsActionSteps': 'Шаги',
      'recDetailsDoneForToday': 'Готово на сегодня',
      'recDetailsDismiss': 'Скрыть',
      'recDetailsHelpful': 'Полезно',
      'recDetailsNotHelpful': 'Не подходит',
      'recDoneBadge': 'Готово',
      'tipsEmptyTitle': 'Пока нет рекомендаций',
      'tipsEmptySubtitle': 'Попробуйте быстрое дыхание или сделайте короткий чек‑ин.',
      'historyInsightsTitle': 'Инсайты',
      'historyInsightsSubtitle':
          'Закономерности из ваших записей — без лишнего шума.',
      'historyTabList': 'Записи',
      'historyTabAnalytics': 'Тренды',
      'historyDailyEntries': 'Ваши записи',
      'historyWeeklySummary': 'Еженедельный обзор',
      'historyDominantMoodCalm': 'Спокойствие',
      'historyDominantMoodBalanced': 'В балансе',
      'historyDominantMoodAnxious': 'Тревожность',
      'historyDominantMoodSubtitle':
          'это ваше доминирующее настроение за неделю',
      'addJournalTitle': 'Дневник',
      'dashboardRiskTitle': 'Готовность к завтра',
      'dashboardRiskLevelHigh': 'Выше нагрузка',
      'dashboardRiskLevelModerate': 'В балансе',
      'dashboardRiskLevelLow': 'Мягкий режим',
      'dashboardRiskForDate': 'Окно прогноза: {date}',
      'dashboardRiskSignalsTitle': 'Что повлияло на оценку',
      'dashboardRiskMethodNote':
          'Учитываются недавние средние значения стресса, настроения и сна, а также снижение настроения во времени. Это простая подсказка, а не медицинский прогноз.',
      'dashboardRiskSuggestionInsufficient':
          'Добавьте ещё несколько дней записей — тогда прогноз станет информативнее.',
      'dashboardRiskFactorPattern': '{name} · {impact}',
      'dashboardRiskImpactNegative': 'повышает нагрузку',
      'dashboardRiskImpactNeutral': 'нейтрально',
      'dashboardRiskImpactPositive': 'смягчает нагрузку',
      'tipsDashboardTapHint': 'Нажмите карточку — шаги и действия',
      'dashboardRiskSuggestionHigh':
          'Короткий вечерний отдых поможет глубже выспаться и смягчить завтрашний день.',
      'dashboardRiskSuggestionLow':
          'Запас устойчивости выглядит здоровым — сохраняйте спокойный ритм.',
      'dashboardRiskExtraForecast': 'По вашим последним паттернам.',
      'dashboardRiskExtraHeuristic': 'По сну и стрессу из последних записей.',
      'tipsDashboardSun': 'Утренний свет 10 минут',
      'tipsDashboardCalm': 'Две минуты медленного дыхания',
      'tipsDashboardSleep': 'Меньше кофеина после 14:00',
      'tipsPersonalizeHint':
          'Добавьте запись на главной — здесь появится персональный совет.',
      'tipsFeedbackThanks': 'Спасибо за отзыв',
      'tipsLikeTooltip': 'Полезно',
      'tipsDislikeTooltip': 'Не подходит',
      'settingsTitle': 'Настройки',
      'settingsLanguage': 'Язык',
      'settingsAppearance': 'Оформление',
      'settingsThemeSystem': 'Как в системе',
      'settingsThemeLight': 'Светлая',
      'settingsThemeDark': 'Тёмная',
      'settingsAbout': 'О приложении',
      'settingsAboutBody': 'Учёт настроения, стресса и энергии. Данные синхронизируются с вашим сервером.',
      'settingsAboutSerenity':
          'Почему Serenity / «Серенити»? Название отсылает к спокойному, ясному состоянию — как тишина после глубокого вдоха. Приложение помогает замечать свои чувства без оценки, маленькими шагами.',
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
  String get brandName => _text('brandName');
  String get navDashboard => _text('navDashboard');
  String get navAdd => _text('navAdd');
  String get navHistory => _text('navHistory');
  String get navTips => _text('navTips');

  String get dashboardWellbeingTitle => _text('dashboardWellbeingTitle');
  String get dashboardWellbeingSubtitleEmpty =>
      _text('dashboardWellbeingSubtitleEmpty');
  String get dashboardWellbeingSubtitle =>
      _text('dashboardWellbeingSubtitle');

  String dashboardWellbeingRawFormat(String n) =>
      _text('dashboardWellbeingRawFormat').replaceAll('{n}', n);

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
  String get historyWeeklySummary => _text('historyWeeklySummary');
  String get historyDominantMoodCalm => _text('historyDominantMoodCalm');
  String get historyDominantMoodBalanced => _text('historyDominantMoodBalanced');
  String get historyDominantMoodAnxious => _text('historyDominantMoodAnxious');
  String get historyDominantMoodSubtitle =>
      _text('historyDominantMoodSubtitle');

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
  String get errorStateTitle => _text('errorStateTitle');
  String get errorNetworkHint => _text('errorNetworkHint');
  String get errorServerHint => _text('errorServerHint');
  String get errorRetry => _text('errorRetry');
  String get dashboardEmptyTitle => _text('dashboardEmptyTitle');
  String get dashboardEmptySubtitle => _text('dashboardEmptySubtitle');
  String get dashboardEmptyCta => _text('dashboardEmptyCta');
  String get quickLogTitle => _text('quickLogTitle');
  String get quickLogSubtitle => _text('quickLogSubtitle');
  String get quickLogPrimaryCta => _text('quickLogPrimaryCta');
  String get quickLogSheetSave => _text('quickLogSheetSave');
  String get quickLogSheetCancel => _text('quickLogSheetCancel');
  String get quickLogSheetReset => _text('quickLogSheetReset');
  String get quickLogSheetNote => _text('quickLogSheetNote');
  String get quickLogSheetAdvanced => _text('quickLogSheetAdvanced');
  String get quickLogSheetSaving => _text('quickLogSheetSaving');
  String get tipsChipWeek => _text('tipsChipWeek');
  String get dashboardGreetingMorning => _text('dashboardGreetingMorning');
  String get dashboardGreetingAfternoon => _text('dashboardGreetingAfternoon');
  String get dashboardGreetingEvening => _text('dashboardGreetingEvening');
  String get dashboardHeroSub => _text('dashboardHeroSub');
  String get moodJourneyTitle => _text('moodJourneyTitle');
  String get moodJourneySubtitle => _text('moodJourneySubtitle');
  String get moodJourneyTrendUp => _text('moodJourneyTrendUp');
  String get moodJourneyTrendDown => _text('moodJourneyTrendDown');
  String get moodJourneyTrendSteady => _text('moodJourneyTrendSteady');
  String get moodJourneyStressHint => _text('moodJourneyStressHint');
  String get moodJourneyActivityHint => _text('moodJourneyActivityHint');
  String get moodJourneyReflectionPrompt =>
      _text('moodJourneyReflectionPrompt');
  String get dashboardInsightStressDown => _text('dashboardInsightStressDown');
  String get dashboardInsightMoodUp => _text('dashboardInsightMoodUp');
  String get dashboardInsightSteady => _text('dashboardInsightSteady');
  String get dashboardInsightConsistency => _text('dashboardInsightConsistency');
  String get dashboardQuickActionsTitle => _text('dashboardQuickActionsTitle');
  String get quickActionBreathing => _text('quickActionBreathing');
  String get quickActionJournal => _text('quickActionJournal');
  String get quickActionStretch => _text('quickActionStretch');
  String get quickActionWater => _text('quickActionWater');
  String get quickActionWalk => _text('quickActionWalk');
  String get dashboardCheckInTitle => _text('dashboardCheckInTitle');
  String get checkInOptionCalm => _text('checkInOptionCalm');
  String get checkInOptionTired => _text('checkInOptionTired');
  String get checkInOptionStressed => _text('checkInOptionStressed');
  String get checkInOptionMotivated => _text('checkInOptionMotivated');
  String get checkInSave => _text('checkInSave');
  String get checkInSaved => _text('checkInSaved');
  String get todayCompletedActions => _text('todayCompletedActions');
  String get todayCompletedActionsSuffix =>
      _text('todayCompletedActionsSuffix');
  String get todayStreakSuffix => _text('todayStreakSuffix');

  String get dashboardPracticesTitle => _text('dashboardPracticesTitle');
  String get dashboardPracticesTracking => _text('dashboardPracticesTracking');
  String get dashboardPracticesEncourage => _text('dashboardPracticesEncourage');
  String get dashboardPracticeCheckin => _text('dashboardPracticeCheckin');
  String get dashboardWellbeingEmptyHeadline =>
      _text('dashboardWellbeingEmptyHeadline');
  String get dashboardWellbeingRingLabel => _text('dashboardWellbeingRingLabel');
  String get dashboardWellbeingScaleTitle => _text('dashboardWellbeingScaleTitle');
  String get dashboardWellbeingZoneLowShort => _text('dashboardWellbeingZoneLowShort');
  String get dashboardWellbeingZoneMidShort => _text('dashboardWellbeingZoneMidShort');
  String get dashboardWellbeingZoneHighShort => _text('dashboardWellbeingZoneHighShort');
  String get dashboardWellbeingScaleFootnote => _text('dashboardWellbeingScaleFootnote');
  String get quickActionStretchDetail => _text('quickActionStretchDetail');
  String get quickActionWaterDetail => _text('quickActionWaterDetail');
  String get recBenefitBreathing => _text('recBenefitBreathing');
  String get recBenefitWalk => _text('recBenefitWalk');
  String get recBenefitGeneric => _text('recBenefitGeneric');
  String get recDurBreathing => _text('recDurBreathing');
  String get recDurMovement => _text('recDurMovement');
  String get recDurQuickBreak => _text('recDurQuickBreak');
  String get recDurSleep => _text('recDurSleep');
  String get recDurMindset => _text('recDurMindset');
  String get recDurDefault => _text('recDurDefault');
  String get breathUiClose => _text('breathUiClose');
  String get breathUiReadyTitle => _text('breathUiReadyTitle');
  String get breathUiReadySubtitle => _text('breathUiReadySubtitle');
  String get breathUiStep1 => _text('breathUiStep1');
  String get breathUiStep2 => _text('breathUiStep2');
  String get breathUiStep3 => _text('breathUiStep3');
  String get breathUiSec => _text('breathUiSec');
  String get breathUiCycles => _text('breathUiCycles');
  String get breathUiStart => _text('breathUiStart');
  String get breathUiStop => _text('breathUiStop');
  String get breathUiDone => _text('breathUiDone');
  String get breathUiRunningFooter => _text('breathUiRunningFooter');
  String get settingsAboutSerenity => _text('settingsAboutSerenity');
  String get apiErrorNoInternet => _text('apiErrorNoInternet');
  String get apiErrorTimeout => _text('apiErrorTimeout');
  String get apiErrorNetwork => _text('apiErrorNetwork');
  String get apiErrorServer => _text('apiErrorServer');
  String get apiErrorClient => _text('apiErrorClient');
  String get apiErrorUnknown => _text('apiErrorUnknown');
  String get wellbeingStateHigh => _text('wellbeingStateHigh');
  String get wellbeingStateMedium => _text('wellbeingStateMedium');
  String get wellbeingStateLow => _text('wellbeingStateLow');
  String get wellbeingHintHigh => _text('wellbeingHintHigh');
  String get wellbeingHintMedium => _text('wellbeingHintMedium');
  String get wellbeingHintLow => _text('wellbeingHintLow');

  String dashboardPracticesProgress(int done, int total) =>
      _text('dashboardPracticesProgress')
          .replaceAll('{done}', '$done')
          .replaceAll('{total}', '$total');

  String dashboardPracticesStreak(int days) => days <= 1
      ? _text('dashboardPracticesStreakSingle')
      : _text('dashboardPracticesStreak').replaceAll('{n}', '$days');

  String get recDetailsExpectedBenefit =>
      _text('recDetailsExpectedBenefit');
  String get recDetailsEstimatedDuration =>
      _text('recDetailsEstimatedDuration');
  String get recDetailsActionSteps => _text('recDetailsActionSteps');
  String get recDetailsDoneForToday => _text('recDetailsDoneForToday');
  String get recDetailsDismiss => _text('recDetailsDismiss');
  String get recDetailsHelpful => _text('recDetailsHelpful');
  String get recDetailsNotHelpful => _text('recDetailsNotHelpful');
  String get recDoneBadge => _text('recDoneBadge');
  String get tipsEmptyTitle => _text('tipsEmptyTitle');
  String get tipsEmptySubtitle => _text('tipsEmptySubtitle');
  String get historyInsightsTitle => _text('historyInsightsTitle');
  String get historyInsightsSubtitle => _text('historyInsightsSubtitle');
  String get historyTabList => _text('historyTabList');
  String get historyTabAnalytics => _text('historyTabAnalytics');
  String get historyDailyEntries => _text('historyDailyEntries');
  String get addJournalTitle => _text('addJournalTitle');
  String get dashboardRiskTitle => _text('dashboardRiskTitle');
  String get dashboardRiskLevelHigh => _text('dashboardRiskLevelHigh');
  String get dashboardRiskLevelModerate => _text('dashboardRiskLevelModerate');
  String get dashboardRiskLevelLow => _text('dashboardRiskLevelLow');
  String get dashboardRiskSignalsTitle => _text('dashboardRiskSignalsTitle');
  String get dashboardRiskMethodNote => _text('dashboardRiskMethodNote');
  String get dashboardRiskSuggestionInsufficient =>
      _text('dashboardRiskSuggestionInsufficient');
  String get dashboardRiskSuggestionHigh => _text('dashboardRiskSuggestionHigh');
  String get dashboardRiskSuggestionLow => _text('dashboardRiskSuggestionLow');
  String get dashboardRiskExtraForecast => _text('dashboardRiskExtraForecast');
  String get dashboardRiskExtraHeuristic => _text('dashboardRiskExtraHeuristic');

  String dashboardRiskForDate(String date) =>
      _text('dashboardRiskForDate').replaceAll('{date}', date);

  String dashboardRiskFactorLine(String name, String impact) {
    final impactLabel = switch (impact) {
      'negative' => _text('dashboardRiskImpactNegative'),
      'neutral' => _text('dashboardRiskImpactNeutral'),
      'positive' => _text('dashboardRiskImpactPositive'),
      _ => impact,
    };
    return _text('dashboardRiskFactorPattern')
        .replaceAll('{name}', name)
        .replaceAll('{impact}', impactLabel);
  }
  String get tipsDashboardSun => _text('tipsDashboardSun');
  String get tipsDashboardCalm => _text('tipsDashboardCalm');
  String get tipsDashboardSleep => _text('tipsDashboardSleep');
  String get tipsDashboardTapHint => _text('tipsDashboardTapHint');
  String get tipsPersonalizeHint => _text('tipsPersonalizeHint');
  String get tipsFeedbackThanks => _text('tipsFeedbackThanks');
  String get tipsLikeTooltip => _text('tipsLikeTooltip');
  String get tipsDislikeTooltip => _text('tipsDislikeTooltip');

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

