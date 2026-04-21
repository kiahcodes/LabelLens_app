import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _showContent = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    // Stagger content appearance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showContent = true);
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showButton = true);
    });
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Background decoration — subtle gradient mesh
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.15,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.amber.withValues(alpha: 0.06),
                    AppColors.amber.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo mark
                  _LogoMark()
                      .animate()
                      .scale(
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0.5, 0.5),
                      )
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // App name
                  AnimatedOpacity(
                    opacity: _showContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: AnimatedSlide(
                      offset: _showContent ? Offset.zero : const Offset(0, 0.3),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Label',
                                  style: GoogleFonts.inter(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.grey900,
                                    letterSpacing: -2.0,
                                    height: 1.0,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Lens',
                                  style: GoogleFonts.inter(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: -2.0,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Know what\'s in everything.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey500,
                              letterSpacing: -0.3,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Feature pills
                  AnimatedOpacity(
                    opacity: _showContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 700),
                    child: AnimatedSlide(
                      offset: _showContent ? Offset.zero : const Offset(0, 0.4),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        children: [
                          _FeatureRow(
                            icon: Icons.shield_outlined,
                            text: 'AI-powered ingredient safety analysis',
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _FeatureRow(
                            icon: Icons.person_outline_rounded,
                            text: 'Personalised for your health profile',
                            color: AppColors.amber,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _FeatureRow(
                            icon: Icons.public_outlined,
                            text: 'Global regulatory intelligence',
                            color: AppColors.danger,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // CTA button
                  AnimatedOpacity(
                    opacity: _showButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: AnimatedSlide(
                      offset: _showButton ? Offset.zero : const Offset(0, 0.5),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        children: [
                          PrimaryButton(
                            label: 'Get started',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _onGetStarted,
                            height: 56,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.green,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle inner highlight
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Icon(
            Icons.document_scanner_outlined,
            color: Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
