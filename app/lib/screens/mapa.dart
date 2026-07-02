import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cadeirotas_app/core/models/categorias.dart';
import 'report_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  GoogleMapController? _mapController;
  bool _permissaoLocalizacaoConcedida = false;
  bool _selecionandoLocalReport = false;

  // Mantido como posição de carregamento (Fallback) enquanto o GPS busca o satélite
  final LatLng _posicaoInicial = const LatLng(-15.7633, -47.8702);

  @override
  void initState() {
    super.initState();
    _pedirPermissaoGPS();
  }

  Future<void> _pedirPermissaoGPS() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.whileInUse ||
        permissao == LocationPermission.always) {
      setState(() => _permissaoLocalizacaoConcedida = true);
      // Assim que a permissão for garantida, move a câmera
      _moverParaLocalizacaoAtual();
    }
  }

  // Função nova que busca a coordenada real e anima o mapa
  Future<void> _moverParaLocalizacaoAtual() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(pos.latitude, pos.longitude),
              zoom: 17.5,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao buscar localização: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Garante que o mapa vá para o local do usuário se a permissão já estiver salva no celular
    if (_permissaoLocalizacaoConcedida) {
      _moverParaLocalizacaoAtual();
    }
  }

  /// Converte os documentos do Firestore em marcadores do mapa.
  Set<Marker> _marcadoresDosDocs(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final dados = doc.data() as Map<String, dynamic>;
      final GeoPoint pos = dados['localizacao'] as GeoPoint;
      final String categoria = dados['categoria'] ?? 'acessivel';

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(Categorias.hue(categoria)),
        onTap: () => _mostrarDetalhesDoPin(dados),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pins').snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final marcadores = _marcadoresDosDocs(docs);

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _posicaoInicial,
                  zoom: 17.5,
                ),
                markers: marcadores,
                myLocationEnabled: _permissaoLocalizacaoConcedida,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onTap: (LatLng localTocado) {
                  if (_selecionandoLocalReport) {
                    setState(() => _selecionandoLocalReport = false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NovoReportScreen(localEscolhido: localTocado),
                      ),
                    );
                  }
                },
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
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.grey,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _selecionandoLocalReport = !_selecionandoLocalReport;
          });
        },
        backgroundColor: _selecionandoLocalReport
            ? const Color(0xFFD85A30)
            : const Color(0xFF0E5FB5),
        icon: Icon(
          _selecionandoLocalReport ? Icons.touch_app : Icons.add_location_alt,
          color: Colors.white,
        ),
        label: Text(
          _selecionandoLocalReport ? 'Toque no local' : 'Reportar',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        selectedItemColor: const Color(0xFF0E5FB5),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  void _mostrarDetalhesDoPin(Map<String, dynamic> dados) {
    final String categoria = dados['categoria'] ?? 'acessivel';
    final String? subcategoria = dados['subcategoria'];
    final String? subRotulo = subcategoria != null
        ? Categorias.subRotulos[subcategoria]
        : null;
    final Color corPin = Categorias.cores[categoria] ?? const Color(0xFF0E5FB5);
    final String rotuloCategoria = Categorias.rotulos[categoria] ?? 'Local';
    final String titulo = dados['titulo'] ?? 'Sem título';
    final String descricao = dados['descricao'] ?? '';
    final int totalReports = dados['totalReports'] ?? 1;
    final String? fotoUrl = dados['fotoUrl'];

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
                  image: fotoUrl != null
                      ? DecorationImage(
                    image: NetworkImage(fotoUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: fotoUrl == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Sem fotografia',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.black54,
                      ),
                    ),
                  ],
                )
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: corPin,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      rotuloCategoria,
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
                        '$totalReports reports',
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

              if (categoria == Categorias.parcial && subRotulo != null) ...[
                Text(
                  subRotulo.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: corPin,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              
              Text(
                titulo,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                descricao,
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
                      onPressed: () => debugPrint('Confirmar clicado'),
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
                      onPressed: () => debugPrint('Contestar clicado'),
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text('Contestar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA32D2D),
                        side: const BorderSide(
                          color: Color(0xFFA32D2D),
                          width: 1.5,
                        ),
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