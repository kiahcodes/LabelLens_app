import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../scan/screens/product_type_screen.dart';
import '../../../models/scan_result.dart';
import '../../analysis/screens/analysis_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../scan/screens/scan_history_screen.dart';
import 'dart:convert';
import '../../../core/constants/demo_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _profile;
  Map? _topProduct;
  RealtimeChannel? _channel;
  List<Map<String, dynamic>> _recentScans = [];
  bool _loading = true;
  int _unreadCount = 0;

  void _subscribeToScans() {
    final userId =
        Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _channel = Supabase.instance.client
        .channel('public:scan_history:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'scan_history',
          filter: PostgresChangeFilter(
            type: FilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // New scan saved — refresh dashboard
            if (mounted) _loadData();
          },
        )
        .subscribe();
  }

  @override
 void initState() {
  super.initState();
  _loadData();
  _subscribeToScans(); // ADD THIS
 }

  @override
  void dispose() {
    _channel?.unsubscribe(); // ADD THIS
    super.dispose();
  }

  // ONLY showing modified sections — rest remains EXACTLY same

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // ✅ FIX 1: prevent infinite loading
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final apiService = ApiService();
      final scans = await apiService.getScanHistory(userId);

      // Count unread notifications
      try {
        if (userId != null) {
          final notifs = await Supabase.instance.client
              .from('notifications')
              .select('id')
              .eq('user_id', userId)
              .eq('is_read', false);

          if (mounted) {
            setState(() =>
                // ✅ FIX 3: safe casting
                _unreadCount = (notifs is List) ? notifs.length : 0);
          }
        }
      } catch (_) {}

      Map? top;
        try {
          top = await Supabase.instance.client
              .from('community_stats')
              .select(
                  'product_name,brand,scan_count,avg_safety_score,verdict')
              .order('scan_count', ascending: false)
              .limit(1)
              .maybeSingle();
        } catch (_) {
          // Community stats non-critical
        }
      if (mounted) {
        setState(() {
          _profile = profile;
          _recentScans = scans;
          _topProduct = top;
          _loading = false;
        });
      }
    } catch (e) {
      try {
        final scans = await Supabase.instance.client
            .from('scan_history')
            .select(
                'id,product_name,brand,product_type,verdict,overall_safety_score,scanned_at')
            .eq('user_id', userId)
            .order('scanned_at', ascending: false)
            .limit(10);

        if (mounted) {
          setState(() {
            _recentScans = List<Map<String, dynamic>>.from(scans ?? []);
            _loading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showDemoMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Demo mode',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Load a pre-cached scan — works offline',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(height: 16),
            _buildDemoBtn('RED verdict product', AppColors.red, kDemoScanRed),
            const SizedBox(height: 8),
            _buildDemoBtn(
                'YELLOW verdict product', AppColors.amber, kDemoScanYellow),
            const SizedBox(height: 8),
            _buildDemoBtn(
                'GREEN verdict product', AppColors.green, kDemoScanGreen),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoBtn(String label, Color color, String json) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          side: BorderSide(color: color.withValues(alpha: 0.3))),
      onPressed: () {
        Navigator.of(context).pop();
        try {
          final result =
              ScanResult.fromJson(jsonDecode(json) as Map<String, dynamic>);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AnalysisScreen(result: result)));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong loading demo'),
            ),
          );
        }
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name'] as String? ?? 'there';
    final isPregnant = _profile?['is_pregnant'] as bool? ?? false;
    final babyMode = _profile?['baby_mode'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_greeting, $name',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (isPregnant || babyMode)
              Text(
                [
                  if (isPregnant) 'Pregnancy mode ON',
                  if (babyMode) 'Baby mode ON',
                ].join(' · '),
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.amber,
                    fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()))
                    .then((_) => _loadData()),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          TextButton(
            onPressed: _showDemoMenu,
            child: const Text('Demo',
                style: TextStyle(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: _signOut,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 22),
            onPressed: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                )
                .then((_) => _loadData()),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.green,
        onRefresh: _loadData,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.green))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(children: [
                    Expanded(
                      child: _CtaCard(
                        title: 'New scan',
                        subtitle: 'Scan a product',
                        icon: Icons.document_scanner_outlined,
                        color: AppColors.green,
                        bgColor: AppColors.greenLight,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ProductTypeScreen()),
                        ),
                      ).animate(delay: 50.ms).slideY(begin: 0.3).fadeIn(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CtaCard(
                        title: 'History',
                        subtitle: '${_recentScans.length} scans',
                        icon: Icons.history_rounded,
                        color: AppColors.amber,
                        bgColor: AppColors.amberLight,
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ScanHistoryScreen())),
                      ).animate(delay: 100.ms).slideY(begin: 0.3).fadeIn(),
                    ),
                  ]),

                  if (_topProduct != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(children: [
                        const Icon(
                          Icons.people_outline_rounded,
                          color: AppColors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF333333),
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${_topProduct!['scan_count']} people ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.green,
                                  ),
                                ),
                                const TextSpan(text: 'scanned '),
                                TextSpan(
                                  text:
                                      '${_topProduct!['product_name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' recently'),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 32),
                  if (_recentScans.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent scans',
                            style: Theme.of(context).textTheme.titleMedium),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ScanHistoryScreen()),
                          ),
                          child: Text('See all',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._recentScans.asMap().entries.map(
                          (e) => _ScanItem(scan: e.value)
                              .animate(delay: (e.key * 50).ms)
                              .slideX(begin: -0.15)
                              .fadeIn(),
                        ),
                  ] else
                    _EmptyState(),
                ],
              ),
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color, bgColor;
  final VoidCallback onTap;
  const _CtaCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
          ],
        ),
      ),
    );
  }
}

class _ScanItem extends StatelessWidget {
  final Map<String, dynamic> scan;
  const _ScanItem({required this.scan});

  Color get _verdictColor {
    switch (scan['verdict'] as String?) {
      case 'GREEN':
        return AppColors.green;
      case 'RED':
        return AppColors.red;
      default:
        return AppColors.amber;
    }
  }

  String get _verdictLabel {
    switch (scan['verdict'] as String?) {
      case 'GREEN':
        return 'Safe';
      case 'RED':
        return 'Avoid';
      default:
        return 'Caution';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final scanId = scan['id'] as String? ?? '';
        if (scanId.isEmpty) return;
        try {
          final apiService = ApiService();
          final resultJson = await apiService.getScan(scanId);
          final result = ScanResult.fromJson(resultJson);
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AnalysisScreen(result: result)),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not load scan: $e')),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _verdictColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              scan['product_type'] == 'food'
                  ? Icons.restaurant_outlined
                  : Icons.spa_outlined,
              color: _verdictColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan['product_name'] as String? ?? 'Unknown',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  scan['brand'] as String? ?? '',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _verdictColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_verdictLabel,
                    style: TextStyle(
                        color: _verdictColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Text(
                '${scan['overall_safety_score']}/100',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ]),
      ),
    );
  } // ← closing brace that was missing
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.subtleLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.document_scanner_outlined,
                size: 36, color: Color(0xFFBBBBBB)),
          ),
          const SizedBox(height: 16),
          const Text('No scans yet',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF333333))),
          const SizedBox(height: 6),
          const Text('Tap New scan to analyse your first product',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
        ]),
      ),
    );
  }
}
