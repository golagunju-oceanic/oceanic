import 'dart:convert';
import 'package:oceanic/core/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:oceanic/data/models/user_model.dart';

class AuthService {
  Future<UserModel> getProfile(String token) async {
    final res = await http.get(
      Uri.parse('${Constants.uri}/api/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(body['message']);
    }

    return UserModel.fromMap(body);
  }

  Future<void> signUp({
    required String memberId,
    required String password,
    required String confirmPassword,
    required String username,
  }) async {
    final res = await http.post(
      Uri.parse('${Constants.uri}/api/auth/register'),
      body: jsonEncode({
        'memberId': memberId,
        'password': password,
        'confirmPassword': confirmPassword,
        'username': username,
      }),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 201) {
      throw Exception(body['message']);
    }
  }

  Future<String> login({
    required String memberId,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${Constants.uri}/api/auth/login'),
      body: jsonEncode({'memberId': memberId, 'password': password}),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(body['message']);
    }
    if (body['token'] == null) {
      throw Exception('Token not returned from server');
    }

    return body['token'] as String;
  }
}
