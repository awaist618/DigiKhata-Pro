class BusinessModel {
  final String id;
  final String ownerId;
  final String name;
  final String? type;
  final String? phone;
  final String? address;
  final String currency;
  final DateTime createdAt;

  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.type,
    this.phone,
    this.address,
    this.currency = 'PKR',
    required this.createdAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      type: json['type'],
      phone: json['phone'],
      address: json['address'],
      currency: json['currency'] ?? 'PKR',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'type': type,
      'phone': phone,
      'address': address,
      'currency': currency,
    };
  }

  BusinessModel copyWith({
    String? name,
    String? type,
    String? phone,
    String? address,
    String? currency,
  }) {
    return BusinessModel(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      currency: currency ?? this.currency,
      createdAt: createdAt,
    );
  }
}
