import 'dart:convert';
import 'dart:io' as io;
import 'package:uuid/uuid.dart';
import '../db/app_database.dart';
import '../../data/fitness_repository.dart';

/// Coordinates foreground/background Flutter engines through the same SQLite file.
class DatabaseLease {
  DatabaseLease(this.database, this.key);
  final AppDatabase database;
  final String key;
  final String _token = const Uuid().v4();
  FitnessRepository get _records => FitnessRepository(database);

  Future<bool> acquire() async {
    try {
      return await database.transaction(() async {
        final raw = await _records.setting('lease:$key');
        if (raw != null) {
          final value = jsonDecode(raw) as Map;
          if (value['token'] != _token &&
              value['pid'] == io.pid &&
              DateTime.parse(
                value['expires'] as String,
              ).isAfter(DateTime.now().toUtc())) {
            return false;
          }
        }
        await _records.setSetting(
          'lease:$key',
          jsonEncode({
            'token': _token,
            'pid': io.pid,
            'expires': DateTime.now()
                .toUtc()
                .add(const Duration(minutes: 5))
                .toIso8601String(),
          }),
        );
        return true;
      });
    } catch (_) {
      return false; // SQLite contention is retryable; never steal another worker's lease.
    }
  }

  Future<void> release() => database.transaction(() async {
    final raw = await _records.setting('lease:$key');
    if (raw != null && (jsonDecode(raw) as Map)['token'] == _token) {
      await (database.delete(
        database.appSettings,
      )..where((s) => s.key.equals('lease:$key'))).go();
    }
  });

  Future<void> guardRefresh(Future<void> Function() action) async {
    for (var attempt = 0; attempt < 450; attempt++) {
      if (await acquire()) {
        try {
          await action();
        } finally {
          await release();
        }
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('Обновление сессии выполняется в фоне. Повторите позже.');
  }
}
