import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';
import '../../../services/api_service.dart';
import '../../analysis/screens/analysis_screen.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});
  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<Map<String, dynamic>> _scans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await ApiService().getScanHistory(userId);
      if (mounted) setState(() { _scans = data; _loading = false; });
    } catch (_) {
      try {
        final data = await Supabase.instance.client
            .from('scan_history')
            .select('id,product_name,brand,product_type,verdict,overall_safety_score,scanned_at')
            .eq('user_id', userId)
            .order('scanned_at', ascending: false)
            .limit(50);
        if (mounted) setState(() {
          _scans = List<Map<String, dynamic>>.from(data ?? []);
          _loading = false;
        });
      } catch (e) {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Scan history')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : _scans.isEmpty
              ? const Center(child: Text('No scans yet'))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.green,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scans.length,
                    itemBuilder: (_, i) {
                      final s = _scans[i];
                      final verdict = s['verdict'] as String? ?? 'YELLOW';
                      final color = verdict == 'GREEN'
                          ? AppColors.green
                          : verdict == 'RED'
                              ? AppColors.red
                              : AppColors.amber;
                      final label = verdict == 'GREEN'
                          ? 'Safe'
                          : verdict == 'RED'
                              ? 'Avoid'
                              : 'Caution';
                      return GestureDetector(
                        onTap: () async {
                          final id = s['id'] as String? ?? '';
                          if (id.isEmpty) return;
                          try {
                            final j = await ApiService().getScan(id);
                            final r = ScanResult.fromJson(j);
                            if (context.mounted) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AnalysisScreen(result: r)));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not load: $e')));
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
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                s['product_type'] == 'food'
                                    ? Icons.restaurant_outlined
                                    : Icons.spa_outlined,
                                color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['product_name'] as String? ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600, fontSize: 14)),
                                Text(s['brand'] as String? ?? '',
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF888888))),
                              ],
                            )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20)),
                                  child: Text(label,
                                      style: TextStyle(
                                          color: color, fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(height: 4),
                                Text('${s['overall_safety_score']}/100',
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF888888))),
                              ],
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}