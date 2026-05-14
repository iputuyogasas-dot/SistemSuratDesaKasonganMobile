// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/auth_controller.dart';
import 'controllers/surat_controller.dart';
import 'controllers/informasi_controller.dart';
import 'utils/app_constants.dart';
import 'views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // paksa orientasi portrait saja
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // warna status bar transparan dengan ikon terang (dark mode setup)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller di root
    final authController = AuthController();
    final suratController = SuratController();
    final informasiController = InformasiController();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.surfaceColor,
          error: AppConstants.errorColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppConstants.textPrimary,
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        textTheme:
            GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: AppConstants.textPrimary,
          displayColor: AppConstants.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppConstants.primaryDark,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: GoogleFonts.poppins(
            color: AppConstants.surfaceColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppConstants.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppConstants.surfaceLight),
          ),
        ),
      ),
      home: SplashScreen(
        authController: authController,
        suratController: suratController,
        informasiController: informasiController,
      ),
    );
  }
}
