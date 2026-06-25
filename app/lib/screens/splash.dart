import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {  // ← muda para StatefulWidget
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarPrimeiroAcesso();
  }

  Future<void> _verificarPrimeiroAcesso() async {
    // aguarda os 3 segundos da animacao
    await Future.delayed(const Duration(seconds: 3));

    //  acessa a memoria
    final prefs = await SharedPreferences.getInstance();
    final bool primeiroAcesso = prefs.getBool('primeiroAcesso') ?? true;

    if (!mounted) return;

    //  redireciona de acordo com o historico
    if (primeiroAcesso) {
      Navigator.pushReplacementNamed(context, '/instrucoes');
    } else {
      Navigator.pushReplacementNamed(context, '/mapa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E5FB5),
              Color(0xFF0C447C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              SvgPicture.asset(
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
              const Spacer(flex: 2),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedThreeDots extends StatefulWidget {
  const AnimatedThreeDots({super.key});

  @override
  State<AnimatedThreeDots> createState() => _AnimatedThreeDotsState();
}

class _AnimatedThreeDotsState extends State<AnimatedThreeDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double delay = index * 0.4;
            final double radians =
                (_controller.value * 2 * math.pi) - delay;
            final double yOffset = math.sin(radians) * -6.0;
            return Transform.translate(
              offset: Offset(0, yOffset),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}