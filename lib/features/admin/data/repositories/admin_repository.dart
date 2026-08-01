import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_stats.dart';
import '../../../profile/data/models/user_model.dart';
import '../../../business/data/models/business_model.dart'; // Assume exists or create
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
      
      return AdminStats(
        totalUsers: userRes.count,
        totalBusinesses: businessRes.count,
        totalTransactions: txRes.count,
        totalRevenue: (revenueData['total_revenue'] as num?)?.toDouble() ?? 0.0,
        weeklyRevenue: List<double>.from((revenueData['weekly_revenue'] as List?)?.map((e) => (e as num).toDouble()) ?? List.filled(7, 0.0)),
        blockedUsers: 0, // Fetch from profiles where is_blocked = true
      );
    } catch (e) {
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
    // Note: In Supabase, deleting from auth.users requires service role key or admin API
    // For now, we delete the profile or mark as deleted
    await _client.from('profiles').delete().eq('id', userId);
  }

  // Business Management
  Future<List<Map<String, dynamic>>> getBusinesses() async {
    return await _client.from('businesses').select('*, profiles(full_name)').order('created_at', ascending: false);
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
    // In production, this would trigger a Supabase Edge Function to hit FCM
    // For now, we simulate by adding to a broadcast queue table
    await _client.from('broadcasts').insert({
      'title': title,
      'body': body,
      'target': target,
      'sent_at': DateTime.now().toIso8601String(),
    });
  }
}
