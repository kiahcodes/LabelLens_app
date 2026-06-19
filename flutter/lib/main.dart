import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/auth/auth_deep_link_handler.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'core/constants/supabase_config.dart';
import 'features/auth/screens/reset_password_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await prepareAuthDeepLinkState();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey:
        SupabaseConfig.supabaseAnonKey,
  );

  await setupAuthDeepLinks(_navigatorKey);

  runApp(const ProviderScope(child: SafeScanApp()));
}

class SafeScanApp extends StatelessWidget {
  const SafeScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'LabelLens',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // light only per requirement
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      // Splash is the entry point
      home: const SplashScreen(),
      routes: {
        '/login': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final emailVerified = args is Map<String, dynamic> &&
              args['emailVerified'] == true;
          return LoginScreen(emailVerified: emailVerified);
        },
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
    );
  }
}
