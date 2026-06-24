import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

/// AuthRepository — singleton that handles device authentication.
///
/// Device ID Strategy (survives uninstall/reinstall):
/// - Android : uses ANDROID_ID (hardware-bound, stable across reinstalls,
///             resets only on factory reset)
/// - iOS     : generates a UUID once and stores it in the Keychain via
///             flutter_secure_storage (Keychain data persists across reinstalls)
class AuthRepository extends ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  String? _accessToken;
  String? _deviceId;
  int _credits = 0;
  int _overallUsedCredits = 0;

  String? get accessToken => _accessToken;
  String? get deviceId => _deviceId;
  int get credits => _credits;
  int get overallUsedCredits => _overallUsedCredits;

  static const String _authUrl =
      'http://my-worker.scratched.workers.dev/api/promptly/auth';
  static const String _addCreditsUrl =
      'http://my-worker.scratched.workers.dev/api/promptly/add-credits';

  // flutter_secure_storage: Keychain on iOS, Keystore on Android
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _deviceIdKey = 'persistent_device_id';

  // ─── Public API ───────────────────────────────────────────────

  Future<void> authenticateUser() async {
    final deviceId = await _getOrCreatePersistentDeviceId();
    _deviceId = deviceId;
    await _callAuthApi(deviceId);
  }

  /// Re-fetches the latest credits (and token) from the backend. Call after a
  /// credit-changing event (purchase / generate) so the UI reflects the
  /// authoritative server balance.
  Future<void> refreshCredits() async {
    final id = _deviceId ?? await _getOrCreatePersistentDeviceId();
    _deviceId = id;
    await _callAuthApi(id);
  }

  /// Adds [amount] credits to this device on the backend, then refreshes the
  /// local balance. Returns true on success. Used after a credit-pack purchase
  /// or a subscription bonus grant.
  Future<bool> addCredits(int amount) async {
    final id = _deviceId ?? await _getOrCreatePersistentDeviceId();
    _deviceId = id;
    try {
      final response = await http
          .post(
            Uri.parse(_addCreditsUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'device_id': id, 'credits': amount}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[AuthRepository] add-credits OK (+$amount) — refreshing');
        await refreshCredits(); // server doesn't return balance → re-fetch
        return true;
      }
      debugPrint('[AuthRepository] add-credits failed (${response.statusCode})');
      return false;
    } catch (e) {
      debugPrint('[AuthRepository] add-credits error: $e');
      return false;
    }
  }

  // ─── Device ID (persistent across reinstalls) ─────────────────

  Future<String> _getOrCreatePersistentDeviceId() async {
    // 1. Android → use ANDROID_ID (hardware-bound, no reinstall reset)
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final androidId = androidInfo.id; // stable ANDROID_ID
        if (androidId.isNotEmpty && androidId != 'unknown') {
          debugPrint('[AuthRepository] Using ANDROID_ID: $androidId');
          return androidId;
        }
      } catch (e) {
        debugPrint('[AuthRepository] Could not read ANDROID_ID: $e');
      }
    }

    // 2. iOS / fallback → Keychain-backed UUID (survives reinstalls on iOS)
    try {
      String? storedId = await _secureStorage.read(key: _deviceIdKey);
      if (storedId != null && storedId.isNotEmpty) {
        debugPrint('[AuthRepository] Using Keychain device_id: $storedId');
        return storedId;
      }

      // First time — generate and persist in Keychain
      final newId = const Uuid().v4();
      await _secureStorage.write(key: _deviceIdKey, value: newId);
      debugPrint('[AuthRepository] Generated new device_id: $newId');
      return newId;
    } catch (e) {
      debugPrint('[AuthRepository] Secure storage error: $e — using SharedPrefs fallback');
    }

    // 3. Last resort fallback (SharedPrefs — not reinstall-safe but better than nothing)
    final prefs = await SharedPreferences.getInstance();
    String? prefId = prefs.getString(_deviceIdKey);
    if (prefId != null && prefId.isNotEmpty) return prefId;

    final fallbackId = const Uuid().v4();
    await prefs.setString(_deviceIdKey, fallbackId);
    return fallbackId;
  }

  // ─── Auth API call ────────────────────────────────────────────

  Future<void> _callAuthApi(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .post(
        Uri.parse(_authUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'device_id': deviceId}),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'] as String?;
        _credits = (data['credits'] as num?)?.toInt() ?? 0;
        _overallUsedCredits = (data['overall_used_credits'] as num?)?.toInt() ?? 0;

        if (_accessToken != null) {
          await prefs.setString('access_token', _accessToken!);
        }
        notifyListeners();
        debugPrint('[AuthRepository] Authenticated. Credits: $_credits, Overall: $_overallUsedCredits');
      } else {
        debugPrint('[AuthRepository] Auth failed (${response.statusCode}) — using cached token');
        _accessToken = prefs.getString('access_token');
      }
    } catch (e) {
      debugPrint('[AuthRepository] Auth error: $e — using cached token');
      _accessToken = prefs.getString('access_token');
    }
  }
}
