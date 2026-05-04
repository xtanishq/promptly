import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  String? _accessToken;
  int _credits = 0;

  String? get accessToken => _accessToken;
  int get credits => _credits;

  final String _authUrl = 'https://my-worker.scratched.workers.dev/api/auth';

  Future<void> authenticateUser() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Get or generate Device ID
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }

    // 2. Call Auth API
    try {
      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'device_id': deviceId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _credits = data['credits'] ?? 0;

        // Optionally save to prefs if you want it persistent across app restarts without re-authenticating
        if (_accessToken != null) {
          await prefs.setString('access_token', _accessToken!);
        }
        print("Authenticated successfully. Credits: $_credits");
      } else {
        print("Auth API failed with status: ${response.statusCode}");
        // Fallback to previously stored token if offline or error
        _accessToken = prefs.getString('access_token');
      }
    } catch (e) {
      print("Auth API Error: $e");
      // Fallback
      _accessToken = prefs.getString('access_token');
    }
  }
}
