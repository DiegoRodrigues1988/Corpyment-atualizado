// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PilatesCorpymentApp());
}

class PilatesCorpymentApp extends StatelessWidget {
  const PilatesCorpymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definindo a cor dourada para ser reutilizada
    const Color goldColor = Color(0xFFD4AF37);

    return MaterialApp(
      title: 'Pilates Corpyment',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),

      // --- NOVO TEMA BRANCO E DOURADO ---
      theme: ThemeData(
        // Define o esquema de cores com o dourado como cor primária
        colorScheme: ColorScheme.fromSeed(
          seedColor: goldColor,
          primary: goldColor,
          brightness: Brightness.light, // Fundo claro (branco)
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white, // Fundo de todas as telas será branco

        // Tema da barra de aplicativos (AppBar)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // AppBar branca
          foregroundColor: Colors.black87, // Título e ícones pretos para contraste
          elevation: 1.0, // Uma leve sombra para destacar
          surfaceTintColor: Colors.transparent,
        ),

        // Tema para os botões principais
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: goldColor, // Fundo dourado
            foregroundColor: Colors.white, // Texto branco
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // Tema para os botões de texto (usados no seletor de data e alertas)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: goldColor, // Texto do botão dourado
          ),
        ),

        // Tema para o botão de ação flutuante (o de '+')
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: goldColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
