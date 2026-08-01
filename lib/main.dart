import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:easy_localization/easy_localization.dart';

import 'core/providers/settings_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';
import 'package:workmanager/workmanager.dart';
import 'core/database/app_database.dart';
import 'core/services/sync_service.dart';
import 'features/auth/presentation/reset_password/reset_password_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background notifications are automatically shown by the OS.
  // We can add logic here to sync data if needed.
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize Dotenv
      await dotenv.load(fileName: "assets/supabase.env");
      
      // 2. Initialize Supabase
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
      if (supabaseUrl == null || supabaseKey == null) return false;

      await Supabase.initialize(
        url: supabaseUrl, 
        anonKey: supabaseKey,
      );
      
      // 3. Initialize DB and Sync Service
      final db = AppDatabase();
      final syncService = SyncService(Supabase.instance.client, db);
      
      // 4. Sync
      await syncService.syncPendingChanges();
      
      await db.close();
      return true;
    } catch (e) {
      debugPrint('Background Sync Task Error: $e');
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

  // Initialize Workmanager for background sync
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "1", 
    "syncTask", 
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  try {
    await dotenv.load(fileName: "assets/supabase.env");
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl != null && supabaseKey != null && supabaseUrl.isNotEmpty) {
      // 2. Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      debugPrint("SUPABASE: Initialized successfully");
    }
  } catch (e) {
    debugPrint("SUPABASE: Initialization error: $e");
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ur')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(
        child: AppStartupWidget(),
      ),
    ),
  );
}

class AppStartupWidget extends ConsumerStatefulWidget {
  const AppStartupWidget({super.key});

  @override
  ConsumerState<AppStartupWidget> createState() => _AppStartupWidgetState();
}

class _AppStartupWidgetState extends ConsumerState<AppStartupWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize Notification Service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
      
      // Supabase Auth Listener for Deep Linking (Reset Password)
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        if (event == AuthChangeEvent.passwordRecovery) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
          );
        }
      });
    });
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.amberGold,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
          brightness: Brightness.dark,
          onSurface: AppColors.textPrimaryDark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.textPrimaryDark,
          displayColor: AppColors.textPrimaryDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.amberGold,
          surface: AppColors.surface,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(),
    );
  }
}
