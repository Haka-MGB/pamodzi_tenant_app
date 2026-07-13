# 🏠 Pamodzi Tenant App

A modern, feature-rich tenant management mobile application for property management in Zambia. Built with Flutter for cross-platform support (Android, iOS, Windows).

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Windows-lightgrey)

## 📱 Features

### ✅ Fully Implemented

#### **Payment Management**
- 💳 Multiple payment methods (Airtel Money, MTN MoMo, Bank Transfer)
- 📱 Mobile money integration ready
- 💰 Payment history tracking
- 📄 Digital receipt generation
- 🔗 Payment verification system

#### **Maintenance Requests**
- 🔧 Report issues with categories
- 📸 Photo uploads (up to 5 images)
- 📊 Priority levels (Urgent, High, Medium, Low)
- 👷 Assignment tracking
- 📈 Status monitoring (Open, In Progress, Resolved)
- 🔍 Detailed issue view

#### **Document Management**
- 📑 PDF receipt generation
- 📋 Lease agreement PDFs
- 📤 Share documents via email, WhatsApp, etc.
- ⬇️ Download documents to device

#### **Communication**
- 📧 Email landlord directly
- 📞 Call landlord
- 💬 SMS messaging
- 💚 WhatsApp integration
- 📝 Message templates

#### **Account Management**
- 🔐 Secure login system
- 🔑 Change password functionality
- 👤 Profile management
- 🌓 Dark mode support
- 💾 Preference persistence

#### **Notifications**
- 🔔 In-app notifications
- 🔵 Unread badge system
- ✅ Mark all as read
- 📬 Multiple notification types

### 📊 App Screens (11 Total)

1. **Login Screen** - Authentication
2. **Home Screen** - Dashboard with rent summary
3. **Pay Screen** - Payment processing
4. **Maintenance List** - All maintenance issues
5. **Maintenance Detail** - Full issue information
6. **Notifications** - App alerts
7. **Profile** - User settings
8. **Receipts** - Payment receipts list
9. **Receipt Detail** - Individual receipt view
10. **Lease Screen** - Lease agreement details
11. **Payment History** - Full payment timeline
12. **Change Password** - Security settings
13. **Contact Landlord** - Multi-channel communication

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Android Studio / Xcode / Visual Studio (depending on target platform)
- Device or emulator running Android 5.0+ / iOS 12.0+ / Windows 10+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pamodzi_tenant_app.git
   cd pamodzi_tenant_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Android
   flutter run

   # iOS
   flutter run -d ios

   # Windows
   flutter run -d windows
   ```

### Demo Credentials

```
Email: chanda.m@pamodzi.com
Password: rent2026
```

---

## 🏗️ Project Structure

```
lib/
├── data/
│   └── app_state.dart              # Global state management
├── models/
│   └── models.dart                  # Data models
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── pay_screen.dart
│   ├── maintenance_screen.dart
│   ├── maintenance_detail_screen.dart
│   ├── receipts_screen.dart
│   ├── secondary_screens.dart       # Profile, Notifications, Lease, etc.
│   ├── change_password_screen.dart
│   └── contact_landlord_screen.dart
├── services/
│   ├── auth_service.dart            # Authentication
│   ├── payment_service.dart         # Payment processing
│   ├── pdf_service.dart             # PDF generation
│   ├── image_service.dart           # Photo uploads
│   └── communication_service.dart   # Email, SMS, calls
├── theme/
│   └── app_theme.dart               # Theme configuration
├── widgets/
│   └── shared_widgets.dart          # Reusable components
└── main.dart                        # App entry point
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1                   # State management
  google_fonts: ^6.1.0               # Typography
  intl: ^0.19.0                      # Internationalization
  shared_preferences: ^2.2.2         # Local storage
  fluttertoast: ^8.2.4               # Toast messages
  url_launcher: ^6.2.4               # Open URLs, emails, phone
  image_picker: ^1.0.7               # Photo uploads
  pdf: ^3.10.8                       # PDF generation
  path_provider: ^2.1.2              # File system access
  share_plus: ^7.2.2                 # Share functionality
  http: ^1.2.0                       # HTTP requests
  permission_handler: ^11.2.0        # Permissions
```

---

## ⚙️ Configuration

### Android Setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CALL_PHONE" />

<!-- Queries for URL launcher -->
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="mailto" />
    </intent>
    <intent>
        <action android:name="android.intent.action.DIAL" />
        <data android:scheme="tel" />
    </intent>
    <!-- Add more as needed -->
</queries>
```

### iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture photos of maintenance issues</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>mailto</string>
    <string>tel</string>
    <string>sms</string>
    <string>whatsapp</string>
</array>
```

---

## 🎨 Design

### Color Scheme
- **Primary Green:** `#1A4D2E` - Trust and growth
- **Accent Green:** `#4ADE80` - Action and success
- **Background:** Light `#F5F5F5` / Dark `#0A0F0D`
- **Surface:** Light `#FFFFFF` / Dark `#111716`

### Typography
- **Font Family:** Inter (via Google Fonts)
- **Weights:** 400 (regular), 500 (medium), 600 (semibold), 700 (bold), 800 (extra bold)

---

## 🧪 Testing

### Manual Testing Checklist

- [x] Login with valid credentials
- [x] Login with invalid credentials (error handling)
- [x] Navigate between all screens
- [x] Toggle dark mode
- [x] Submit maintenance issue with photos
- [x] Process payment (all methods)
- [x] Generate and download receipt PDF
- [x] Generate and download lease PDF
- [x] Share documents
- [x] Contact landlord (all methods)
- [x] Change password
- [x] Mark notifications as read
- [x] Logout and login again

### Run Tests
```bash
flutter test
```

---

## 🔐 Security

### Current Implementation
- Session token storage in SharedPreferences
- Password validation (minimum 6 characters)
- Secure password input fields (obscured text)
- Demo mode with hardcoded credentials

### Production Recommendations
- Use `flutter_secure_storage` for sensitive data
- Implement SSL certificate pinning
- Add JWT token refresh mechanism
- Enable biometric authentication
- Implement rate limiting on API calls
- Add multi-factor authentication (MFA)

---

## 🌍 Localization

Currently supports:
- 🇬🇧 English (default)

### Adding New Languages

1. Add dependency:
   ```yaml
   flutter_localizations:
     sdk: flutter
   ```

2. Create ARB files in `l10n/`:
   ```
   l10n/
   ├── app_en.arb    # English
   ├── app_bem.arb   # Bemba
   └── app_ny.arb    # Nyanja
   ```

3. Generate localizations:
   ```bash
   flutter gen-l10n
   ```

---

## 📊 State Management

Uses **Provider** pattern for simplicity and maintainability.

### AppState Structure
```dart
class AppState extends ChangeNotifier {
  // Authentication
  bool isLoggedIn;
  
  // Theme
  bool isDarkMode;
  
  // Data
  List<Payment> payments;
  List<MaintenanceIssue> issues;
  List<AppNotification> notifications;
  
  // Settings
  String selectedLanguage;
  bool notificationsEnabled;
}
```

---

## 🚧 Known Limitations

1. **No Backend Integration:** Currently uses mock data and simulated API calls
2. **No Push Notifications:** Would require Firebase Cloud Messaging
3. **No Real Payment Gateway:** Simulated transactions only
4. **No Cloud Storage:** Photos stored locally only
5. **Single Tenant:** No multi-tenant support
6. **No Offline Sync:** Requires internet connection (when backend is added)

---

## 🗺️ Roadmap

### Phase 1 (Current) ✅
- [x] Core UI/UX implementation
- [x] Payment flow (mock)
- [x] Maintenance reporting
- [x] PDF generation
- [x] Photo uploads
- [x] Contact features

### Phase 2 (Next)
- [ ] Backend API integration
- [ ] Real payment gateway
- [ ] Push notifications
- [ ] Cloud photo storage
- [ ] Biometric login

### Phase 3 (Future)
- [ ] Multi-language support
- [ ] Rent reminders
- [ ] Lease renewal workflow
- [ ] In-app chat
- [ ] Analytics dashboard

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Your Name** - Initial work

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- [Google Fonts](https://fonts.google.com/) for the Inter font family
- [Heroicons](https://heroicons.com/) for icon inspiration
- Property management stakeholders in Zambia for requirements

---

## 📞 Support

For support, email support@pamodzi.zm or open an issue on GitHub.

---

## 📸 Screenshots

_Add screenshots here when available_

---

**Made with ❤️ for tenants in Zambia**
