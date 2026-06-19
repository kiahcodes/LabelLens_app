import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/theme/app_theme.dart';

enum AuthMode { login, signup }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthMode _mode = AuthMode.login;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _listenForAuthChange();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _listenForAuthChange() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        if (!mounted) return;
        final userId = session.user.id;
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (!mounted) return;
        if (profile == null) {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        } else {
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
        redirectTo: kAuthRedirectUrl,
      );
    } catch (e) {
      _showError('Google sign in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_mode == AuthMode.login) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'name': _nameController.text.trim()},
        );
        if (response.user != null && mounted) {
          _showSuccess(
              'Account created! Check your email to verify, then log in.');
          setState(() => _mode = AuthMode.login);
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == AuthMode.login;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Logo + title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            size: 36, color: AppColors.green),
                      )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      Text('LabelLens',
                              style: Theme.of(context).textTheme.headlineMedium)
                          .animate(delay: 100.ms)
                          .fadeIn(),
                      const SizedBox(height: 4),
                      Text(
                        isLogin ? 'Welcome back' : 'Create your account',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate(delay: 150.ms).fadeIn(),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Tab switcher
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.subtleLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _TabBtn(
                        label: 'Log in',
                        active: isLogin,
                        onTap: () => setState(() => _mode = AuthMode.login),
                      ),
                      _TabBtn(
                        label: 'Sign up',
                        active: !isLogin,
                        onTap: () => setState(() => _mode = AuthMode.signup),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Name field (signup only)
                if (!isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
                  ).animate().fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 14),
                ],

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email address'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate(delay: 50.ms).fadeIn(),

                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (!isLogin && v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate(delay: 100.ms).fadeIn(),

                // Confirm password (signup only)
                if (!isLogin) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmController,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    obscureText: _obscureConfirm,
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ).animate(delay: 150.ms).fadeIn(),
                ],

                // Forgot password (login only)
                if (isLogin) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.green,
                          padding: EdgeInsets.zero),
                      child: const Text('Forgot password?',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Main button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitEmailAuth,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(isLogin ? 'Log in' : 'Create account'),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider()),
                ]),

                const SizedBox(height: 20),

                // Google button
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.login_rounded,
                        size: 18, color: AppColors.green),
                    label: const Text('Continue with Google',
                        style: TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w500)),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Enter your email address first');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: kAuthRedirectUrl,
      );
      _showSuccess(
          'Password reset email sent. Open the link on this device to set a new password.');
    } catch (e) {
      _showError('Could not send reset email. Try again.');
    }
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1))
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? const Color(0xFF111111) : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }
}
