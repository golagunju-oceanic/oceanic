import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:oceanic/core/constants/theme.dart';
import 'package:oceanic/core/services/notification_service.dart';
import 'package:oceanic/presentation/features/home/view/splash_screen.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ====================================================
// FIREBASE BACKGROUND HANDLER
// ====================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background notification received.');
}

// ====================================================
// MAIN
// ====================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firebaseApp = Firebase.app();

  debugPrint('FIREBASE PROJECT: ${firebaseApp.options.projectId}');

  debugPrint('FIREBASE SENDER ID: ${firebaseApp.options.messagingSenderId}');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      debugPrint('Starting Oceanic notification setup...');

      await NotificationService.instance.initialize();

      if (!mounted) return;

      // Temporary test: display a real Android notification.
      await NotificationService.instance.sendLocalTestNotification();

      debugPrint('Oceanic notification test finished.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,

          scaffoldMessengerKey:
              NotificationService.instance.scaffoldMessengerKey,

          debugShowCheckedModeBanner: false,

          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: ThemeMode.system,

          home: const SplashScreen(),
        );
      },
    );
  }
}
