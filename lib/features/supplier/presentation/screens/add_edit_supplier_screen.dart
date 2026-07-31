import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import '../providers/supplier_provider.dart';
import '../../data/models/supplier_model.dart';

class AddEditSupplierScreen extends ConsumerStatefulWidget {
  final SupplierModel? supplier;
  const AddEditSupplierScreen({super.key, this.supplier});

  @override
  ConsumerState<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends ConsumerState<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name);
    _phoneController = TextEditingController(text: widget.supplier?.phone);
    _addressController = TextEditingController(text: widget.supplier?.address);
    _notesController = TextEditingController(text: widget.supplier?.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final businessId = ref.read(selectedBusinessIdProvider);
      
      if (businessId != null) {
        if (widget.supplier == null) {
          final newSupplier = SupplierModel(
            id: '', 
            businessId: businessId,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            notes: _notesController.text.trim(),
            createdAt: DateTime.now(),
          );
          await ref.read(suppliersProvider.notifier).addSupplier(newSupplier);
        } else {
          final updatedSupplier = widget.supplier!.copyWith(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            notes: _notesController.text.trim(),
          );
          await ref.read(suppliersProvider.notifier).updateSupplier(updatedSupplier);
        }
        
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.supplier == null ? 'Add Supplier' : 'Edit Supplier',
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
                hintText: 'Supplier Name',
                prefixIcon: Icons.business_outlined,
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Address (Optional)',
                prefixIcon: Icons.location_on_outlined,
                controller: _addressController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Notes',
                prefixIcon: Icons.notes,
                controller: _notesController,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                  : PrimaryButton(
                      text: widget.supplier == null ? 'Add Supplier' : 'Save Changes',
                      onPressed: _handleSave,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
