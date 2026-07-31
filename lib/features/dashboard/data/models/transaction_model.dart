enum TransactionType { credit, debit }

class TransactionModel {
  final String id;
  final String customerId;
  final String businessId;
  final double amount;
  final String? description;
  final TransactionType type;
  final DateTime date;
  final String? imageUrl;

  TransactionModel({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.amount,
    this.description,
    required this.type,
    required this.date,
    this.imageUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      customerId: json['customer_id'],
      businessId: json['business_id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      type: json['type'] == 'credit' ? TransactionType.credit : TransactionType.debit,
      date: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'business_id': businessId,
      'amount': amount,
      'description': description,
      'type': type.name,
      'created_at': date.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
