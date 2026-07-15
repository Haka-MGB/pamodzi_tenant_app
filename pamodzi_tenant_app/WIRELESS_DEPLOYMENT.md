# 📱 Wireless Deployment Guide

## Method 1: ADB Wireless (Android 11+)

### Step 1: Enable Wireless Debugging on Phone
1. Go to **Settings** > **Developer Options**
2. Enable **Wireless Debugging**
3. Tap **Wireless Debugging** to see the pairing screen
4. Tap **Pair device with pairing code**
5. Note the **IP address, port, and pairing code** (e.g., 192.168.1.5:37831)

### Step 2: Pair from PC
```cmd
adb pair <IP>:<PORT>
```
Example:
```cmd
adb pair 192.168.1.5:37831
```
Enter the 6-digit pairing code when prompted.

### Step 3: Connect
```cmd
adb connect <IP>:<WIRELESS_PORT>
```
The wireless port is shown in the Wireless Debugging screen (usually 5555).
Example:
```cmd
adb connect 192.168.1.5:5555
```

### Step 4: Verify Connection
```cmd
adb devices
```
You should see your device listed.

### Step 5: Run Flutter App
```cmd
cd c:\Users\hakam\Desktop\pamodzi_tenant_app\pamodzi_tenant_app
flutter run
```

---

## Method 2: ADB TCP/IP (Android 10 and below)

### Requirements
- USB cable for initial setup (can disconnect after)

### Steps
1. **Connect phone via USB** (one time only)
```cmd
adb devices
```

2. **Enable TCP/IP mode**
```cmd
adb tcpip 5555
```

3. **Find phone's IP address**
   - Go to **Settings** > **About Phone** > **Status** > **IP Address**
   - Or Settings > **WiFi** > Tap your network > Check IP

4. **Disconnect USB cable**

5. **Connect wirelessly**
```cmd
adb connect <PHONE_IP>:5555
```
Example:
```cmd
adb connect 192.168.1.100:5555
```

6. **Verify**
```cmd
adb devices
```

7. **Run app**
```cmd
cd c:\Users\hakam\Desktop\pamodzi_tenant_app\pamodzi_tenant_app
flutter run
```

---

## Method 3: Build APK and Install

### Step 1: Build APK
```cmd
cd c:\Users\hakam\Desktop\pamodzi_tenant_app\pamodzi_tenant_app
flutter build apk --release
```

### Step 2: Locate APK
The APK will be at:
```
build\app\outputs\flutter-apk\app-release.apk
```

### Step 3: Transfer to Phone
- **Email:** Email the APK to yourself
- **Cloud:** Upload to Google Drive/Dropbox
- **Direct:** Use file sharing apps (ShareIt, Xender)
- **HTTP Server:** Share via local network

### Step 4: Install on Phone
1. Open the APK file on your phone
2. Allow "Install from Unknown Sources" if prompted
3. Tap **Install**

---

## Method 4: Flutter Web Server (Quick Test)

### Start Local Server
```cmd
cd c:\Users\hakam\Desktop\pamodzi_tenant_app\pamodzi_tenant_app
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
```

### Access from Phone
1. Find your PC's IP address:
```cmd
ipconfig
```
Look for "IPv4 Address" (e.g., 192.168.1.50)

2. Open browser on phone:
```
http://<PC_IP>:8080
```
Example: `http://192.168.1.50:8080`

**Note:** Some features may not work in web mode (camera, certain permissions).

---

## Troubleshooting

### "No devices found"
```cmd
adb kill-server
adb start-server
adb connect <IP>:5555
```

### Connection keeps dropping
- Ensure phone doesn't go to sleep
- Keep WiFi on
- Disable battery optimization for ADB

### Firewall blocking connection
- Allow ADB through Windows Firewall
- Port 5555 must be open

### Check if ADB is installed
```cmd
adb version
```
If not found, ensure Flutter SDK is in PATH or use full path:
```cmd
flutter pub global run adb devices
```

---

## Quick Commands Reference

```cmd
# Check connected devices
adb devices

# Connect wirelessly
adb connect <IP>:5555

# Disconnect
adb disconnect

# Run Flutter app
flutter run

# Hot reload (while app is running)
Press 'r' in terminal

# Hot restart
Press 'R' in terminal

# Build APK
flutter build apk --release
```

---

## Best Practice

1. **First time:** Use ADB wireless pairing
2. **Subsequent runs:** Just `flutter run` (stays connected)
3. **Production testing:** Build and install APK
4. **Quick iterations:** Use wireless ADB with hot reload

---

**Tip:** Once connected via ADB wireless, the connection persists until phone restarts. You can run `flutter run` anytime without reconnecting!
