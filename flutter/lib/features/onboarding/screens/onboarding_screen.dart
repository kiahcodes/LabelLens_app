import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State {
  final _controller = PageController();
  int _page = 0;
  bool _saving = false;

  String _name = '';
  int _age = 25;
  String _gender = 'Prefer not to say';
  bool _isPregnant = false;
  // bool _isBreastfeeding = false;
  bool _babyMode = false;
  List _allergies = [];
  String _skinType = 'Normal';
  List _dietary = [];
  String _language = 'en';

  void _next() {
    if (_page < 5) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _saveAndFinish();
    }
  }

  void _back() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Use a different account?'),
        content: const Text(
          'You will be signed out and can log in with another account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Future _saveAndFinish() async {
    setState(() => _saving = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client.from('profiles').upsert({
        'user_id': userId,
        'name': _name,
        'age': _age,
        'gender': _gender,
        'is_pregnant': _isPregnant,
        'is_breastfeeding': false, // always false now
        'baby_mode': _babyMode,
        'allergies': _allergies,
        'skin_type': _skinType,
        'dietary_restrictions': _dietary,
        'preferred_language': _language,
      });
      if (mounted) Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: _page > 0 ? 'Back' : 'Change account',
                    onPressed: _saving ? null : _back,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Step ${_page + 1} of 6',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_page + 1) / 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.green),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _Page1(
                      name: _name,
                      age: _age,
                      gender: _gender,
                      onChanged: (n, a, g) => setState(() {
                            _name = n;
                            _age = a;
                            _gender = g;
                          })),
                  // _Page2(
                  //     pregnant: _isPregnant,
                  //     breastfeeding: _isBreastfeeding,
                  //     baby: _babyMode,
                  //     onChanged: (p, b, bm) => setState(() {
                  //           _isPregnant = p;
                  //           _isBreastfeeding = b;
                  //           _babyMode = bm;
                  //         })),
                  _Page2(
                    pregnant: _isPregnant,
                    baby: _babyMode,
                    onChanged: (p, b) => setState(() {
                      _isPregnant = p;
                      _babyMode = b;
                    }),
                  ),
                  _Page3(
                      allergies: _allergies,
                      onChanged: (a) => setState(() => _allergies = a)),
                  _Page4(
                      skinType: _skinType,
                      onChanged: (s) => setState(() => _skinType = s)),
                  _Page5(
                      dietary: _dietary,
                      onChanged: (d) => setState(() => _dietary = d)),
                  _Page6(
                      language: _language,
                      onChanged: (l) => setState(() => _language = l)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_page == 5 ? 'Get started' : 'Continue',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PAGE 1: Name, Age, Gender ──────────────────────────
class _Page1 extends StatelessWidget {
  final String name;
  final int age;
  final String gender;
  final Function(String, int, String) onChanged;
  const _Page1(
      {required this.name,
      required this.age,
      required this.gender,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about yourself',
                  style: Theme.of(context).textTheme.headlineMedium)
              .animate()
              .fadeIn()
              .slideY(begin: 0.3),
          const SizedBox(height: 8),
          Text('We use this to personalize your safety analysis.',
                  style: Theme.of(context).textTheme.bodyMedium)
              .animate(delay: 100.ms)
              .fadeIn(),
          const SizedBox(height: 32),
          TextFormField(
            initialValue: name,
            decoration: const InputDecoration(labelText: 'Your name'),
            onChanged: (v) => onChanged(v, age, gender),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: age.toString(),
            decoration: const InputDecoration(labelText: 'Your age'),
            keyboardType: TextInputType.number,
            onChanged: (v) => onChanged(name, int.tryParse(v) ?? age, gender),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            initialValue: gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: ['Male', 'Female', 'Non-binary', 'Prefer not to say']
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => onChanged(name, age, v ?? gender),
          ),
        ],
      ),
    );
  }
}

// ── PAGE 2: Health modes (breastfeeding removed) ───────
class _Page2 extends StatelessWidget {
  final bool pregnant;
  final bool baby;
  final Function(bool, bool) onChanged;
  const _Page2({
    required this.pregnant,
    required this.baby,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Special health modes',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Turn on to get extra safety warnings tailored to your situation.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _ToggleTile(
            icon: '🤰',
            title: 'Pregnancy mode',
            sub: 'Flags ingredients unsafe during pregnancy',
            value: pregnant,
            onChanged: (v) => onChanged(v, baby),
          ),
          _ToggleTile(
            icon: '👶',
            title: 'Baby mode',
            sub: 'Flags ingredients unsafe for infants',
            value: baby,
            onChanged: (v) => onChanged(pregnant, v),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String icon, title, sub;
  final bool value;
  final Function(bool) onChanged;
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: value ? AppColors.primarySurface : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: value ? AppColors.primaryBorder : AppColors.borderLight,
          width: value ? 1.5 : 1.0,
        ),
        boxShadow: value ? AppShadows.sm : [],
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: value ? AppColors.primary : AppColors.grey900,
          ),
        ),
        subtitle: Text(
          sub,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.grey500,
            height: 1.4,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

// ── PAGE 3: Allergies ──────────────────────────────────
class _Page3 extends StatelessWidget {
  final List allergies;
  final Function(List) onChanged;
  const _Page3({required this.allergies, required this.onChanged});
  static const _opts = [
    'Gluten',
    'Dairy',
    'Eggs',
    'Nuts',
    'Peanuts',
    'Soy',
    'Fish',
    'Shellfish',
    'Sesame',
    'Sulfites'
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Known allergies',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('We alert you when allergens are detected.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _opts.map((a) {
              final sel = allergies.contains(a);
              return FilterChip(
                label: Text(a),
                selected: sel,
                selectedColor: AppColors.green.withOpacity(0.2),
                checkmarkColor: AppColors.green,
                onSelected: (v) {
                  final next = [...allergies];
                  v ? next.add(a) : next.remove(a);
                  onChanged(next);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── PAGE 4: Skin type ──────────────────────────────────
class _Page4 extends StatelessWidget {
  final String skinType;
  final Function(String) onChanged;
  const _Page4({required this.skinType, required this.onChanged});
  static const _types = ['Normal', 'Dry', 'Oily', 'Combination', 'Sensitive'];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your skin type',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Used for cosmetic product analysis.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ..._types.map((s) => RadioListTile(
                title: Text(s),
                value: s,
                groupValue: skinType,
                activeColor: AppColors.green,
                onChanged: (v) => onChanged(v ?? skinType),
              )),
        ],
      ),
    );
  }
}

// ── PAGE 5: Dietary restrictions ───────────────────────
class _Page5 extends StatelessWidget {
  final List dietary;
  final Function(List) onChanged;
  const _Page5({required this.dietary, required this.onChanged});
  static const _opts = [
    'Vegan',
    'Vegetarian',
    'Halal',
    'Kosher',
    'Diabetic',
    'Keto',
    'Gluten-free',
    'Jain'
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dietary restrictions',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Select all that apply.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _opts.map((d) {
              final sel = dietary.contains(d);
              return FilterChip(
                label: Text(d),
                selected: sel,
                selectedColor: AppColors.amber.withOpacity(0.2),
                checkmarkColor: AppColors.amber,
                onSelected: (v) {
                  final next = [...dietary];
                  v ? next.add(d) : next.remove(d);
                  onChanged(next);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── PAGE 6: Language ───────────────────────────────────
class _Page6 extends StatelessWidget {
  final String language;
  final Function(String) onChanged;
  const _Page6({required this.language, required this.onChanged});
  static const _langs = {'en': 'English', 'hi': 'Hindi'};
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferred language',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Results will be shown in this language.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ..._langs.entries.map((e) => RadioListTile(
                title: Text(e.value),
                value: e.key,
                groupValue: language,
                activeColor: AppColors.green,
                onChanged: (v) => onChanged(v ?? language),
              )),
        ],
      ),
    );
  }
}
