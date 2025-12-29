import 'package:shared_preferences/shared_preferences.dart';
import 'package:violet/core/utils/console.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// STORAGE SERVICE
/// Unified local storage service (combines UserInfo + UserStatus)
/// ═══════════════════════════════════════════════════════════════════════════
class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences - call this in main() before runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    Console.storage('StorageService initialized');
  }

  static SharedPreferences get _box {
    if (_prefs == null) {
      throw Exception(
        'StorageService not initialized. Call StorageService.init() first.',
      );
    }
    return _prefs!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Storage Keys
  // ─────────────────────────────────────────────────────────────────────────

  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserId = 'userId';
  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyIsFirstTimeUser = 'isFirstTimeUser';
  static const String _keyIsPremium = 'premium';
  static const String _keyFcmToken = 'fcmToken';

  // ─────────────────────────────────────────────────────────────────────────
  // User Information
  // ─────────────────────────────────────────────────────────────────────────

  /// Set user name
  static Future<void> setUserName(String name) async {
    await _box.setString(_keyUserName, name);
    Console.storage('User name saved: $name');
  }

  /// Get user name
  static String getUserName() {
    return _box.getString(_keyUserName) ?? '';
  }

  /// Set user email
  static Future<void> setUserEmail(String email) async {
    await _box.setString(_keyUserEmail, email);
  }

  /// Get user email
  static String getUserEmail() {
    return _box.getString(_keyUserEmail) ?? '';
  }

  /// Set user ID
  static Future<void> setUserId(String id) async {
    await _box.setString(_keyUserId, id);
  }

  /// Get user ID
  static String getUserId() {
    return _box.getString(_keyUserId) ?? '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Authentication Tokens
  // ─────────────────────────────────────────────────────────────────────────

  /// Set access token
  static Future<void> setAccessToken(String token) async {
    await _box.setString(_keyAccessToken, token);
    Console.storage('Access token saved');
  }

  /// Get access token
  static String getAccessToken() {
    return _box.getString(_keyAccessToken) ?? '';
  }

  /// Set refresh token
  static Future<void> setRefreshToken(String token) async {
    await _box.setString(_keyRefreshToken, token);
  }

  /// Get refresh token
  static String getRefreshToken() {
    return _box.getString(_keyRefreshToken) ?? '';
  }

  /// Check if user has valid token
  static bool hasValidToken() {
    return getAccessToken().isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // User Status
  // ─────────────────────────────────────────────────────────────────────────

  /// Set logged in status
  static Future<void> setIsLoggedIn(bool status) async {
    await _box.setBool(_keyIsLoggedIn, status);
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return _box.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Set first time user status
  static Future<void> setIsFirstTimeUser(bool status) async {
    await _box.setBool(_keyIsFirstTimeUser, status);
  }

  /// Check if first time user
  static bool isFirstTimeUser() {
    return _box.getBool(_keyIsFirstTimeUser) ?? true;
  }

  /// Set premium status
  static Future<void> setIsPremium(bool status) async {
    await _box.setBool(_keyIsPremium, status);
  }

  /// Check if user is premium
  static bool isPremium() {
    return _box.getBool(_keyIsPremium) ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Session Management
  // ─────────────────────────────────────────────────────────────────────────

  /// Save complete user session after login
  static Future<void> saveUserSession({
    required String accessToken,
    String? refreshToken,
    String? userId,
  }) async {
    await setAccessToken(accessToken);
    if (refreshToken != null) await setRefreshToken(refreshToken);
    if (userId != null) await setUserId(userId);
    await setIsLoggedIn(true);
    await setIsFirstTimeUser(false);
    Console.success('User session saved');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FCM Token
  // ─────────────────────────────────────────────────────────────────────────

  /// Set FCM token
  static Future<void> setFcmToken(String token) async {
    await _box.setString(_keyFcmToken, token);
  }

  /// Get FCM token
  static String getFcmToken() {
    return _box.getString(_keyFcmToken) ?? '';
  }

  /// Clear user session on logout
  static Future<void> clearUserSession() async {
    await _box.remove(_keyUserName);
    await _box.remove(_keyUserEmail);
    await _box.remove(_keyUserId);
    await _box.remove(_keyAccessToken);
    await _box.remove(_keyRefreshToken);
    await _box.remove(_keyIsLoggedIn);
    Console.info('User session cleared');
  }

  /// Clear all app data
  static Future<void> clearAll() async {
    await _box.clear();
    Console.warning('All storage cleared');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY SUPPORT - For backward compatibility
// ═══════════════════════════════════════════════════════════════════════════

/// @deprecated Use StorageService instead
class UserInfo {
  static Future<void> setUserName(String name) =>
      StorageService.setUserName(name);
  static String getUserName() => StorageService.getUserName();
  static Future<void> setUserEmail(String email) =>
      StorageService.setUserEmail(email);
  static String getUserEmail() => StorageService.getUserEmail();
  static Future<void> setAccessToken(String token) =>
      StorageService.setAccessToken(token);
  static String getAccessToken() => StorageService.getAccessToken();
  static Future<void> clearUserInfo() => StorageService.clearUserSession();
}

/// @deprecated Use StorageService instead
class UserStatus {
  static Future<void> setIsLoggedIn(bool status) =>
      StorageService.setIsLoggedIn(status);
  static bool getIsLoggedIn() => StorageService.isLoggedIn();
  static Future<void> setIsFirstTimeUser(bool status) =>
      StorageService.setIsFirstTimeUser(status);
  static bool getIsFirstTimeUser() => StorageService.isFirstTimeUser();
}
