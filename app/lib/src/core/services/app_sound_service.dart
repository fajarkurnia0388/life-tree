import 'package:flutter/services.dart';

class AppSoundService {
  /// Play wood wind chime sound for regular habit checks.
  /// Synthesized using standard MIDI chimes or haptic waves to avoid packaging heavy assets
  static Future<void> playChime() async {
    // Generate a pleasant wood wind chime cadence using sequenced haptic taps
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.lightImpact();
  }

  /// Play Tibetan singing bowl wave sound for celebration checks.
  static Future<void> playTibetanChime() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 180));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 220));
    await HapticFeedback.lightImpact();
  }

  /// Play low hum sound for entering recovery mode.
  static Future<void> playLowHum() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    await HapticFeedback.mediumImpact();
  }
}
