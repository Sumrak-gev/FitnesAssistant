import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import '../api/api_client.dart';
import '../db/app_database.dart';
import 'database_lease.dart';
import 'sync_engine.dart';

@pragma('vm:entry-point')
void fitnessSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    final database = AppDatabase();
    final api = ApiClient(
      refreshGuard: DatabaseLease(database, 'refresh').guardRefresh,
    );
    SyncEngine? engine;
    try {
      await api.restore();
      if (api.session == null) return true;
      engine = SyncEngine(database, api);
      await engine.synchronize();
      return engine.status == 'Синхронизировано' || engine.conflict != null;
    } catch (_) {
      return false; // WorkManager retries under its network/backoff policy.
    } finally {
      engine?.dispose();
      api.dispose();
      await database.close();
    }
  });
}

Future<void> initializeBackgroundSync() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  await Workmanager().initialize(fitnessSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    'fitness-sync',
    'fitness-sync',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(seconds: 30),
  );
}
