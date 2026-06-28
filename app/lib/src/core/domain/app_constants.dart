import 'package:flutter/material.dart';

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

class DomainColors {
  DomainColors._();
  static Color forDomain(String? domain) {
    switch (domain) {
      case 'Tubuh':    return const Color(0xFF7C9A72);
      case 'Keuangan': return const Color(0xFFC29B38);
      case 'Hubungan': return const Color(0xFFC78585);
      case 'Emosi':    return const Color(0xFF8595C7);
      case 'Karir':    return const Color(0xFF6CA8B5);
      case 'Rekreasi': return const Color(0xFFD49E6A);
      default:         return const Color(0xFF7C9A72);
    }
  }
}
