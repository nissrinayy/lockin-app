import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SecondOnboardingPage extends StatefulWidget {
  @override
  State<SecondOnboardingPage> createState() => _SecondOnboardingPageState();
}

class _SecondOnboardingPageState extends State<SecondOnboardingPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestNotificationPermission() async {
    try {
      // Cek status permission terlebih dahulu
      PermissionStatus status = await Permission.notification.status;
      
      if (status.isDenied) {
        // Request permission jika belum diberikan
        status = await Permission.notification.request();
      }
      
      if (status.isGranted) {
        // Buat notification channel
        await _createNotificationChannel();
        
        // Tampilkan notifikasi test
        await _showTestNotification();
        
        // Permission granted, show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifikasi berhasil diaktifkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, buka settings
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin notifikasi ditolak permanen. Buka Settings untuk mengaktifkan.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      } else {
        // Permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin notifikasi ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notifikasi Aktif!',
      'Aplikasi Lockin berhasil mengaktifkan notifikasi.',
      platformChannelSpecifics,
    );
  }

  void _turnOnNotifications() async {
    await _requestNotificationPermission();
    _goToHome();
  }

  void _skipNotifications() {
    _goToHome();
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.02),
              // Progress bar
              Stack(
                children: [
                  LinearProgressIndicator(
                    value: 1,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                    minHeight: 4,
                  ),
                  Container(
                    width: width * 0.9,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.05),
              Expanded(
                child: _buildNotificationPage(width, height),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationPage(double width, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        Text(
          'Turn on notifications',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: width * 0.07,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        
        SizedBox(height: height * 0.02),
        
        // Subtitle
        Text(
          'Enable notification for help you remember tasks you need to complete',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: width * 0.04,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        
        SizedBox(height: height * 0.05),
        
        // Illustration with toa.png
        Image.asset(
          'assets/toa.png',
          width: width * 0.7,
          height: width * 0.7,
          fit: BoxFit.contain,
        ),
        
        SizedBox(height: height * 0.08),
        
        // Turn on notifications button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.01),
          child: SizedBox(
            width: double.infinity,
            height: height * 0.065,
            child: ElevatedButton(
              onPressed: _turnOnNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Turn on notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: width * 0.04,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: height * 0.02),
        
        // No, thanks button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.01),
          child: SizedBox(
            width: double.infinity,
            height: height * 0.065,
            child: OutlinedButton(
              onPressed: _skipNotifications,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF4782F4), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                'No, thanks',
                style: TextStyle(
                  color: Color(0xFF4782F4),
                  fontWeight: FontWeight.w500,
                  fontSize: width * 0.04,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


}
