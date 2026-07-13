# 🚀 Quick Start Guide - Pamodzi Tenant App

## Get the App Running in 5 Minutes

### Step 1: Verify Flutter Installation
```bash
flutter doctor
```
✅ Should show Flutter SDK, Dart, and at least one platform (Android/iOS/Windows)

### Step 2: Install Dependencies
```bash
cd pamodzi_tenant_app
flutter pub get
```
✅ **Already done!** Dependencies installed successfully.

### Step 3: Run the App
```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios

# For Windows
flutter run -d windows
```

### Step 4: Login
```
Email: chanda.m@pamodzi.com
Password: rent2026
```

---

## 🎯 Test Each Feature (5-Minute Tour)

### 1. Home Dashboard (30 seconds)
- ✅ View rent card with "Pay May Rent" button
- ✅ See quick actions (Pay Rent, Report Issue, Receipts, My Lease)
- ✅ View recent payments section
- ✅ Check maintenance preview

### 2. Pay Rent (1 minute)
1. Tap "Pay May Rent" or navigate to Pay tab
2. Select payment method:
   - Airtel Money
   - MTN Mobile Money
   - Bank Transfer
   - Deposit Slip Upload
3. Tap "Pay K 2,200 securely"
4. Wait 2 seconds for processing
5. ✅ See success screen with transaction ID

### 3. Report Maintenance Issue (1.5 minutes)
1. Tap "Issues" tab or Home → "Report Issue"
2. Select category (Plumbing, Electrical, etc.)
3. Enter title: "Kitchen tap leaking"
4. Add description (optional)
5. Select priority (Urgent, High, Medium, Low)
6. **Add photos:**
   - Tap camera icon (take photo)
   - Or tap gallery icon (select photo)
   - Add up to 5 photos
   - Remove photos by tapping X
7. Tap "Submit Report"
8. ✅ See issue in maintenance list

### 4. View Issue Details (30 seconds)
1. Go to Issues tab
2. Tap any maintenance issue
3. ✅ See full details:
   - Title, status, priority
   - Category and assignment
   - Description
   - Photos (if attached)
   - Contact landlord button

### 5. Generate & Share Receipt PDF (1 minute)
1. Go to Receipts (Home → "Receipts" or tap payment)
2. Tap any receipt
3. Tap "PDF" button (bottom right)
4. Wait for PDF generation
5. ✅ Share dialog opens
6. Choose email, WhatsApp, or save

### 6. Contact Landlord (30 seconds)
1. Go to Profile tab
2. Tap "Contact landlord" under Tenancy
3. Try each method:
   - Email (opens mail client)
   - Phone (opens dialer)
   - SMS (opens messages)
   - WhatsApp (opens WhatsApp)

### 7. Change Password (30 seconds)
1. Profile → Account → "Change password"
2. Enter current: `rent2026`
3. Enter new password (min 6 characters)
4. Confirm new password
5. Tap "Change Password"
6. ✅ Success message shown

### 8. Toggle Dark Mode (15 seconds)
1. Profile → Preferences → "Dark mode" toggle
2. ✅ Theme changes immediately
3. ✅ Close and reopen app - preference saved!

---

## 📱 Feature Test Matrix

| Feature | Screen | Action | Expected Result |
|---------|--------|--------|-----------------|
| Login | Login | Enter credentials | Navigates to Home |
| Pay Rent | Pay | Select method → Pay | Success screen |
| Upload Photo | New Issue | Camera/Gallery | Photo preview shown |
| Generate PDF | Receipt Detail | Tap PDF | PDF generated & shared |
| Share Document | Receipt Detail | Tap Share | Share dialog opens |
| Call Landlord | Contact Landlord | Tap Phone | Dialer opens |
| Email Landlord | Contact Landlord | Tap Email | Mail client opens |
| WhatsApp | Contact Landlord | Tap WhatsApp | WhatsApp opens |
| Change Password | Profile | Fill form → Submit | Success message |
| Dark Mode | Profile | Toggle switch | Theme changes |
| Notifications | Notifications tab | Tap "Mark all read" | Badge clears |
| Issue Details | Issues | Tap issue card | Detail screen |

---

## 🐛 Troubleshooting

### Issue: "Flutter not recognized"
```bash
# Add Flutter to PATH (Windows)
set PATH=%PATH%;C:\flutter\bin

# Or add to System Environment Variables
```

### Issue: "Dependencies not resolving"
```bash
flutter clean
flutter pub get
```

### Issue: "Camera permission denied"
- Android: Go to Settings → Apps → Pamodzi → Permissions → Enable Camera & Storage
- iOS: Go to Settings → Pamodzi → Enable Camera & Photos

### Issue: "PDF not generating"
- Check storage permission is granted
- Verify device has enough storage space
- Try generating again

### Issue: "Email/Phone/WhatsApp not opening"
- Verify you have the respective app installed
- Grant URL launching permissions if prompted

### Issue: "Photos not uploading"
```bash
# Ensure permissions are in AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

---

## 🔍 Verify Installation

### Check All Features Work
```bash
# Run this checklist:
✅ App launches
✅ Can login
✅ Home screen loads
✅ Can navigate between tabs
✅ Can upload photo
✅ Can generate PDF
✅ Can share document
✅ Can contact landlord
✅ Can change password
✅ Can toggle dark mode
✅ Preferences persist on restart
```

---

## 📚 Next Steps

1. **Read Documentation:**
   - `README.md` - Full project overview
   - `IMPLEMENTATION_GUIDE.md` - Developer guide
   - `COMPLETION_SUMMARY.md` - Feature completion status

2. **Explore Code:**
   - `lib/services/` - Business logic
   - `lib/screens/` - UI screens
   - `lib/data/app_state.dart` - State management

3. **Customize:**
   - Update branding in `app_theme.dart`
   - Add your logo
   - Configure actual API endpoints

4. **Deploy:**
   - Set up backend API
   - Configure payment gateway
   - Add cloud storage
   - Submit to app stores

---

## 💡 Pro Tips

### For Developers
- Use `flutter run -d <device-id>` to target specific device
- Hot reload with `r` in terminal while app is running
- Hot restart with `R` for state reset
- Use `flutter logs` to see real-time logs
- Use `flutter doctor -v` for detailed environment info

### For Testers
- Test on physical device (some features don't work in emulator)
- Try both light and dark modes
- Test all permission flows
- Try with/without internet connection
- Test with different file types for photos

### For Designers
- All colors defined in `lib/theme/app_theme.dart`
- UI follows Material Design 3
- Components in `lib/widgets/shared_widgets.dart`
- Spacing is consistent (8px grid system)

---

## 🎉 You're All Set!

The app is now running with all features functional. 

### Quick Access to Demo Credentials
```
Email: chanda.m@pamodzi.com
Password: rent2026
```

### Need Help?
- Check `IMPLEMENTATION_GUIDE.md` for detailed feature info
- Review code comments in service files
- Open an issue on GitHub
- Email support@pamodzi.zm

---

**Happy Testing! 🚀**
