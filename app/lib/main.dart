import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'src/app.dart';
import 'src/core/services/error_handler_service.dart';
import 'src/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    ErrorHandlerService.logFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    return ErrorHandlerService.logZoneError(error, stack);
  };

  // Detect local timezone; fallback to Asia/Jakarta if detection fails.
  String timeZoneName;
  try {
    timeZoneName = await FlutterTimezone.getLocalTimezone();
  } catch (e, stackTrace) {
    timeZoneName = 'Asia/Jakarta';
    ErrorHandlerService().logError(
      e,
      stackTrace,
      context: 'main.timezoneDetection',
    );
  }

  // Notification failure must never prevent the main UI from starting.
  try {
    await NotificationService.initialize(timeZoneName: timeZoneName);
  } catch (error, stackTrace) {
    ErrorHandlerService().logError(
      error,
      stackTrace,
      context: 'main.notificationInit',
    );
  }

  runApp(const ProviderScope(child: DaojiApp()));
}
