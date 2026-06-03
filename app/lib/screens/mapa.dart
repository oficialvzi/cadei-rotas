import 'package:flutter/material.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  int _indiceAbaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Text(
                'Google Maps será renderizado aqui\n(Campus da UnB)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          Positioned(
            top: 400,
            left: 200,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0E5FB5).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0E5FB5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 280,
            left: 120,
            child: GestureDetector(
              onTap: () => _mostrarDetalhesDoPin(context, 'Local Acessível', const Color(0xFF0E5FB5)),
              child: const Icon(Icons.location_on, size: 50, color: Color(0xFF0E5FB5)),
            ),
          ),

          Positioned(
            top: 350,
            left: 250,
            child: GestureDetector(
              onTap: () => _mostrarDetalhesDoPin(context, 'Barreira Parcial', const Color(0xFFD85A30)),
              child: const Icon(Icons.location_on, size: 50, color: Color(0xFFD85A30)),
            ),
          ),

          Positioned(
            top: 450,
            left: 100,
            child: GestureDetector(
              onTap: () => _mostrarDetalhesDoPin(context, 'Bloqueio Total', const Color(0xFFA32D2D)),
              child: const Icon(Icons.location_on, size: 50, color: Color(0xFFA32D2D)),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar local na FT...',
                    hintStyle: TextStyle(fontFamily: 'Inter', color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          debugPrint("Botão de criar report acionado");
        },
        backgroundColor: const Color(0xFF0E5FB5),
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text(
          'Reportar',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAbaAtual,
        onTap: (index) {
          setState(() {
            _indiceAbaAtual = index;
          });
        },
        selectedItemColor: const Color(0xFF0E5FB5),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _mostrarDetalhesDoPin(BuildContext context, String categoria, Color corPin) {
    String tituloFicticio = '';
    String descricaoFicticia = '';
    int reportsFicticios = 0;

    if (corPin == const Color(0xFF0E5FB5)) {
      tituloFicticio = 'Rampa de Acesso Principal';
      descricaoFicticia = 'A rampa encontra-se em perfeitas condições, com inclinação adequada e piso tátil. Acesso totalmente livre para o pavilhão de aulas.';
      reportsFicticios = 1;
    } else if (corPin == const Color(0xFFD85A30)) {
      tituloFicticio = 'Porta muito pesada';
      descricaoFicticia = 'A porta do laboratório de redes é excessivamente pesada e a mola está desregulada, dificultando muito a entrada sem auxílio externo.';
      reportsFicticios = 4;
    } else {
      tituloFicticio = 'Caminho bloqueado por obras';
      descricaoFicticia = 'Obras no corredor principal deixaram restos de material no chão, impossibilitando por completo a passagem de cadeiras de rodas.';
      reportsFicticios = 12;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFE1F5EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Fotografia do local (em breve)',
                      style: TextStyle(fontFamily: 'Inter', color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: corPin,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoria,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 18, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '$reportsFicticios reports',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                tituloFicticio,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                descricaoFicticia,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        debugPrint('Confirmar clicado');
                      },
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('Confirmar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E5FB5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        debugPrint('Contestar clicado');
                      },
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text('Contestar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA32D2D),
                        side: const BorderSide(color: Color(0xFFA32D2D), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}