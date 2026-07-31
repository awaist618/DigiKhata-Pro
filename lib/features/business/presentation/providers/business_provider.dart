import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mocking business ID for now as selection is not fully persistent yet
final selectedBusinessIdProvider = StateProvider<String?>((ref) => 'mock-business-id-123');

final businessNameProvider = StateProvider<String>((ref) => 'Zenvyro Labs');
