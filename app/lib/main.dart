import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(const SecretariaEscolarApp());
}

class SecretariaEscolarApp extends StatelessWidget {
  const SecretariaEscolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secretaria Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: corAzulEscuro),
        useMaterial3: true,
        scaffoldBackgroundColor: corFundo,
      ),
      home: const HomeScreen(),
    );
  }
}
