import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Importa o arquivo splash.dart que está localizado dentro da pasta screens
import 'screens/splash.dart';

void main() async{
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadei-Rotas',
      // Define a SplashScreen como a tela inicial do aplicativo
      home: SplashScreen(),
    );
  }
}