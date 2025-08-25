import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real Firebase signup
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      print('Starting signup for email: $email');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        print('User created: ${user.uid}, displayName: ${user.displayName}');
        await user.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        return {
          'success': true,
          'message': 'Akun berhasil dibuat! Selamat datang, $name!',
          'user': user,
        };
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password terlalu lemah. Minimal 6 karakter.';
          break;
        case 'email-already-in-use':
          message = 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'operation-not-allowed':
          message = 'Pendaftaran dengan email/password tidak diizinkan.';
          break;
        case 'network-request-failed':
          message = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e, stackTrace) {
      print('General Error during signup: $e\nStackTrace: $stackTrace');
      return {
        'success': false,
        'message': 'Terjadi kesalahan tak terduga: $e',
      };
    }
    
    return {
      'success': false,
      'message': 'Gagal membuat akun',
    };
  }

  // Real Firebase login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Starting login for email: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = result.user;
      print('Raw UserCredential: $result');
      print('User after login: $user');
      if (user != null) {
        print('User logged in successfully: ${user.uid}, displayName: ${user.displayName}');
        return {
          'success': true,
          'message': 'Selamat datang kembali!',
          'user': user,
        };
      } else {
        print('User is null after login');
        return {
          'success': false,
          'message': 'Gagal mendapatkan data pengguna',
        };
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar. Silakan daftar terlebih dahulu.';
          break;
        case 'wrong-password':
          message = 'Password salah. Periksa kembali password Anda.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          message = 'Akun Anda telah dinonaktifkan. Hubungi admin.';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan login. Coba lagi nanti.';
          break;
        case 'network-request-failed':
          message = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
          break;
        case 'invalid-credential':
          message = 'Email atau password salah.';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e, stackTrace) {
      print('General Error during login: $e\nStackTrace: $stackTrace');
      return {
        'success': false,
        'message': 'Terjadi kesalahan tak terduga: $e',
      };
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      print('User logged out successfully');
    } catch (e) {
      print('Logout error: $e');
      throw e;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  static bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get user stream for real-time auth state changes
  static Stream<User?> get userStream {
    return _auth.authStateChanges();
  }

  // Send password reset email
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Email reset password telah dikirim ke $email',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  // Delete demo method (no longer needed)
  static Future<void> addDemoUsers() async {
    print('Demo users method called - using real Firebase auth now');
  }
}