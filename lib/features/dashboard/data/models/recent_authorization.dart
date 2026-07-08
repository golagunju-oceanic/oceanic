class RecentAuthorization {
  final String? id;
  final String? hospital;
  final String? status;
  final String? service;
  final DateTime? createdAt;

  RecentAuthorization({
    this.id,
    this.hospital,
    this.status,
    this.service,
    this.createdAt,
  });

  factory RecentAuthorization.fromJson(
      Map<String, dynamic> json) {
    return RecentAuthorization(
      id: json['id'],
      hospital: json['hospital'],
      status: json['status'],
      service: json['service'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}