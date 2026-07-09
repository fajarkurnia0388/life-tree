import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/core/services/notification_service.dart';
import 'src/core/utils/reset_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TEMPORARY: Reset database untuk fix migration issue
  await resetDatabase();
  
  // Initialize Notification Service
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: DaojiApp(),
    ),
  );
}
