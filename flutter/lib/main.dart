// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();

// //   await Supabase.initialize(
// //     url: 'https://wqdrvcoofglaofvkcccj.supabase.co',
// //     anonKey:
// //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxZHJ2Y29vZmdsYW9mdmtjY2NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyOTc1ODEsImV4cCI6MjA5MDg3MzU4MX0.KeYmrfrRSCJmBbeKU8kpDgBVJMzNYrBnwSCaFJB79Xc',
// //   );

// //   runApp(
// //     const MaterialApp(
// //       home: Scaffold(
// //         body: Center(
// //           child: Text(
// //             'LabelLens + Supabase works!',
// //             style: TextStyle(fontSize: 20),
// //           ),
// //         ),
// //       ),
// //     ),
// //   );
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'features/auth/screens/login_screen.dart';
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
//       home: const LoginScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';
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
        '/onboarding': (context) => const PlaceholderScreen(name: 'Onboarding'),
        '/dashboard': (context) => const PlaceholderScreen(name: 'Dashboard'),
      },
    );
  }
}

// Temporary placeholder — replace with real screens on Day 3
class PlaceholderScreen extends StatelessWidget {
  final String name;
  const PlaceholderScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.green, size: 64),
            const SizedBox(height: 16),
            Text('Login worked!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Going to: $name',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
