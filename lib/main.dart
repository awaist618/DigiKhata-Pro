import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:khataplus/features/splash/presentation/splash_screen.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'package:khataplus/core/providers/security_provider.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:khataplus/core/services/notification_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:khataplus/core/database/app_database.dart';
import 'package:khataplus/core/services/sync_service.dart';
import 'package:khataplus/core/services/backup_service.dart';
import 'package:khataplus/features/auth/presentation/login/login_screen.dart';
import 'package:khataplus/features/auth/presentation/reset_password/reset_password_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await dotenv.load(fileName: "assets/supabase.env");
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
      if (supabaseUrl == null || supabaseKey == null) return false;

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
      final db = AppDatabase();
      if (task == "syncTask") {
        final syncService = SyncService(Supabase.instance.client, db);
        await syncService.syncPendingChanges();
      } else if (task == "backupTask") {
        final backupService = BackupService(db);
        await backupService.createBackup();
      }
      await db.close();
      return true;
    } catch (e) {
      debugPrint('Background Task Error ($task): $e');
      return false;
    }
  });
}

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await EasyLocalization.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask("1", "syncTask", frequency: const Duration(minutes: 15), constraints: Constraints(networkType: NetworkType.connected));
  Workmanager().registerPeriodicTask("2", "backupTask", frequency: const Duration(hours: 24), constraints: Constraints(requiresStorageNotLow: true));

  try {
    await dotenv.load(fileName: "assets/supabase.env");
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (supabaseUrl != null && supabaseKey != null && supabaseUrl.isNotEmpty) {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
    }
  } catch (e) {
    debugPrint("SUPABASE: Initialization error: $e");
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ur')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: AppStartupWidget()),
    ),
  );
}

class AppStartupWidget extends ConsumerStatefulWidget {
  const AppStartupWidget({super.key});
  @override
  ConsumerState<AppStartupWidget> createState() => _AppStartupWidgetState();
}

class _AppStartupWidgetState extends ConsumerState<AppStartupWidget> with WidgetsBindingObserver {
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final duration = DateTime.now().difference(_backgroundTime!);
        if (duration.inSeconds > 15) {
          _lockApp();
        }
      }
    }
  }

  void _lockApp() async {
    if (!mounted) return;
    final security = ref.read(securityProvider);
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      if (security.isAutoLogoutEnabled) {
        await ref.read(supabaseServiceProvider).signOut();
        navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
      } else if (security.isBiometricEnabled) {
        final authenticated = await ref.read(securityProvider.notifier).authenticate();
        if (!authenticated) {
          navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDarkMode = settings.isDarkMode;
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'DigiKhata Pro',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue, primary: AppColors.primaryBlue, secondary: AppColors.amberGold, surface: AppColors.surfaceDark, error: AppColors.error, brightness: Brightness.dark, onSurface: AppColors.textPrimaryDark),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(bodyColor: AppColors.textPrimaryDark, displayColor: AppColors.textPrimaryDark),
        scaffoldBackgroundColor: AppColors.backgroundDark,
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue, primary: AppColors.primaryBlue, secondary: AppColors.amberGold, surface: AppColors.surface, error: AppColors.error, brightness: Brightness.light),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(),
    );
  }
}
