class Providers {
  final String id;
  final String name;
  final String specialty;
  final String address;
  final String city;
  final String state;
  final String country;
  final String phone;
  final String email;
  final String providerCode;
  final String status;
  final bool isActive;
  final bool isDeleted;
  final bool isFeatured;
  final String rating;
  final DateTime createdAt;

  Providers({
    required this.id,
    required this.name,
    required this.specialty,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.phone,
    required this.email,
    required this.providerCode,
    required this.status,
    required this.isActive,
    required this.isDeleted,
    required this.isFeatured,
    required this.rating,
    required this.createdAt,
  });

  factory Providers.fromJson(Map<String, dynamic> json) => Providers(
    id: json['id'].toString(),
    name: json['name'] ?? '',
    specialty: json['specialty'] ?? '',
    address: json['address'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    country: json['country'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    providerCode: json['provider_code'] ?? '',
    status: json['status'] ?? '',
    isActive: json['is_active'] ?? false,
    isDeleted: json['is_deleted'] ?? false,
    isFeatured: json['is_featured'] ?? false,
    rating: json['rating'].toString(),
    createdAt: DateTime.parse(json['created_at']),
  );
}