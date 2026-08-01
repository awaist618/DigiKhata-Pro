import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import 'package:khataplus/features/customer/presentation/providers/customer_provider.dart';
import 'package:khataplus/features/customer/data/models/customer_model.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/business/data/models/business_model.dart';
import 'package:khataplus/features/business/data/repositories/linked_business_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class QrManagerScreen extends ConsumerStatefulWidget {
  const QrManagerScreen({super.key});

  @override
  ConsumerState<QrManagerScreen> createState() => _QrManagerScreenState();
}

class _QrManagerScreenState extends ConsumerState<QrManagerScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isProcessing = false;

  Future<void> _shareQrCode(String businessName) async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/business_qr.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(path)], text: 'Scan this QR to find $businessName on DigiKhata Pro');
    } catch (e) {
      debugPrint('Error sharing QR: $e');
    }
  }

  void _handleScannedData(String data) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      if (data.startsWith('customer:')) {
        final customerId = data.split(':').last;
        final customer = await ref.read(customerRepositoryProvider).fetchCustomerById(customerId);
        if (customer != null) {
          _showAddCustomerDialog(customer);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid QR: Customer not found')),
            );
          }
        }
      } else {
        // Assume it's a business ID
        final repository = ref.read(linkedBusinessRepositoryProvider);
        final business = await repository.fetchBusinessById(data);
        
        if (business != null) {
          _showBusinessInfo(business);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid QR: Business not found')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing QR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showAddCustomerDialog(CustomerModel customer) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Customer via QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${customer.name}'),
            const SizedBox(height: 8),
            Text('Phone: ${customer.phone}'),
            const SizedBox(height: 16),
            const Text('Do you want to add this customer to your business?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final businessId = ref.read(selectedBusinessIdProvider);
              if (businessId == null) return;
              
              // Add as a NEW customer in our business, but with same details
              final newCustomer = customer.copyWith(
                id: '', // New ID for our business
                businessId: businessId,
                balance: 0, // Fresh balance in our ledger
              );
              
              await ref.read(customerRepositoryProvider).addCustomer(newCustomer);
              ref.read(customersProvider.notifier).loadCustomers();

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer added successfully!'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showBusinessInfo(BusinessModel business) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(business.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${business.type ?? 'General'}'),
            const SizedBox(height: 8),
            Text('Contact: ${business.phone ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Text('Would you like to link this business to your workspace?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(linkedBusinessRepositoryProvider).linkBusiness(business);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Business linked successfully!'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Link Business'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessId = ref.watch(selectedBusinessIdProvider);
    final businessName = ref.watch(businessNameProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('QR Manager', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'My Business QR'),
                Tab(text: 'Scan QR'),
              ],
              labelColor: AppColors.primaryBlue,
              indicatorColor: AppColors.primaryBlue,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: My Business QR
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        RepaintBoundary(
                          key: _qrKey,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  businessName,
                                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Digital Business Identity',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 24),
                                QrImageView(
                                  data: businessId ?? 'no-business',
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  foregroundColor: AppColors.deepNavy,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.verified, color: AppColors.primaryBlue, size: 16),
                                    const SizedBox(width: 4),
                                    Text('Powered by DigiKhata Pro', style: GoogleFonts.inter(fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () => _shareQrCode(businessName),
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text('Share QR Code', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab 2: Scan QR
                  Stack(
                    children: [
                      MobileScanner(
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                            _handleScannedData(barcodes.first.rawValue!);
                          }
                        },
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue, width: 2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
