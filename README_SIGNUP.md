# Fitur Signup LockIn App

## Overview
Fitur signup telah berhasil ditambahkan ke aplikasi LockIn dengan flow yang sesuai dengan permintaan:
- **Flow**: Onboarding → Login → Signup (dari button "Daftar Akun")
- **Design**: Menggunakan logo.png dan mengikuti desain yang diberikan
- **Backend**: Service autentikasi dengan validasi dan session management

## Fitur yang Ditambahkan

### 1. Halaman Signup (`lib/signup_page.dart`)
- **Design**: Mengikuti desain yang diberikan dengan logo, gradient text, dan form fields
- **Fields**: Nama, Email Address, Password
- **Validasi**:
  - Semua field wajib diisi
  - Format email harus valid
  - Password minimal 6 karakter
- **UI Elements**:
  - Logo dari `assets/logo.png`
  - Gradient text "Buat Akun Baru"
  - Form fields dengan styling yang konsisten
  - Button "Daftar" dengan gradient background
  - Separator dengan text "Sudah Punya Akun?"
  - Button "Masuk" untuk kembali ke login

### 2. AuthService (`lib/services/auth_service.dart`)
- **Login**: Validasi email dan password
- **Signup**: Registrasi user baru dengan validasi
- **Session Management**: Menggunakan SharedPreferences
- **Error Handling**: Pesan error yang informatif
- **API Ready**: Siap untuk integrasi dengan backend API

### 3. Update Login Page
- **Navigation**: Button "Daftar Akun" sekarang mengarah ke halaman signup
- **Integration**: Menggunakan AuthService untuk login
- **Error Handling**: Pesan error yang lebih baik

### 4. Route Configuration
- **Main.dart**: Menambahkan route `/signup`
- **Navigation**: Flow yang konsisten antar halaman

## Flow Aplikasi

```
Splash Screen → Onboarding → Login Page → [Daftar Akun] → Signup Page
                                    ↓
                              [Masuk] → Second Onboarding → Home
```

## Validasi yang Diterapkan

### Signup Validation
- **Nama**: Tidak boleh kosong
- **Email**: Format email valid, tidak boleh kosong
- **Password**: Minimal 6 karakter, tidak boleh kosong

### Login Validation
- **Email**: Tidak boleh kosong
- **Password**: Tidak boleh kosong
- **User Check**: Email harus terdaftar, password harus benar

## Backend Integration

### Current Implementation (Local Storage)
- Menggunakan SharedPreferences untuk menyimpan data user
- Simulasi API call dengan delay 1 detik
- Data user disimpan dalam memory (Map)

### Real API Integration
- Dokumentasi API lengkap di `backend_api_documentation.md`
- Contoh implementasi Node.js/Express
- Security best practices
- JWT token authentication

## File Structure

```
lib/
├── main.dart (updated with signup route)
├── login_page.dart (updated with navigation and AuthService)
├── signup_page.dart (new file)
├── services/
│   └── auth_service.dart (new file)
└── ... (existing files)

backend_api_documentation.md (new file)
README_SIGNUP.md (this file)
```

## Cara Menjalankan

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run App**:
   ```bash
   flutter run
   ```

3. **Test Flow**:
   - Buka aplikasi
   - Lewati onboarding
   - Di login page, klik "Daftar Akun"
   - Isi form signup
   - Klik "Daftar"
   - Akan diarahkan ke second onboarding

## Testing

### Manual Testing
1. **Signup dengan data valid**: Harus berhasil dan redirect ke onboarding
2. **Signup dengan email kosong**: Harus muncul error
3. **Signup dengan password < 6 karakter**: Harus muncul error
4. **Signup dengan email format salah**: Harus muncul error
5. **Login dengan user yang sudah daftar**: Harus berhasil
6. **Login dengan user tidak terdaftar**: Harus muncul error

### Automated Testing
- File test sudah ada di `test/` folder
- Bisa ditambahkan test untuk signup dan login

## Security Features

### Implemented
- Password validation (minimal 6 karakter)
- Email format validation
- Input sanitization
- Session management

### Recommended for Production
- Password hashing (bcrypt/argon2)
- JWT token authentication
- Rate limiting
- HTTPS enforcement
- Input validation di server side

## Next Steps

1. **Backend Integration**: Implementasi API backend yang sebenarnya
2. **Password Hashing**: Tambahkan bcrypt untuk password security
3. **JWT Token**: Implementasi JWT untuk authentication
4. **Error Handling**: Tambahkan error handling yang lebih robust
5. **Loading States**: Improve loading indicators
6. **Form Validation**: Tambahkan real-time validation
7. **Testing**: Tambahkan unit tests dan integration tests

## Dependencies Added

- `http: ^1.1.0` - Untuk API calls (sudah ada di pubspec.yaml)

## Notes

- Logo menggunakan `assets/logo.png` sesuai permintaan
- Design mengikuti style yang konsisten dengan halaman lain
- Backend service siap untuk integrasi dengan API yang sebenarnya
- Semua validasi mengikuti standar umum aplikasi
- Error messages dalam bahasa Indonesia
