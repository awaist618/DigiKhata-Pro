import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'package:khataplus/core/providers/database_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DashboardRepository(database);
});

final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final businessId = ref.watch(selectedBusinessIdProvider);
  
  if (businessId == null) return Stream.value(DashboardStats.empty());
  
  return repository.watchDashboardStats(businessId);
});
