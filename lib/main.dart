// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/creator_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final colorScheme = ColorScheme.light(
      primary: const Color(0xFFAEC6CF),      // メインカラー (パステルブルー)
      secondary: const Color(0xFFFFB6C1),    // アクセントカラー (パステルピンク)
      background: const Color(0xFFF0F4F7),  // 背景色 (ごく薄いブルーグレー)
      surface: Colors.white,                 // カードなどの表面色
      onPrimary: const Color(0xFF333333),    // primaryカラーの上のテキスト色 (濃いグレー)
      onSecondary: const Color(0xFF333333),  // secondaryカラーの上のテキスト色 (濃いグレー)
      onBackground: const Color(0xFF4E5D66),  // 背景の上のテキスト色 (少し青みがかったグレー)
      onSurface: const Color(0xFF333333),      // surfaceの上のテキスト色 (濃いグレー)
    );

    return MaterialApp(
      title: 'がくモン',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          centerTitle: true,
          titleTextStyle: GoogleFonts.mPlusRounded1c(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: GoogleFonts.mPlusRounded1cTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: colorScheme.onBackground,
          displayColor: colorScheme.onBackground,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: GoogleFonts.mPlusRounded1c(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: CreatorSplashScreen(),
    );
  }
}