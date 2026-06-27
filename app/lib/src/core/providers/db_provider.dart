import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
