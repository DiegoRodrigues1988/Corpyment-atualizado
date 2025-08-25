// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'helpers/notification_helper.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo')); // Define o fuso horário

  final notificationHelper = NotificationHelper();
  await notificationHelper.initialize();
  await notificationHelper.scheduleDailyMorningNotification();

  runApp(const PilatesCorpymentApp());
}

class PilatesCorpymentApp extends StatelessWidget {
  const PilatesCorpymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    return MaterialApp(
      title: 'Pilates Corpyment',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: goldColor, primary: goldColor, brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, foregroundColor: Colors.black87,
          elevation: 1.0, surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: goldColor, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: goldColor)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: goldColor, foregroundColor: Colors.white),
      ),
      home: const HomeScreen(),
    );
  }
}
