import 'package:oceanic/features/auth/data/models/user_models.dart';


class AuthResponseModel {
  final String token;
  final UserModel user;

  AuthResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AuthResponseModel(
      token: data['token'],
      user: UserModel.fromJson(data['user']),
    );
  }
}