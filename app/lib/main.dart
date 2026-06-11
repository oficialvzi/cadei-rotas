import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login.dart';
import 'screens/report_screen.dart';
import 'screens/splash.dart';
import 'screens/user_profile.dart';
import 'screens/instruction_slides.dart';
import 'screens/mapa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CadeiRotasApp());
}

class CadeiRotasApp extends StatelessWidget {
  const CadeiRotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadei-Rotas',
      initialRoute: '/splash',
      routes: {
        '/login':    (_) => const LoginScreen(),
        '/cadastro': (_) => const CadastroScreen(),
        '/splash':   (_) => const SplashScreen(),
        '/profile':  (_) => const TelaDePerfil(),
        '/instructions': (_) => const TelaDeInstrucoes(),
        '/mapa':     (_) => const MapaScreen(),
      },
    );
  }
}