import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import '../../data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return DashboardRepository(supabase.client);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final businessId = ref.watch(selectedBusinessIdProvider);
  
  if (businessId == null) throw 'No business selected';
  
  return await repository.getDashboardStats(businessId);
});
