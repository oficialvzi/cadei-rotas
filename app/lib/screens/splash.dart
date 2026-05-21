import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const CadeiRotasApp());
}

class CadeiRotasApp extends StatelessWidget {
  const CadeiRotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadei-Rotas',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient( // gradiente
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E5FB5), // Azul Rota
              Color(0xFF0C447C), // Azul Profundo
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer (flex: 3),

              SvgPicture.asset( // icone do meio
                'assets/images/logo-icone.svg',
                height: 200,
              ),
              const SizedBox(height: 24),
              const Text(
                'Cadei-Rotas',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'ACESSIBILIDADE EM ROTA',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),

              const Spacer (flex: 2),

              const AnimatedThreeDots(),

              const SizedBox(height: 12),

              const Text(
                'Carregando...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
              const SizedBox (height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// --- COMPONENTE DA ANIMAÇÃO DOS TRÊS PONTINHOS ---
// Usamos um StatefulWidget porque cascatas de animação guardam "estado" de tempo
class AnimatedThreeDots extends StatefulWidget {
  const AnimatedThreeDots({super.key});

  @override
  State<AnimatedThreeDots> createState() => _AnimatedThreeDotsState();
}

class _AnimatedThreeDotsState extends State<AnimatedThreeDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Configura a animação para durar 1.2 segundos e rodar continuamente (repeat)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // Boa prática: descarta o controlador ao fechar a tela para poupar memória
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Mantém os pontos centralizados horizontalmente
      children: List.generate(3, (index) {
        // O AnimatedBuilder reconstrói apenas os pontinhos a cada frame da animação
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Criamos um atraso (delay) para cada bolinha com base no seu índice (0, 1 ou 2)
            // É isso que faz uma bolinha subir depois da outra em efeito de onda
            final double delay = index * 0.4;
            final double radians = (_controller.value * 2 * math.pi) - delay;

            // Usamos a função seno (math.sin) para fazer um movimento suave de subida e descida
            // O número -6.0 determina a altura que as bolinhas vão subir (6 pixels)
            final double yOffset = math.sin(radians) * -6.0;

            return Transform.translate(
              offset: Offset(0, yOffset), // Move a bolinha no eixo Y (vertical)
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4), // Espaço entre as bolinhas
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle, // Transforma o container em um círculo perfeito
                ),
              ),
            );
          },
        );
      }),
    );
  }
}