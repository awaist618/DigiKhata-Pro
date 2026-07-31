import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/features/profile/presentation/providers/profile_provider.dart';

import 'package:khataplus/core/providers/settings_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    _nameController = TextEditingController(text: profile?.fullName);
    _phoneController = TextEditingController(text: profile?.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final currentProfile = ref.read(profileProvider).value;
      if (currentProfile != null) {
        final updatedUser = currentProfile.copyWith(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );
        
        await ref.read(profileProvider.notifier).updateProfile(updatedUser);
        
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.deepNavy : AppColors.background,
      appBar: AppBar(
        title: Text(
          'edit_profile'.tr(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                hintText: 'full_name'.tr(),
                prefixIcon: Icons.person_outline,
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'phone_number'.tr(),
                prefixIcon: Icons.phone_outlined,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Field required';
                  if (!RegExp(r'^\+?[0-9]{10,12}$').hasMatch(val)) return 'Invalid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                  : PrimaryButton(
                      text: 'save_changes'.tr(),
                      onPressed: _handleSave,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
