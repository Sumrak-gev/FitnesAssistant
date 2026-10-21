import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/db/app_database.dart';
import 'core/api/api_client.dart';
import 'core/sync/sync_engine.dart';
import 'core/sync/background_sync.dart';
import 'core/sync/database_lease.dart';
import 'data/fitness_repository.dart';
import 'screens/auth/auth_screen.dart';
import 'data/profile_repository.dart';
import 'services/profile_controller.dart';
import 'services/reminder_service.dart';
import 'services/theme_controller.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/nutrition/nutrition_screen.dart';
import 'screens/workouts/workouts_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'widgets/app_backdrop.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeBackgroundSync();
  } catch (_) {
    debugPrint('Фоновая синхронизация недоступна');
  }
  runApp(const FitnessAssistantApp());
}

class FitnessAssistantApp extends StatefulWidget {
  const FitnessAssistantApp({super.key, this.profileController});
  final ProfileController? profileController;

  @override
  State<FitnessAssistantApp> createState() => _FitnessAssistantAppState();
}

class _FitnessAssistantAppState extends State<FitnessAssistantApp>
    with WidgetsBindingObserver {
  AppDatabase? _database;
  late final ProfileController _profile;
  ApiClient? _api;
  SyncEngine? _sync;
  late final ThemeController _theme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _profile =
        widget.profileController ??
        ProfileController(
          ProfileRepository(_database = AppDatabase()),
          LocalReminderService(),
        );
    _profile.load();
    _theme = ThemeController(FitnessRepository(_profile.repository.database));
    _theme.load();
    if (widget.profileController == null) {
      _api = ApiClient(
        refreshGuard: DatabaseLease(
          _profile.repository.database,
          'refresh',
        ).guardRefresh,
      );
      _sync = SyncEngine(
        _profile.repository.database,
        _api!,
        onDataChanged: _profile.load,
      );
      _api!.restore();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _profile.reconcileReminders();
      _sync?.synchronize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sync?.dispose();
    _api?.dispose();
    _theme.dispose();
    if (widget.profileController == null) _profile.dispose();
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: _profile.repository.database),
        ChangeNotifierProvider<ProfileController>.value(value: _profile),
        ChangeNotifierProvider<ThemeController>.value(value: _theme),
        ChangeNotifierProvider<ApiClient?>.value(value: _api),
        ChangeNotifierProvider<SyncEngine?>.value(value: _sync),
      ],
      child: Consumer<ThemeController>(
        builder: (context, appearance, _) => MaterialApp(
          title: 'Фитнес-помощник',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ru'),
          supportedLocales: const [Locale('ru')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          themeMode: appearance.mode,
          theme: _appTheme(Brightness.light, appearance.palette),
          darkTheme: _appTheme(Brightness.dark, appearance.palette),
          builder: (context, child) =>
              AppBackdrop(child: child ?? const SizedBox()),
          home: _api == null
              ? const RootScreen()
              : Consumer<ApiClient?>(
                  builder: (context, api, _) {
                    if (!api!.restored) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return api.session == null
                        ? AuthScreen(api: api, repository: _profile.repository)
                        : const _GoalGate();
                  },
                ),
        ),
      ),
    );
  }
}

ThemeData _appTheme(Brightness brightness, AppPalette palette) {
  final scheme = ColorScheme.fromSeed(
    seedColor: palette == AppPalette.israel
        ? const Color(0xFF1555A5)
        : const Color(0xFF247E76),
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow.withValues(alpha: .92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

class _GoalGate extends StatefulWidget {
  const _GoalGate();
  @override
  State<_GoalGate> createState() => _GoalGateState();
}

class _GoalGateState extends State<_GoalGate> {
  late final Future<String?> _chosen = FitnessRepository(
    context.read<AppDatabase>(),
  ).setting('goalSelected');
  bool _finished = false;

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: _chosen,
    builder: (context, snapshot) {
      if (!snapshot.hasData &&
          snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return _finished || snapshot.data == '1'
          ? const RootScreen()
          : GoalsScreen(
              onboarding: true,
              onSaved: () => setState(() => _finished = true),
            );
    },
  );
}

/// Корневой экран с нижней навигацией между основными модулями приложения.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final _screens = const [
    NutritionScreen(),
    WorkoutsScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncEngine?>();
    return Scaffold(
      body: Column(
        children: [
          if (sync?.conflict != null)
            SafeArea(
              bottom: false,
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      const Text('Есть конфликт синхронизации'),
                      if (sync!.conflict != null)
                        Wrap(
                          spacing: 8,
                          children: [
                            if (sync.conflict?['canKeepLocal'] == true)
                              TextButton(
                                onPressed: () =>
                                    sync.resolveConflict(keepLocal: true),
                                child: const Text('Оставить локальную версию'),
                              ),
                            TextButton(
                              onPressed: () =>
                                  sync.resolveConflict(keepLocal: false),
                              child: const Text('Принять с сервера'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              key: ValueKey(sync?.generation),
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'КБЖУ'),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Тренировки',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Прогресс',
          ),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Настройки'),
        ],
      ),
    );
  }
}
