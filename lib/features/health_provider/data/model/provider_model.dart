class ProviderModel {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? city;
  final String? state;
  final String? category;

  const ProviderModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.city,
    this.state,
    this.category,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      name: json["name"] ?? "",
      address: json["address"],
      phone: json["phone"],
      email: json["email"],
      city: json["city"],
      state: json["state"],
      category: json["category"],
    );
  }
}
