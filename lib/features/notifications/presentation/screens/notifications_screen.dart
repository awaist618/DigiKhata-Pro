import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/services.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'notifications'.tr(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: AppColors.primaryBlue),
            onPressed: () => ref.read(notificationActionsProvider.notifier).markAllAsRead(),
            tooltip: 'mark_all_read'.tr(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(isDarkMode);
          }

          final grouped = _groupNotifications(notifications);

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final item = grouped[index];
              if (item is String) {
                return _buildNotificationGroup(item, isDarkMode);
              } else {
                return _buildDismissibleItem(context, ref, item as NotificationModel, isDarkMode);
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  List<dynamic> _groupNotifications(List<NotificationModel> notifications) {
    final List<dynamic> grouped = [];
    String? currentGroup;

    for (final note in notifications) {
      final String groupName = _getGroupName(note.createdAt);
      if (groupName != currentGroup) {
        currentGroup = groupName;
        grouped.add(groupName);
      }
      grouped.add(note);
    }
    return grouped;
  }

  String _getGroupName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) return 'Today';
    if (noteDate == yesterday) return 'Yesterday';
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: isDarkMode ? Colors.white24 : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white54 : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationGroup(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDismissibleItem(BuildContext context, WidgetRef ref, NotificationModel notification, bool isDarkMode) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(notificationActionsProvider.notifier).deleteNotification(notification.id!);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.heavyImpact();
          _showDeleteDialog(context, ref, notification.id!);
        },
        child: _buildNotificationItem(context, notification, isDarkMode),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_notification_q'.tr()),
        content: Text('delete_notification_desc'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              ref.read(notificationActionsProvider.notifier).deleteNotification(id);
              Navigator.pop(context);
            },
            child: Text('delete'.tr(), style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notification, bool isDarkMode) {
    final color = _getIconColor(notification.type);
    final icon = _getIcon(notification.type);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: notification.isRead ? null : Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Text(
                      timeago.format(notification.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return AppColors.danger;
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.announcement:
        return AppColors.amberGold;
      case NotificationType.info:
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.success:
        return Icons.check_circle_outline_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.info:
      default:
        return Icons.info_outline_rounded;
    }
  }
}
