import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String _selectedPaymentMethod = 'airtel';
  String get selectedPaymentMethod => _selectedPaymentMethod;

  String? _selectedPriority;
  String? get selectedPriority => _selectedPriority;

  int _notifBadge = 2;
  int get notifBadge => _notifBadge;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  String _selectedLanguage = 'English';
  String get selectedLanguage => _selectedLanguage;

  // Language options
  final Map<String, String> languages = {
    'English': 'English',
    'Bemba': 'Bemba',
    'Nyanja': 'Nyanja',
  };

  // Notification settings
  Map<String, bool> _notificationSettings = {
    'push': true,
    'sms': true,
    'email': true,
    'rent_reminders': true,
    'maintenance_updates': true,
    'payment_confirmations': true,
  };
  Map<String, bool> get notificationSettings => _notificationSettings;

  final Tenant tenant = const Tenant(
    name: 'Chanda Mulenga',
    email: 'chanda.m@pamodzi.com',
    phone: '+260 977 123 456',
    unit: 'A3',
    estate: 'Parklands Estate',
    city: 'Lusaka',
    initials: 'CM',
  );

  final Lease lease = const Lease(
    tenantName: 'Chanda Mulenga',
    property: 'A3 · Parklands Estate',
    landlord: 'James Mwale',
    landlordEmail: 'james@pamodzi.zm',
    startDate: '1 January 2026',
    endDate: '31 December 2026',
    monthlyRent: 2200,
    dueDate: '1st of each month',
    lateFee: 220,
    lateDays: 5,
    deposit: 4400,
  );

  final double rentAmount = 2200.00;
  final String rentPeriod = 'May 2026';
  final String rentRef = 'CM-PRKL-MAY26';
  final String rentStatus = 'pending';

  List<Payment> payments = [
    const Payment(month: 'April 2026', amount: 2200, method: 'Airtel Money', ref: 'CM-PRKL-APR26', date: '3 Apr 2026', status: 'paid'),
    const Payment(month: 'March 2026', amount: 2200, method: 'Airtel Money', ref: 'CM-PRKL-MAR26', date: '1 Mar 2026', status: 'paid'),
    const Payment(month: 'February 2026', amount: 2200, method: 'MTN MoMo', ref: 'CM-PRKL-FEB26', date: '2 Feb 2026', status: 'paid'),
    const Payment(month: 'January 2026', amount: 2200, method: 'Bank Transfer', ref: 'CM-PRKL-JAN26', date: '5 Jan 2026', status: 'paid'),
  ];

  List<MaintenanceIssue> issues = [
    const MaintenanceIssue(title: 'Kitchen tap leaking at base', category: 'Plumbing', status: 'progress', priority: 'high', date: '2 days ago', assignee: 'John Soko', iconType: 'plumbing'),
    const MaintenanceIssue(title: 'Circuit breaker trips frequently', category: 'Electrical', status: 'open', priority: 'urgent', date: '1 week ago', assignee: 'Awaiting assignment', iconType: 'electrical'),
    const MaintenanceIssue(title: 'Broken gate lock', category: 'Security', status: 'resolved', priority: 'low', date: '2 weeks ago', assignee: 'John Soko', iconType: 'security'),
  ];

  List<AppNotification> notifications = [
    AppNotification(type: 'green', iconType: 'check', title: 'Payment confirmed', body: 'Your April 2026 rent of K2,200 has been confirmed by James Mwale.', time: '2 hours ago', unread: true),
    AppNotification(type: 'amber', iconType: 'tools', title: 'Maintenance update', body: 'Your kitchen tap issue has been assigned to John Soko — in progress.', time: 'Yesterday', unread: true),
    AppNotification(type: 'blue', iconType: 'document', title: 'Lease reminder', body: 'Your lease expires in December 2026. Renewal discussions can begin now.', time: '3 days ago', unread: false),
    AppNotification(type: 'green', iconType: 'bell', title: 'Rent reminder', body: 'May 2026 rent of K2,200 is due on 1 May 2026. Pay early to avoid late fees.', time: '5 days ago', unread: false),
  ];

  // Initialize app state from shared preferences
  AppState() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      
      // Load notification settings
      _notificationSettings = {
        'push': prefs.getBool('notif_push') ?? true,
        'sms': prefs.getBool('notif_sms') ?? true,
        'email': prefs.getBool('notif_email') ?? true,
        'rent_reminders': prefs.getBool('notif_rent_reminders') ?? true,
        'maintenance_updates': prefs.getBool('notif_maintenance_updates') ?? true,
        'payment_confirmations': prefs.getBool('notif_payment_confirmations') ?? true,
      };
      
      notifyListeners();
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      }
    } catch (e) {
      print('Error saving preference: $e');
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _savePreference('dark_mode', _isDarkMode);
    notifyListeners();
  }

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setPriority(String? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void addIssue(MaintenanceIssue issue) {
    issues.insert(0, issue);
    // Add notification for new issue
    _addNotification(AppNotification(
      type: 'amber',
      iconType: 'tools',
      title: 'Issue reported',
      body: '${issue.title} has been submitted to your landlord.',
      time: 'Just now',
      unread: true,
    ));
    notifyListeners();
  }

  void markAllNotifsRead() {
    for (final n in notifications) {
      n.unread = false;
    }
    _notifBadge = 0;
    notifyListeners();
  }

  void _addNotification(AppNotification notification) {
    notifications.insert(0, notification);
    if (notification.unread) {
      _notifBadge++;
    }
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _savePreference('notifications_enabled', _notificationsEnabled);
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    _savePreference('language', language);
    notifyListeners();
  }

  void updateNotificationSettings(String key, bool value) {
    _notificationSettings[key] = value;
    _savePreference('notif_$key', value);
    notifyListeners();
  }

  String getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 18) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  // Add payment to history
  void addPayment(Payment payment) {
    payments.insert(0, payment);
    _addNotification(AppNotification(
      type: 'green',
      iconType: 'check',
      title: 'Payment submitted',
      body: 'Your ${payment.month} rent payment of K${payment.amount.toStringAsFixed(0)} has been submitted.',
      time: 'Just now',
      unread: true,
    ));
    notifyListeners();
  }
}
