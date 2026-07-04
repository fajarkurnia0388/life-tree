/// User-facing text keys covered by Daoji's vocabulary registry.
///
/// The registry starts with P0 surfaces. More keys should be added as feature
/// text is migrated out of hardcoded widgets.
enum DaojiTextKey {
  // Navigation
  navHome,
  navJournal,
  navReflection,
  navMarketplace,
  navProfile,

  // Dashboard / action
  dashboardNoActionsTitle,
  dashboardNoActionsBody,
  dashboardQuickActionsTitle,
  dashboardAddPracticeTitle,
  dashboardAddPracticeSubtitle,
  dashboardJournalTitle,
  dashboardJournalSubtitle,
  dashboardShowCultivationStatus,
  dashboardHideCultivationStatus,
  dashboardLoading,
  dashboardLoadError,
  actionTitle,
  actionSubtitle,
  actionDone,
  actionNotCapable,
  actionWhyTooltip,
  actionWhyTitle,
  actionUnderstand,
  actionPaused,

  // Streams / map
  mapTitle,
  mapDomainLabel,
  mapScoreLabel,
  mapInfoTitle,
  treeTitle,
  treeRoot,
  treeBranch,
  treeLeaf,
  treeFlower,
  treeFruit,
  treeCapture,
  treeShowAll,
  treeShareSave,

  // Seasons / states
  stateGrowth,
  stateRecovery,
  stateDormant,
  stateTribulation,
  stateQuietIntegration,
  stateGrowthDescription,
  stateRecoveryDescription,
  stateDormantDescription,

  // Friction / bottleneck
  frictionTitle,
  frictionNoGuilt,
  frictionTime,
  frictionEnergy,
  frictionForgot,
  frictionRecoveryTitle,
  frictionSave,
  frictionRestDays,

  // Habit/practice form
  habitLabel,
  habitAdd,
  habitEdit,
  habitDelete,
  habitCategory,
  habitNameLabel,
  habitGoalLabel,
  habitFrequency,
  habitFriction,
  habitEnergy,
  habitImpact,
  habitMva,
  habitSave,
  habitCapacityWarning,

  // Journal / reflection / weekly / value / decision / market
  journalTabTitle,
  journalQuickTitle,
  journalMoodPrompt,
  journalSave,
  reflectionTitle,
  reflectionSubtitle,
  reflectionValueMirror,
  reflectionWeeklyPulse,
  reflectionThinkingCanvas,
  reflectionSafetyCard,
  reflectionMarketplace,
  weeklyTitle,
  weeklyIntro,
  weeklyBackDashboard,
  valueIntroTitle,
  valueStart,
  decisionTitle,
  marketTitle,

  // Safety locked
  safetyTitle,
  safetyHeader,
  safetyCall,
  safetyLocalData,

  // Settings
  settingsTitle,
  settingsVocabularyStyle,
  settingsExport,
  settingsReset,
  settingsDevMode,

  // System
  systemLoading,
  systemRetry,
  systemCancel,
  systemClose,
  systemSave,
  systemDelete,
}
