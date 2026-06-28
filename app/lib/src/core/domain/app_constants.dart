// Centralized domain constants to avoid raw string literals.
// Use these instead of hardcoded strings like 'Done', 'Missed', 'Recovery', etc.

class HabitStatus {
  HabitStatus._();
  static const String active = 'Active';
  static const String done = 'Done';
  static const String missed = 'Missed';
  static const String paused = 'Paused';
  static const String skippedIntentionally = 'Skipped_Intentionally';
}

class SupportMode {
  SupportMode._();
  static const String normal = 'Normal';
  static const String recovery = 'Recovery';
}

class Season {
  Season._();
  static const String growth = 'Growth';
  static const String recovery = 'Recovery';
  static const String dormant = 'Dormant';
}

class HabitFrequency {
  HabitFrequency._();
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String custom = 'Custom';
}

class JournalEntryType {
  JournalEntryType._();
  static const String lite = 'Lite';
  static const String deep = 'Deep';
}

class FrictionReason {
  FrictionReason._();
  static const String kurangWaktu = 'Kurang_Waktu';
  static const String kelelahan = 'Kelelahan';
  static const String lupa = 'Lupa';
}

class TreeSkin {
  TreeSkin._();
  static const String defaultSkin = 'Default';
  static const String sakura = 'Sakura';
  static const String maple = 'Maple';
  static const String bonsai = 'Bonsai';
}

class WellnessPromptTrigger {
  WellnessPromptTrigger._();
  static const String lowMood = 'Low_Mood_3Days';
  static const String safetyCard = 'Safety_Card';
  static const String weeklyPulse = 'Weekly_Pulse';
}
