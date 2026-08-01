class CustomerModel {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? photoUrl;
  final double balance;
  final bool isFavorite;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.notes,
    this.photoUrl,
    this.balance = 0.0,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      notes: json['notes'],
      photoUrl: json['photo_url'],
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['is_favorite'] ?? false,
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
      'is_favorite': isFavorite,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    String? photoUrl,
    double? balance,
    bool? isFavorite,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      businessId: businessId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      balance: balance ?? this.balance,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
