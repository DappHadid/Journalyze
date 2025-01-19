import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:journalyze/firebase/firebase_options.dart';
import 'package:journalyze/pages/bookmark.dart';
import 'package:journalyze/pages/dashboard_admin.dart';
import 'package:journalyze/pages/dashboard_user.dart';
import 'package:journalyze/pages/forgot_pass.dart';
import 'package:journalyze/pages/register_page.dart';
import 'package:journalyze/pages/welcome_page.dart';
import 'package:journalyze/utils/splash_screen.dart';
import 'package:journalyze/pages/journal_detail_user.dart';
import 'package:device_preview_plus/device_preview_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journalyze',
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      home: AppSplashScreen(),
      routes: {
        'splash': (context) => AppSplashScreen(),
        'welcome_screen': (context) => WelcomeScreen(),
        'forgot_pass': (context) => ForgotPasswordPage(),
        'registration_screen': (context) => RegistrationScreen(),
        'dashboard_admin': (context) => DashboardAdmin(),
        'dashboard_user': (context) => DashboardUser(),
        'bookmark': (context) => BookmarkPage(),
      },
    );
  }
}
