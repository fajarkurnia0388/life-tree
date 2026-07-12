import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'src/app.dart';
import 'src/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect local timezone; fallback to Asia/Jakarta if detection fails.
  String timeZoneName;
  try {
    timeZoneName = await FlutterTimezone.getLocalTimezone();
  } catch (e) {
    timeZoneName = 'Asia/Jakarta';
  }

  // Notification failure must never prevent the main UI from starting.
  try {
    await NotificationService.initialize(timeZoneName: timeZoneName);
  } catch (error, stackTrace) {
    debugPrint('Notification initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const ProviderScope(child: DaojiApp()));
}
