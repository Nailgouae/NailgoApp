import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordApi {
  static const String _base = 'http://nailgo.ae/api/v2/password';

  /// POST /password/forget_request
  static Future<void> sendResetRequest(String email) async {
    final res = await http.post(
      Uri.parse('$_base/forget_request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    _throwIfNot200(res);
  }

  /// POST /password/verify_otp
  static Future<void> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse('$_base/verify_otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    _throwIfNot200(res);
  }

  /// POST /password/reset_password
  static Future<void> resetPassword(String email, String newPass) async {
    final res = await http.post(
      Uri.parse('$_base/reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': newPass}),
    );
    _throwIfNot200(res);
  }

  static void _throwIfNot200(http.Response r) {
    if (r.statusCode != 200) {
      throw Exception('Server responded ${r.statusCode}: ${r.body}');
    }
  }
}
