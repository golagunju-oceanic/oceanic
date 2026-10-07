import 'authorization_item_model.dart';

class AuthorizationResponseModel {
  final int count;
  final int limit;
  final int offset;
  final List<AuthorizationItemModel> results;

  const AuthorizationResponseModel({
    required this.count,
    required this.limit,
    required this.offset,
    required this.results,
  });

  factory AuthorizationResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthorizationResponseModel(
      count: json['count'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      offset: json['offset'] as int? ?? 0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                AuthorizationItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
