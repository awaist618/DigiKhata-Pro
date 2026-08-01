import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/services/backup_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;

class BackupManagementScreen extends ConsumerStatefulWidget {
  const BackupManagementScreen({super.key});

  @override
  ConsumerState<BackupManagementScreen> createState() => _BackupManagementScreenState();
}

class _BackupManagementScreenState extends ConsumerState<BackupManagementScreen> {
  bool _isLoading = false;
  List<File> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final backups = await ref.read(backupServiceProvider).getBackups();
    setState(() => _backups = backups);
  }

  Future<void> _createManualBackup() async {
    setState(() => _isLoading = true);
    final path = await ref.read(backupServiceProvider).createBackup();
    setState(() => _isLoading = false);

    if (path != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully!'), backgroundColor: AppColors.success),
        );
        _loadBackups();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create backup'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Data & Backups', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadBackups,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDarkMode),
              const SizedBox(height: 32),
              Text(
                'Recent Backups',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (_backups.isEmpty)
                _buildEmptyState(isDarkMode)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _backups.length,
                  itemBuilder: (context, index) {
                    final file = _backups[index];
                    return _buildBackupTile(file, isDarkMode);
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _createManualBackup,
          icon: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.add_circle_outline),
          label: Text(_isLoading ? 'Creating...' : 'Create Backup Now', style: const TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepNavy, AppColors.electricBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 48),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automatic Backups',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Backups are created daily to ensure your data is safe.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.history, size: 64, color: isDarkMode ? Colors.white10 : Colors.black12),
          const SizedBox(height: 16),
          Text(
            'No local backups found',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTile(File file, bool isDarkMode) {
    final stat = file.statSync();
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(stat.modified);
    final size = (stat.size / 1024).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white10 : AppColors.border),
      ),
      child: ListTile(
        onTap: () => _confirmRestore(file),
        leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryBlue),
        title: Text(
          p.basename(file.path),
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text('$dateStr • $size KB', style: const TextStyle(fontSize: 11)),
        trailing: IconButton(
          icon: const Icon(Icons.share, size: 20),
          onPressed: () => Share.shareXFiles([XFile(file.path)], text: 'My DigiKhata Pro Backup'),
        ),
      ),
    );
  }

  void _confirmRestore(File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Restore Backup?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text(
          'This will replace ALL current data on this device with the data from this backup. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRestore(file);
            },
            child: const Text('Restore Now', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleRestore(File file) async {
    setState(() => _isLoading = true);
    final success = await ref.read(backupServiceProvider).restoreBackup(file);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Restore Successful'),
            content: const Text('Your data has been restored. The app will now restart to apply changes.'),
            actions: [
              TextButton(
                onPressed: () {
                  // For a real restart, you'd use a package or exit(0)
                  // For now, navigating to splash is sufficient to refresh providers
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Restart App'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore failed!'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
