// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/creator_splash_screen.dart';


class ThemeController extends ChangeNotifier {
  // 初期色
  Color _primaryColor = const Color(0xFFAEC6CF);
  // 初期サブカラー
  Color _secondaryColor = const Color(0xFFFFB6C1);

  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;

  // 色を変更するメソッド
  void changeThemeColor(Color newPrimary, Color newSecondary) {
    _primaryColor = newPrimary;
    _secondaryColor = newSecondary;
    notifyListeners(); 
  }
}

final themeController = ThemeController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
    
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        
      
        final colorScheme = ColorScheme.light(
          primary: themeController.primaryColor,   
          secondary: themeController.secondaryColor, 
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

          supportedLocales: const [
            Locale('ja', 'JP'),
            Locale('en', 'US'),
          ],

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
         
          home: const CreatorSplashScreen(), 
        );
      },
    );
  }
}