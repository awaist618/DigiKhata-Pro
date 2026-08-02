import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_stats.dart';
import '../../../profile/data/models/user_model.dart';
import '../../../business/data/models/business_model.dart';
import '../../../../features/dashboard/data/models/transaction_model.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<AdminStats> getDashboardStats() async {
    try {
      final userRes = await _client.from('profiles').select('id').count(CountOption.exact);
      final businessRes = await _client.from('businesses').select('id').count(CountOption.exact);
      final txRes = await _client.from('transactions').select('id').count(CountOption.exact);
      
      final revenueData = await _client.rpc('get_admin_revenue_stats');
      
      final List<AdminAlert> alerts = [];
      
      try {
        final recentUsers = await _client.from('profiles')
            .select('full_name, created_at')
            .order('created_at', ascending: false)
            .limit(2);
        for (var u in recentUsers) {
          alerts.add(AdminAlert(
            title: 'New user: ${u['full_name'] ?? 'User'}',
            timestamp: DateTime.parse(u['created_at']),
            type: 'user',
          ));
        }

        final bigTx = await _client.from('transactions')
            .select('amount, created_at')
            .order('amount', ascending: false)
            .limit(2);
        for (var tx in bigTx) {
          if ((tx['amount'] as num) > 5000) {
            alerts.add(AdminAlert(
              title: 'High volume: PKR ${tx['amount']}',
              timestamp: DateTime.parse(tx['created_at']),
              type: 'transaction',
            ));
          }
        }
      } catch (_) {}

      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return AdminStats(
        totalUsers: userRes.count,
        totalBusinesses: businessRes.count,
        totalTransactions: txRes.count,
        totalRevenue: (revenueData['total_revenue'] as num?)?.toDouble() ?? 0.0,
        weeklyRevenue: List<double>.from((revenueData['weekly_revenue'] as List?)?.map((e) => (e as num).toDouble()) ?? List.filled(7, 0.0)),
        blockedUsers: 0,
        recentAlerts: alerts.take(4).toList(),
      );
    } catch (e) {
      debugPrint('AdminStats Error: $e');
      return AdminStats.empty();
    }
  }

  // User Management
  Future<List<UserModel>> getUsers() async {
    final response = await _client.from('profiles').select().order('created_at', ascending: false);
    return (response as List).map((json) => UserModel.fromJson(json)).toList();
  }

  Future<void> updateBlockStatus(String userId, bool isBlocked) async {
    await _client.from('profiles').update({'is_blocked': isBlocked}).eq('id', userId);
  }

  Future<void> deleteUser(String userId) async {
    await _client.from('profiles').delete().eq('id', userId);
  }

  // Business Management
  Future<List<Map<String, dynamic>>> getBusinesses() async {
    try {
      final response = await _client.from('businesses')
          .select('*, profiles!owner_id(full_name)')
          .order('created_at', ascending: false);
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('Error fetching businesses: $e');
      rethrow;
    }
  }

  // Banners
  Future<List<Map<String, dynamic>>> getBanners() async {
    return await _client.from('banners').select().order('created_at', ascending: false);
  }

  // Announcements
  Future<void> createAnnouncement(String title, String body) async {
    await _client.from('announcements').insert({
      'title': title,
      'body': body,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Banners
  Future<void> addBanner(String title, String imageUrl, String? link) async {
    await _client.from('banners').insert({
      'title': title,
      'image_url': imageUrl,
      'link': link,
      'is_active': true,
    });
  }

  // Broadcaster
  Future<void> broadcastNotification(String title, String body, String target) async {
    await _client.from('broadcasts').insert({
      'title': title,
      'body': body,
      'target': target,
      'sent_at': DateTime.now().toIso8601String(),
    });

    try {
      await _client.functions.invoke('send-broadcast', body: {
        'title': title,
        'message': body,
        'target': target,
      });
      debugPrint('FCM Edge Function invoked successfully');
    } catch (e) {
      debugPrint('FCM Edge Function failed (expected if not deployed): $e');
    }
  }

  Future<void> deleteBanner(dynamic id) async {
    await _client.from('banners').delete().eq('id', id);
  }

  // System Settings
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final res = await _client.from('system_settings').select();
      final Map<String, dynamic> settings = {};
      for (var item in (res as List)) {
        settings[item['key']] = item['value'];
      }
      return settings;
    } catch (e) {
      debugPrint('Error fetching system settings: $e');
      return {
        'maintenance_mode': 'false',
        'terms_and_conditions': '',
        'privacy_policy': '',
      };
    }
  }

  Future<void> updateSystemSetting(String key, String value) async {
    await _client.from('system_settings').upsert({
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Report Data Fetching
  Future<List<Map<String, dynamic>>> getUserGrowthData() async {
    return await _client.rpc('get_user_growth_stats');
  }

  Future<List<Map<String, dynamic>>> getBusinessActivityData() async {
    return await _client.from('businesses').select('type, id');
  }

  Future<List<Map<String, dynamic>>> getTransactionVolumeData() async {
    return await _client.from('transactions').select('amount, type, created_at');
  }

  Future<List<Map<String, dynamic>>> getComplianceAuditData() async {
    // This could be from a dedicated logs table if it exists, 
    // otherwise we use profiles/transactions as proxy
    return await _client.from('profiles').select('email, created_at, is_blocked');
  }
}
