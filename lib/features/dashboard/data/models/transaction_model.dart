enum TransactionType { credit, debit }

class TransactionModel {
  final String id;
  final String? customerId;
  final String? supplierId;
  final String businessId;
  final double amount;
  final String? description;
  final TransactionType type;
  final DateTime date;
  final String? imageUrl;
  final String? notes;

  TransactionModel({
    required this.id,
    this.customerId,
    this.supplierId,
    required this.businessId,
    required this.amount,
    this.description,
    required this.type,
    required this.date,
    this.imageUrl,
    this.notes,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      customerId: json['customer_id'],
      supplierId: json['supplier_id'],
      businessId: json['business_id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      type: json['type'] == 'credit' ? TransactionType.credit : TransactionType.debit,
      date: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'supplier_id': supplierId,
      'business_id': businessId,
      'amount': amount,
      'description': description,
      'type': type.name,
      'created_at': date.toIso8601String(),
      'image_url': imageUrl,
      'notes': notes,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? customerId,
    String? supplierId,
    String? businessId,
    double? amount,
    String? description,
    TransactionType? type,
    DateTime? date,
    String? imageUrl,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      businessId: businessId ?? this.businessId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }
}
