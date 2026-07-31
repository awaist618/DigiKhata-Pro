import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

import 'package:easy_localization/easy_localization.dart';

import 'core/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    // 1. Load environment variables
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
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDarkMode = settings.isDarkMode;

    return MaterialApp(
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
          surface: AppColors.logoNavyBottom,
          error: AppColors.error,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: AppColors.deepNavy,
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
