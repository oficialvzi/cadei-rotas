import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  int _indiceAbaAtual = 0;
  late GoogleMapController _mapController;

  // Variável para controlar se o Android já liberou o GPS
  bool _permissaoLocalizacaoConcedida = false;

  final LatLng _posicaoInicial = const LatLng(-15.7633, -47.8702);

  @override
  void initState() {
    super.initState();
    // Assim que a tela carregar, pedimos a permissão
    _pedirPermissaoGPS();
  }

  // Função que faz o pop-up nativo do Android aparecer
  Future<void> _pedirPermissaoGPS() async {
    LocationPermission permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.whileInUse || permissao == LocationPermission.always) {
      // Se o usuário permitiu, atualizamos a tela para ligar a bolinha azul no mapa
      setState(() {
        _permissaoLocalizacaoConcedida = true;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Set<Marker> _criarMarcadores() {
    return {
      Marker(
        markerId: const MarkerId('acessivel_1'),
        position: const LatLng(-15.7635, -47.8705),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: () => _mostrarDetalhesDoPin(context, 'Local Acessível', const Color(0xFF0E5FB5)),
      ),
      Marker(
        markerId: const MarkerId('barreira_1'),
        position: const LatLng(-15.7630, -47.8700),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () => _mostrarDetalhesDoPin(context, 'Barreira Parcial', const Color(0xFFD85A30)),
      ),
      Marker(
        markerId: const MarkerId('bloqueio_1'),
        position: const LatLng(-15.7628, -47.8708),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () => _mostrarDetalhesDoPin(context, 'Bloqueio Total', const Color(0xFFA32D2D)),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _posicaoInicial,
              zoom: 17.5,
            ),
            markers: _criarMarcadores(),
            // Agora o mapa só ativa o GPS se a permissão foi dada com sucesso
            myLocationEnabled: _permissaoLocalizacaoConcedida,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
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