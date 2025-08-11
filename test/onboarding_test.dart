import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lockin_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Onboarding and Login navigation test', (WidgetTester tester) async {
    // Pump aplikasi
    await tester.pumpWidget(app.MyApp());

    // splash screen (3 detik)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ada di halaman onboarding pertama
    expect(find.text('Manage yourself'), findsOneWidget);

    // Lewati onboarding (tekan "Skip")
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Verifikasi halaman login
    expect(find.text('Welcome to LockIn'), findsOneWidget);

    // Isi email dan password
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.pumpAndSettle();

    // Tekan tombol Masuk
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle(const Duration(seconds: 2)); // Tunggu simulasi login

    // Verifikasi halaman home
    expect(find.text('Selamat datang di Home Page!'), findsOneWidget);
  });
}