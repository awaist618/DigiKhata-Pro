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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'user_management'.tr(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.adminGradientStart, AppColors.adminGradientEnd],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'search_users_hint'.tr(),
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.adminPrimary),
                    filled: true,
                    fillColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_rounded, size: 64, color: isDarkMode ? Colors.white12 : Colors.black12),
                          const SizedBox(height: 16),
                          Text(
                            'no_users_found'.tr(),
                            style: GoogleFonts.inter(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
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
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.adminPrimary)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: user.isBlocked ? AppColors.danger.withValues(alpha: 0.1) : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.border.withValues(alpha: 0.5)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  user.isBlocked ? AppColors.danger.withValues(alpha: 0.2) : AppColors.adminPrimary.withValues(alpha: 0.2),
                  user.isBlocked ? AppColors.danger.withValues(alpha: 0.05) : AppColors.adminPrimary.withValues(alpha: 0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                user.fullName?[0].toUpperCase() ?? 'U',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: user.isBlocked ? AppColors.danger : AppColors.adminPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName ?? 'Unnamed User',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isBlocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'BLOCKED',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
        _buildCircularAction(
          icon: user.isBlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
          color: user.isBlocked ? AppColors.success : AppColors.danger,
          onTap: () => _confirmBlockToggle(user.id, user.isBlocked),
        ),
        const SizedBox(width: 8),
        _buildCircularAction(
          icon: Icons.delete_outline_rounded,
          color: AppColors.textSecondary,
          onTap: () => _confirmDelete(user.id),
        ),
      ],
    );
  }

  Widget _buildCircularAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
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
