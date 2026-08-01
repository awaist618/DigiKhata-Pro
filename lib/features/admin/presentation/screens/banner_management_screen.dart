import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khataplus/core/services/supabase_service.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class BannerManagementScreen extends ConsumerStatefulWidget {
  const BannerManagementScreen({super.key});

  @override
  ConsumerState<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends ConsumerState<BannerManagementScreen> {
  final _titleController = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;
  bool _isPicking = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) setState(() => _selectedImage = image);
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _handleAddBanner() async {
    final title = _titleController.text.trim();

    if (title.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title and select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      
      // 1. Upload to Storage
      final file = File(_selectedImage!.path);
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'marketing/$fileName';
      
      await supabase.storage.from('banners').upload(path, file);
      final imageUrl = supabase.storage.from('banners').getPublicUrl(path);

      // 2. Save to DB
      await ref.read(adminRepositoryProvider).addBanner(title, imageUrl, null);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner published successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddDialog(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.adminSurface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'add_new_banner'.tr(), 
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: isDarkMode ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              _buildInputField('Banner Title', Icons.title_rounded, _titleController, isDarkMode),
              const SizedBox(height: 16),
              
              // Image Picker UI
              InkWell(
                onTap: () async {
                  await _pickImage();
                  setModalState(() {});
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.backgroundDark : AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkMode ? Colors.white10 : AppColors.border),
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_rounded, color: AppColors.adminPrimary, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to Select Image', 
                              style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.adminPrimary))
                : ElevatedButton(
                    onPressed: _handleAddBanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adminPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Text('Add Slider Banner', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon, TextEditingController controller, bool isDarkMode) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.adminPrimary, size: 20),
        filled: true,
        fillColor: isDarkMode ? AppColors.backgroundDark : AppColors.inputBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                'marketing_banners'.tr(),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.adminPrimary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.view_carousel_rounded, size: 80, color: AppColors.adminPrimary.withValues(alpha: 0.2)),
              ),
              const SizedBox(height: 24),
              Text(
                'banner_system'.tr(), 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800, 
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'add_banner_desc'.tr(),
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(isDarkMode),
                icon: const Icon(Icons.add_rounded),
                label: Text('add_new_banner'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 40),
              _buildExistingBanners(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingBanners(bool isDarkMode) {
    final bannersAsync = ref.watch(bannersProvider);

    return bannersAsync.when(
      data: (banners) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Active Banners',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          if (banners.isEmpty)
            Center(child: Text('No active banners', style: TextStyle(color: AppColors.textSecondary)))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        banner['image_url'],
                        width: 80,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 50, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 20)),
                      ),
                    ),
                    title: Text(
                      banner['title'] ?? 'Untitled',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : AppColors.textPrimary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      onPressed: () => _confirmDelete(banner['id']),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 100),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  void _confirmDelete(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        title: const Text('Remove Banner?'),
        content: const Text('This banner will no longer be visible to users.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          TextButton(
            onPressed: () async {
              await ref.read(adminRepositoryProvider).deleteBanner(id);
              ref.invalidate(bannersProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('delete'.tr(), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
