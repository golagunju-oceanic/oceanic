class ApiResponse<T> {
  final bool success;

  final String? message;

  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? parser,
  ) {
    return ApiResponse(
      success: json["success"],
      message: json["message"],
      data: parser == null
          ? null
          : parser(json["data"]),
    );
  }
}