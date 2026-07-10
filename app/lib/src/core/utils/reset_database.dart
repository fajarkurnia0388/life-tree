import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Helper untuk menghapus database lokal saat development/debugging
Future<void> resetDatabase() async {
  final dbFolder = await getApplicationSupportDirectory();
  final file = File(p.join(dbFolder.path, 'daoji.db'));
  
  if (await file.exists()) {
    await file.delete();
    debugPrint('✓ Database dihapus: ${file.path}');
  } else {
    debugPrint('✗ Database tidak ditemukan: ${file.path}');
  }
}
