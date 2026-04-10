// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'features/auth/screens/login_screen.dart';
// import 'features/onboarding/screens/onboarding_screen.dart';
// import 'features/dashboard/screens/dashboard_screen.dart';
// import 'core/theme/app_theme.dart';
// import 'models/scan_result.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Supabase.initialize(
//     url: 'https://wqdrvcoofglaofvkcccj.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxZHJ2Y29vZmdsYW9mdmtjY2NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyOTc1ODEsImV4cCI6MjA5MDg3MzU4MX0.KeYmrfrRSCJmBbeKU8kpDgBVJMzNYrBnwSCaFJB79Xc',
//   );

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SafeScan',
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//       debugShowCheckedModeBanner: false,
//       home: const LoginScreen(),
//       routes: {
//         '/onboarding': (context) => const OnboardingScreen(),
//         '/dashboard': (context) => const DashboardScreen(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

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

  await Supabase.initialize(
    url: 'https://wqdrvcoofglaofvkcccj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxZHJ2Y29vZmdsYW9mdmtjY2NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyOTc1ODEsImV4cCI6MjA5MDg3MzU4MX0.KeYmrfrRSCJmBbeKU8kpDgBVJMzNYrBnwSCaFJB79Xc',
  );

  runApp(const ProviderScope(child: SafeScanApp()));
}

class SafeScanApp extends StatelessWidget {
  const SafeScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabelLens',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // light only per requirement
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      // Splash is the entry point
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
    );
  }
}
