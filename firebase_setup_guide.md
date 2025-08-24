# 🔥 Firebase Setup Guide untuk LockIn App

## Langkah-langkah Setup Firebase

### 1. Buat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Create a project" atau "Add project"
3. Masukkan nama project: `lockin-app` (atau nama yang Anda inginkan)
4. Pilih "Enable Google Analytics" (opsional)
5. Klik "Create project"

### 2. Tambahkan Android App

1. Di Firebase Console, klik ikon Android
2. Masukkan Android package name: `com.example.lockin_app`
3. Masukkan app nickname: `LockIn App`
4. Klik "Register app"
5. Download file `google-services.json`
6. Letakkan file tersebut di folder `android/app/`

### 3. Tambahkan iOS App (jika diperlukan)

1. Di Firebase Console, klik ikon iOS
2. Masukkan iOS bundle ID: `com.example.lockinApp`
3. Masukkan app nickname: `LockIn App`
4. Klik "Register app"
5. Download file `GoogleService-Info.plist`
6. Letakkan file tersebut di folder `ios/Runner/`

### 4. Enable Authentication

1. Di Firebase Console, pilih "Authentication"
2. Klik "Get started"
3. Pilih tab "Sign-in method"
4. Enable "Email/Password"
5. Klik "Save"

### 5. Setup Firestore Database

1. Di Firebase Console, pilih "Firestore Database"
2. Klik "Create database"
3. Pilih "Start in test mode" (untuk development)
4. Pilih lokasi database (pilih yang terdekat)
5. Klik "Done"

### 6. Update Android Configuration

#### android/app/build.gradle
```gradle
android {
    defaultConfig {
        applicationId "com.example.lockin_app"
        minSdkVersion 21  // Update ini
        targetSdkVersion 33
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

#### android/build.gradle
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### android/app/build.gradle (tambahkan di akhir file)
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 7. Update iOS Configuration (jika diperlukan)

#### ios/Runner/Info.plist
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>REVERSED_CLIENT_ID_FROM_GOOGLESERVICE_INFO_PLIST</string>
        </array>
    </dict>
</array>
```

### 8. Install Dependencies

Jalankan command berikut:
```bash
flutter pub get
```

### 9. Test Firebase Connection

Setelah setup selesai, jalankan aplikasi:
```bash
flutter run
```

## 🔧 Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
- Pastikan `google-services.json` sudah ada di `android/app/`
- Pastikan `GoogleService-Info.plist` sudah ada di `ios/Runner/` (untuk iOS)
- Restart aplikasi

### Error: "Firebase Auth not initialized"
- Pastikan Firebase sudah di-initialize di `main.dart`
- Pastikan dependencies sudah terinstall dengan benar

### Error: "Permission denied" di Firestore
- Pastikan Firestore rules sudah dikonfigurasi dengan benar
- Untuk development, gunakan rules berikut:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📊 Firebase Features yang Digunakan

1. **Firebase Authentication**
   - Email/Password signup dan login
   - User session management
   - Secure password handling

2. **Cloud Firestore**
   - User data storage
   - Real-time database
   - Automatic scaling

3. **Firebase Analytics** (opsional)
   - User behavior tracking
   - App performance monitoring

## 🔒 Security Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 💰 Pricing

Firebase memiliki **free tier** yang cukup generus:
- **Authentication**: 10,000 users/month
- **Firestore**: 1GB storage, 50,000 reads/day, 20,000 writes/day
- **Hosting**: 10GB storage, 360MB/day transfer

Untuk aplikasi development dan small scale, free tier sudah cukup.

## 🚀 Next Steps

Setelah Firebase setup selesai:
1. Test signup dan login
2. Cek data di Firebase Console
3. Implementasi fitur tambahan (profile update, delete account)
4. Setup production environment
