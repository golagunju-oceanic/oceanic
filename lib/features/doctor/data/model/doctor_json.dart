import 'dart:convert';

/// Read the Express envelope { "data": ... } without swallowing unexpected API responses.
dynamic unwrapDoctorData(dynamic responseBody) {
  final dynamic decoded = responseBody is String
      ? jsonDecode(responseBody)
      : responseBody;
  final json = doctorJsonMap(decoded, context: 'API response');
  if (!json.containsKey('data')) {
    throw const FormatException('Expected a response containing a "data" field');
  }
  return json['data'];
}

Map<String, dynamic> doctorJsonMap(dynamic value, {String context = 'JSON'}) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Expected an object for $context');
}

List<Map<String, dynamic>> doctorJsonList(dynamic value, {String context = 'list'}) {
  if (value is! List) throw FormatException('Expected an array for $context');
  return value.map((item) => doctorJsonMap(item, context: context)).toList();
}

String requireDoctorString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null || value.toString().trim().isEmpty) {
    throw FormatException('Missing required field: $key');
  }
  return value.toString();
}

String? doctorString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  return value.toString();
}

String doctorStringOrEmpty(Map<String, dynamic> json, String key) =>
    doctorString(json, key) ?? '';

int doctorInt(Map<String, dynamic> json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

int? doctorNullableInt(Map<String, dynamic> json, String key) {
  if (json[key] == null) return null;
  return doctorInt(json, key);
}

bool doctorBool(Map<String, dynamic> json, String key, {bool fallback = false}) {
  final value = json[key];
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return fallback;
}

DateTime? doctorDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

DateTime requireDoctorDate(Map<String, dynamic> json, String key) {
  final value = doctorDate(json, key);
  if (value == null) throw FormatException('Missing/invalid datetime: $key');
  return value;
}
