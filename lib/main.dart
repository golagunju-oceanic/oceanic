import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oceanic/core/constants/app_colors.dart';

import 'package:oceanic/presentation/features/home/view/splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'First Method',

          theme: ThemeData(
            primarySwatch: Colors.indigo,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: child,
        );
      },
      child: ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Oceanic Health',

          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
