import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/services/connectivity_service.dart';
import 'package:khataplus/core/providers/database_provider.dart';
import 'package:drift/drift.dart';

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final countExp = db.syncQueue.id.count();
  return (db.selectOnly(db.syncQueue)..addColumns([countExp]))
      .watchSingle()
      .map((row) => row.read(countExp) ?? 0);
});

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;

    // Only show if truly disconnected
    if (status != ConnectivityStatus.isDisconnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: AppColors.danger,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            'You are offline. $pendingCount items pending sync.',
            style: GoogleFonts.inter(
              color: Colors.white, 
              fontSize: 12, 
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
