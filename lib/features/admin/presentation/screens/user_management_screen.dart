import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../providers/admin_provider.dart';
import '../../../profile/data/models/user_model.dart';
import 'package:intl/intl.dart';

import 'package:easy_localization/easy_localization.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('user_management'.tr(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'search_users_hint'.tr(),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                filled: true,
                fillColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filteredUsers = users.where((u) => 
                  (u.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                  u.email.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (filteredUsers.isEmpty) {
                  return Center(child: Text('no_users_found'.tr()));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user, isDarkMode);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: isDarkMode ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.adminPrimary.withValues(alpha: 0.2), AppColors.adminPrimary.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                user.fullName?[0].toUpperCase() ?? 'U',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.adminPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? 'Unnamed User',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButtons(user),
        ],
      ),
    );
  }

  Widget _buildActionButtons(UserModel user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            user.isBlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
            color: user.isBlocked ? AppColors.success : AppColors.danger,
            size: 20,
          ),
          onPressed: () => _confirmBlockToggle(user.id, user.isBlocked),
          tooltip: user.isBlocked ? 'Unblock' : 'Block',
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.grey, size: 20),
          onPressed: () => _confirmDelete(user.id),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  void _confirmBlockToggle(String userId, bool currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentStatus ? 'unblock_user_q'.tr() : 'block_user_q'.tr()),
        content: Text(currentStatus ? 'unblock_confirm'.tr() : 'block_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              ref.read(adminActionsProvider.notifier).toggleUserBlock(userId, !currentStatus);
              Navigator.pop(context);
            },
            child: Text(currentStatus ? 'active'.tr() : 'blocked'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_user_q'.tr()),
        content: Text('delete_user_desc'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              ref.read(adminActionsProvider.notifier).deleteUser(userId);
              Navigator.pop(context);
            },
            child: Text('delete'.tr(), style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
