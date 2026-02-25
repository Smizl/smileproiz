import 'package:flutter_test/flutter_test.dart';
import 'package:smileproiz/models/login_response.dart';

void main() {
  group('LoginResponse model', () {
    test('should parse login response correctly', () {
      final json = {
        "success": true,
        "message": "Login successful",
        "data": {
          "token": "abc123",
          "user": {
            "id": 1,
            "email": "test@mail.com",
            "username": "testuser",
            "phone": "123456",
          },
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.success, true);
      expect(response.token, "abc123");
      expect(response.user?['email'], "test@mail.com");
      expect(response.user?['username'], "testuser");
    });
  });
}
