// lib/main.dart
// Ponto de entrada da aplicação

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Garante que os bindings do Flutter estão prontos antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase (necessário antes de qualquer uso)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AgendaApp());
}

class AgendaApp extends StatelessWidget {
  const AgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Compromissos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // StreamBuilder escuta o estado de autenticação em tempo real.
      // Se o usuário estiver logado → HomeScreen
      // Se não estiver logado → LoginScreen
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica o estado, mostra loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Usuário autenticado
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // Usuário não autenticado
          return const LoginScreen();
        },
      ),
    );
  }
}
