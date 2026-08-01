class SupplierModel {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? photoUrl;
  final double balance;
  final DateTime createdAt;

  SupplierModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.notes,
    this.photoUrl,
    this.balance = 0.0,
    required this.createdAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      notes: json['notes'],
      photoUrl: json['photo_url'],
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'photo_url': photoUrl,
    };
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    String? photoUrl,
    double? balance,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      businessId: businessId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      balance: balance ?? this.balance,
      createdAt: createdAt,
    );
  }
}
