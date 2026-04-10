import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../models/scan_result.dart';
import '../../analysis/screens/analysis_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String ocrText;
  final String productType;
  const LoadingScreen({
    super.key,
    required this.ocrText,
    required this.productType,
  });
  @override
  State createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _messageIndex = 0;
  final List _messages = [
    'Extracting ingredients...',
    'Analysing safety...',
    'Personalising for your profile...',
    'Fetching safer alternatives...',
    'Almost done...',
  ];

  @override
  void initState() {
    super.initState();
    _startMessageCycle();
    _runScan();
  }

  void _startMessageCycle() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
      return mounted;
    });
  }

  Future _runScan() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    try {
      // Load user profile for personalization
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final userProfile = {
        'allergies': List.from(profileData?['allergies'] ?? []),
        'is_pregnant': profileData?['is_pregnant'] as bool? ?? false,
        'baby_mode': profileData?['baby_mode'] as bool? ?? false,
        'dietary_restrictions':
            List.from(profileData?['dietary_restrictions'] ?? []),
        'skin_type': profileData?['skin_type'] as String? ?? 'Normal',
        'preferred_language':
            profileData?['preferred_language'] as String? ?? 'en',
      };
      final preferredLanguage =
          profileData?['preferred_language'] as String? ?? 'en';

      final apiService = ApiService();
      final resultJson = await apiService.scan(
        ocrText: widget.ocrText,
        productType: widget.productType,
        userProfile: userProfile,
        userId: userId,
      );

      final result = ScanResult.fromJson(resultJson);

      if (mounted) {
        // Replace entire scan stack with analysis screen
        // In _runScan(), after getting profileData:
        final preferredLanguage =
            profileData?['preferred_language'] as String? ?? 'en';

// Update the Navigator push to AnalysisScreen:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(
              result: result,
              preferredLanguage: preferredLanguage, // ADD
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: AppColors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.green,
                  strokeWidth: 3,
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This takes 5-10 seconds',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
