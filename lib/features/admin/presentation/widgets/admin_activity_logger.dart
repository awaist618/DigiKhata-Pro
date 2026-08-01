import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khataplus/core/services/supabase_service.dart';

final adminActivityProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider).client;
  final response = await supabase
      .from('admin_logs')
      .select('*, profiles(full_name)')
      .order('created_at', ascending: false)
      .limit(10);
  return List<Map<String, dynamic>>.from(response);
});

class AdminActivityLogger {
  static Future<void> log(SupabaseClient client, String action, String details) async {
    try {
      await client.from('admin_logs').insert({
        'admin_id': client.auth.currentUser?.id,
        'action': action,
        'details': details,
      });
    } catch (_) {}
  }
}
