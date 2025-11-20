// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart'; 

import 'firebase_options.dart';
import 'screens/creator_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 日本語ロケールデータの初期化
  await initializeDateFormatting('ja', null);
  
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
      primary: const Color(0xFFAEC6CF),
      secondary: const Color(0xFFFFB6C1),
      background: const Color(0xFFF0F4F7),
      surface: Colors.white,
      onPrimary: const Color(0xFF333333),
      onSecondary: const Color(0xFF333333),
      onBackground: const Color(0xFF4E5D66),
      onSurface: const Color(0xFF333333),
    );

    return MaterialApp(
      title: 'がくモン',
      debugShowCheckedModeBanner: false,

      // 【重要】サポートロケールの定義
      supportedLocales: const [
        Locale('ja', 'JP'), 
        Locale('en', 'US'),
      ],

      // 【重要】ローカライズデリゲートの設定
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,  
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('ja', 'JP'), 

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