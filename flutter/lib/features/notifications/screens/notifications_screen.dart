import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _notifications = [];
          _loading = false;
        });
      }
      return;
    }

    try {
      final result = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);
      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(result ?? []);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(String id) async {
    await Supabase.instance.client
        .from('notifications')
        .update({'is_read': true}).eq('id', id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      const Icon(
                        Icons.notifications_none_outlined,
                        size: 64,
                        color: Color(0xFFBBBBBB),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      final isRead = n['is_read'] as bool? ?? false;
                      return GestureDetector(
                        onTap: () => _markRead(n['id'] as String),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isRead ? Colors.white : AppColors.greenLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isRead
                                  ? AppColors.borderLight
                                  : AppColors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isRead
                                      ? Colors.transparent
                                      : AppColors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['title'] as String? ?? '',
                                      style: TextStyle(
                                        fontWeight: isRead
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if ((n['body'] as String? ?? '')
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        n['body'] as String? ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF888888),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
