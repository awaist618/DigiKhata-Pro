import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../providers/admin_provider.dart';
import '../../../profile/data/models/user_model.dart';
import 'package:intl/intl.dart';

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
        title: Text('User Management', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
                hintText: 'Search users by name or email...',
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
                  return const Center(child: Text('No users found'));
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Text(user.fullName?[0].toUpperCase() ?? 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName ?? 'Unnamed User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(user.email, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Joined: ${user.createdAt != null ? DateFormat('dd MMM yyyy').format(user.createdAt!) : 'N/A'}', 
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            children: [
              Switch.adaptive(
                value: !user.isBlocked,
                activeColor: AppColors.success,
                onChanged: (val) => _confirmBlockToggle(user.id, user.isBlocked),
              ),
              Text(user.isBlocked ? 'Blocked' : 'Active', style: TextStyle(fontSize: 9, color: user.isBlocked ? AppColors.danger : AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
            onPressed: () => _confirmDelete(user.id),
          ),
        ],
      ),
    );
  }

  void _confirmBlockToggle(String userId, bool currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentStatus ? 'Unblock User?' : 'Block User?'),
        content: Text('Are you sure you want to ${currentStatus ? 'unblock' : 'block'} this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminActionsProvider.notifier).toggleUserBlock(userId, !currentStatus);
              Navigator.pop(context);
            },
            child: Text(currentStatus ? 'Unblock' : 'Block', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: const Text('This action cannot be undone. All user data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminActionsProvider.notifier).deleteUser(userId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
