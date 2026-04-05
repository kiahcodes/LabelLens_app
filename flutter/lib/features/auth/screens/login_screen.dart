// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../core/theme/app_theme.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool _loading = false;

//   Future<void> _signInWithGoogle() async {
//     setState(() => _loading = true);
//     try {
//       await Supabase.instance.client.auth.signInWithOAuth(
//         OAuthProvider.google,
//         redirectTo: 'io.supabase.safescan://login-callback/',
//       );
//       if (mounted) {
//         // Check if profile exists
//         final userId = Supabase.instance.client.auth.currentUser?.id;
//         if (userId != null) {
//           final profile = await Supabase.instance.client
//               .from('profiles')
//               .select()
//               .eq('user_id', userId)
//               .maybeSingle();
//           if (profile == null && mounted) {
//             context.go('/onboarding');
//           } else if (mounted) {
//             context.go('/');
//           }
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Sign in failed: $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Spacer(),
//               // Logo / Icon
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: AppColors.green.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Icon(Icons.shield_outlined,
//                     size: 44, color: AppColors.green),
//               )
//                   .animate()
//                   .scale(duration: 600.ms, curve: Curves.elasticOut)
//                   .fadeIn(),
//               const SizedBox(height: 24),
//               Text(
//                 'SafeScan',
//                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.w700,
//                     ),
//                 textAlign: TextAlign.center,
//               )
//                   .animate(delay: 200.ms)
//                   .slideY(begin: 0.3, curve: Curves.easeOut)
//                   .fadeIn(),
//               const SizedBox(height: 8),
//               Text(
//                 'Your personal AI health guardian',
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ).animate(delay: 300.ms).fadeIn(),
//               const Spacer(),
//               // Feature bullets
//               ...[
//                 '🔍  Scan any food or cosmetic label',
//                 '🧬  Personalized to your health profile',
//                 '🌍  Global regulatory intelligence',
//                 '🔊  Full voice accessibility',
//               ].asMap().entries.map((entry) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Row(children: [
//                       Text(entry.value,
//                           style: Theme.of(context).textTheme.bodyMedium),
//                     ]),
//                   )
//                       .animate(delay: (400 + entry.key * 80).ms)
//                       .slideX(begin: -0.2)
//                       .fadeIn()),
//               const Spacer(),
//               // Google sign-in button
//               SizedBox(
//                 height: 56,
//                 child: ElevatedButton.icon(
//                   onPressed: _loading ? null : _signInWithGoogle,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                   ),
//                   icon: _loading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Icon(Icons.login_rounded),
//                   label:
//                       Text(_loading ? 'Signing in...' : 'Continue with Google'),
//                 ),
//               )
//                   .animate(delay: 800.ms)
//                   .slideY(begin: 0.5, curve: Curves.easeOutBack)
//                   .fadeIn(),
//               const SizedBox(height: 16),
//               Text(
//                 '100% free · No ads · Your data stays yours',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _listenForAuthChange();
  }

  void _listenForAuthChange() {
    // This listens in the background for when Google login completes
    // and the browser redirects back to the app
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        if (!mounted) return;

        // Check if this user has completed onboarding before
        final userId = session.user.id;
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        if (!mounted) return;

        if (profile == null) {
          // New user — go to onboarding
          Navigator.of(context).pushReplacementNamed('/onboarding');
        } else {
          // Returning user — go to dashboard
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.safescan://login-callback/',
      );
      // After this line the browser opens
      // Navigation happens in _listenForAuthChange() above
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 44,
                    color: AppColors.green,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(),
              ),

              const SizedBox(height: 24),

              Text(
                'SafeScan',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn(),

              const SizedBox(height: 8),

              Text(
                'Your personal AI health guardian',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(),

              const Spacer(),

              ...[
                ('🔍', 'Scan any food or cosmetic label'),
                ('🧬', 'Personalized to your health profile'),
                ('🌍', 'Global regulatory intelligence'),
                ('🔊', 'Full voice accessibility'),
              ].asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Text(entry.value.$1,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Text(entry.value.$2,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    )
                        .animate(delay: (400 + entry.key * 80).ms)
                        .slideX(begin: -0.2)
                        .fadeIn(),
                  ),

              const Spacer(),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.green.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.login_rounded, size: 22),
                  label: Text(
                    _loading ? 'Signing in...' : 'Continue with Google',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              )
                  .animate(delay: 800.ms)
                  .slideY(begin: 0.5, curve: Curves.easeOutBack)
                  .fadeIn(),

              const SizedBox(height: 16),

              Text(
                '100% free · No ads · Your data stays yours',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
