import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';
import 'db_provider.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.userProfiles)..limit(1)).watch().map((profiles) {
    if (profiles.isEmpty) return null;
    return profiles.first;
  });
});

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final db = ref.watch(dbProvider);
  final profiles = await db.select(db.userProfiles).get();
  return profiles.isEmpty ? null : profiles.first.userId;
});
