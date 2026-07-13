import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle local data persistence
class StorageService {
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _languageKey = 'language';
  static const String _paymentsKey = 'payments';
  static const String _issuesKey = 'maintenance_issues';
  static const String _notificationsKey = 'notifications';

  /// Save dark mode preference
  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }

  /// Get dark mode preference
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  /// Save notification settings
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationSettingsKey, jsonEncode(settings));
  }

  /// Get notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsStr = prefs.getString(_notificationSettingsKey);
    if (settingsStr != null) {
      final decoded = jsonDecode(settingsStr) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }
    // Default settings
    return {
      'push': true,
      'sms': true,
      'email': true,
      'rent_reminders': true,
      'maintenance_updates': true,
      'payment_confirmations': true,
    };
  }

  /// Save language preference
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Get language preference
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  /// Save payments data
  Future<void> savePayments(List<Map<String, dynamic>> payments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paymentsKey, jsonEncode(payments));
  }

  /// Get payments data
  Future<List<Map<String, dynamic>>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentsStr = prefs.getString(_paymentsKey);
    if (paymentsStr != null) {
      final decoded = jsonDecode(paymentsStr) as List;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Save maintenance issues
  Future<void> saveIssues(List<Map<String, dynamic>> issues) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_issuesKey, jsonEncode(issues));
  }

  /// Get maintenance issues
  Future<List<Map<String, dynamic>>> getIssues() async {
    final prefs = await SharedPreferences.getInstance();
    final issuesStr = prefs.getString(_issuesKey);
    if (issuesStr != null) {
      final decoded = jsonDecode(issuesStr) as List;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Save notifications
  Future<void> saveNotifications(List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  /// Get notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifsStr = prefs.getString(_notificationsKey);
    if (notifsStr != null) {
      final decoded = jsonDecode(notifsStr) as List;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
