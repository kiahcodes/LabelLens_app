// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'features/auth/screens/login_screen.dart';
// import 'features/onboarding/screens/onboarding_screen.dart';
// import 'core/theme/app_theme.dart';

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
//         '/dashboard': (context) => const PlaceholderScreen(name: 'Dashboard'),
//       },
//     );
//   }
// }

// class PlaceholderScreen extends StatelessWidget {
//   final String name;
//   const PlaceholderScreen({super.key, required this.name});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle_outline,
//                 color: AppColors.green, size: 64),
//             const SizedBox(height: 16),
//             Text('Day 3 working!',
//                 style: Theme.of(context).textTheme.headlineMedium),
//             const SizedBox(height: 8),
//             Text(name, style: Theme.of(context).textTheme.bodyMedium),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wqdrvcoofglaofvkcccj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxZHJ2Y29vZmdsYW9mdmtjY2NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyOTc1ODEsImV4cCI6MjA5MDg3MzU4MX0.KeYmrfrRSCJmBbeKU8kpDgBVJMzNYrBnwSCaFJB79Xc',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeScan',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
