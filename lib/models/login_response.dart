class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = (data is Map) ? Map<String, dynamic>.from(data) : null;

    return LoginResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      token: dataMap?['token']?.toString(),
      user: (dataMap?['user'] is Map)
          ? Map<String, dynamic>.from(dataMap!['user'])
          : null,
    );
  }
}
