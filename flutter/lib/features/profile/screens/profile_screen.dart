import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _saving = false;
  bool _deleting = false;
  final _nameCtrl = TextEditingController();
  bool _isPregnant = false;
  bool _babyMode = false;
  List<String> _allergies = [];
  String _language = 'en';

  static const _allergyOptions = [
    'Gluten',
    'Dairy',
    'Eggs',
    'Nuts',
    'Peanuts',
    'Soy',
    'Fish',
    'Shellfish',
    'Sesame',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (mounted && data != null) {
      setState(() {
        _nameCtrl.text = data['name'] as String? ?? '';
        _isPregnant = data['is_pregnant'] as bool? ?? false;
        _babyMode = data['baby_mode'] as bool? ?? false;
        _allergies = List<String>.from(data['allergies'] as List? ?? []);
        _language = data['preferred_language'] as String? ?? 'en';
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client.from('profiles').update({
        'name': _nameCtrl.text.trim(),
        'is_pregnant': _isPregnant,
        'baby_mode': _babyMode,
        'allergies': _allergies,
        'preferred_language': _language,
      }).eq('user_id', userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: AppColors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Save failed: $e'), backgroundColor: AppColors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account, profile, scan history, '
          'and notifications. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You are not signed in.'),
          backgroundColor: AppColors.red,
        ));
      }
      return;
    }

    setState(() => _deleting = true);
    try {
      await ApiService().deleteAccount(session.accessToken);
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } on DioException catch (e) {
      final detail = e.response?.data;
      final message = detail is Map && detail['detail'] != null
          ? detail['detail'].toString()
          : e.message ?? 'Request failed';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Delete failed: $message'),
          backgroundColor: AppColors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: AppColors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.green))
                : const Text('Save',
                    style: TextStyle(
                        color: AppColors.green, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                        color: AppColors.greenLight, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        (_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : '?')
                            .toUpperCase(),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    Supabase.instance.client.auth.currentUser?.email ?? '',
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionLabel('Personal info'),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Health modes'),
                _Toggle(
                    icon: '🤰',
                    title: 'Pregnancy mode',
                    value: _isPregnant,
                    onChanged: (v) => setState(() => _isPregnant = v)),
                _Toggle(
                    icon: '👶',
                    title: 'Baby mode',
                    value: _babyMode,
                    onChanged: (v) => setState(() => _babyMode = v)),
                const SizedBox(height: 20),
                const _SectionLabel('Known allergies'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allergyOptions.map((a) {
                    final sel = _allergies.contains(a);
                    return FilterChip(
                      label: Text(a),
                      selected: sel,
                      selectedColor: AppColors.green.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.green,
                      onSelected: (v) => setState(
                          () => v ? _allergies.add(a) : _allergies.remove(a)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Language'),
                Row(children: [
                  Expanded(
                      child: _LangBtn(
                          label: 'English',
                          selected: _language == 'en',
                          onTap: () => setState(() => _language = 'en'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _LangBtn(
                          label: 'Hindi',
                          selected: _language == 'hi',
                          onTap: () => setState(() => _language = 'hi'))),
                ]),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: _deleting ? null : _confirmDeleteAccount,
                  icon: _deleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.red,
                          ),
                        )
                      : const Icon(Icons.delete_outline, size: 18),
                  label: Text(_deleting ? 'Deleting...' : 'Delete account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF888888))),
      );
}

class _Toggle extends StatelessWidget {
  final String icon, title;
  final bool value;
  final Function(bool) onChanged;
  const _Toggle(
      {required this.icon,
      required this.title,
      required this.value,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: value ? AppColors.greenLight : AppColors.subtleLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: value
                  ? AppColors.green.withValues(alpha: 0.3)
                  : AppColors.borderLight),
        ),
        child: SwitchListTile(
          secondary: Text(icon, style: const TextStyle(fontSize: 22)),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.green,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      );
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangBtn(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.greenLight : AppColors.subtleLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.green : AppColors.borderLight,
                width: selected ? 1.5 : 0.5),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.green : const Color(0xFF555555))),
        ),
      );
}
