import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cadeirotas_app/core/models/categorias.dart';
import 'package:cadeirotas_app/core/services/places_service.dart';
import 'report_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cadeirotas_app/core/services/reports_service.dart';
import 'package:cadeirotas_app/core/services/auth_service.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  GoogleMapController? _mapController;
  bool _permissaoLocalizacaoConcedida = false;
  bool _selecionandoLocalReport = false;

  final LatLng _posicaoInicial = const LatLng(-15.7633, -47.8702);
  static CameraPosition? _ultimaPosicaoSalva;

  // ─── Busca ───────────────────────────────────────────────
  final _buscaCtrl = TextEditingController();
  final _placesService = PlacesService();
  Timer? _debounce;
  List<ResultadoLugar> _resultadosLugares = [];
  List<QueryDocumentSnapshot> _resultadosPins = [];
  bool _buscando = false;

  // Guarda os pins atuais do stream, para buscar neles
  List<QueryDocumentSnapshot> _pinsAtuais = [];

  @override
  void initState() {
    super.initState();
    _pedirPermissaoGPS();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _pedirPermissaoGPS() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.whileInUse ||
        permissao == LocationPermission.always) {
      setState(() => _permissaoLocalizacaoConcedida = true);
      //_moverParaLocalizacaoAtual();
    }
  }

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
    //if (_permissaoLocalizacaoConcedida) {
    //  _moverParaLocalizacaoAtual();
    //}
  }

  Set<Marker> _marcadoresDosDocs(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final dados = doc.data() as Map<String, dynamic>;
      final GeoPoint pos = dados['localizacao'] as GeoPoint;
      final String categoria = dados['categoria'] ?? 'acessivel';
      final String status = dados['status'] ?? 'ativo';
      final bool pendente = status == 'pendente';

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(Categorias.hue(categoria)),
        alpha: pendente ? 0.5 : 1.0, // ← translúcido se pendente
        onTap: () => _mostrarDetalhesDoPin(doc.id, dados),
      );
    }).toSet();
  }

  // ─── Lógica de busca ─────────────────────────────────────
  void _onTextoBuscaMudou(String texto) {
    _debounce?.cancel();

    // Busca nos pins é instantânea (em memória)
    final termo = texto.trim().toLowerCase();
    if (termo.isEmpty) {
      setState(() {
        _resultadosLugares = [];
        _resultadosPins = [];
      });
      return;
    }

    _resultadosPins = _pinsAtuais
        .where((doc) {
          final dados = doc.data() as Map<String, dynamic>;
          final titulo = (dados['titulo'] ?? '').toString().toLowerCase();
          return titulo.contains(termo);
        })
        .take(5)
        .toList();

    setState(() => _buscando = true);

    // Busca de lugares no Google com debounce (evita chamar a cada tecla)
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final lugares = await _placesService.autocomplete(texto);
      if (mounted) {
        setState(() {
          _resultadosLugares = lugares;
          _buscando = false;
        });
      }
    });
  }

  Future<void> _irParaLugar(ResultadoLugar lugar) async {
    _fecharBusca();
    final loc = await _placesService.detalhesLocalizacao(lugar.placeId);
    if (loc != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(loc['lat']!, loc['lng']!), zoom: 18),
        ),
      );
    }
  }

  void _irParaPin(QueryDocumentSnapshot doc) {
    _fecharBusca();
    final dados = doc.data() as Map<String, dynamic>;
    final GeoPoint pos = dados['localizacao'] as GeoPoint;

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 18.5),
      ),
    );

    // Abre o detalhe do pin após a câmera começar a mover
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _mostrarDetalhesDoPin(doc.id, dados);
    });
  }

  void _fecharBusca() {
    _buscaCtrl.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _resultadosLugares = [];
      _resultadosPins = [];
      _buscando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pins')
            .where('status', whereIn: ['pendente', 'ativo'])
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          _pinsAtuais = docs; // guarda para a busca
          final marcadores = _marcadoresDosDocs(docs);

          final temResultados =
              _resultadosLugares.isNotEmpty || _resultadosPins.isNotEmpty;

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition:
                    CameraPosition(target: _posicaoInicial, zoom: 17.5),
                onCameraMove: (pos) => _ultimaPosicaoSalva = pos,
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
                  } else {
                    _fecharBusca(); // toque no mapa fecha a busca
                  }
                },
              ),

              // Barra de busca + resultados
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
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
                        child: TextField(
                          controller: _buscaCtrl,
                          onChanged: _onTextoBuscaMudou,
                          decoration: InputDecoration(
                            hintText: 'Buscar local ou pino...',
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.grey,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: _buscaCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                    ),
                                    onPressed: _fecharBusca,
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),

                      // Lista de resultados
                      if (temResultados || _buscando)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: [
                              // Pins primeiro
                              ..._resultadosPins.map((doc) {
                                final dados =
                                    doc.data() as Map<String, dynamic>;
                                final categoria =
                                    dados['categoria'] ?? 'acessivel';
                                final cor =
                                    Categorias.cores[categoria] ??
                                    const Color(0xFF0E5FB5);
                                return ListTile(
                                  leading: Icon(Icons.location_on, color: cor),
                                  title: Text(dados['titulo'] ?? 'Pino'),
                                  subtitle: Text(
                                    Categorias.rotulos[categoria] ?? '',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onTap: () => _irParaPin(doc),
                                );
                              }),

                              // Depois lugares do Google
                              ..._resultadosLugares.map((lugar) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.place_outlined,
                                    color: Colors.grey,
                                  ),
                                  title: Text(lugar.nomePrincipal),
                                  subtitle: lugar.nomeSecundario.isNotEmpty
                                      ? Text(
                                          lugar.nomeSecundario,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  onTap: () => _irParaLugar(lugar),
                                );
                              }),

                              if (_buscando)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botão: ir para minha localização
          FloatingActionButton(
            heroTag: 'btnLocalizacao',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _permissaoLocalizacaoConcedida
                ? _moverParaLocalizacaoAtual
                : _pedirPermissaoGPS,
            child: const Icon(Icons.my_location, color: Color(0xFF0E5FB5)),
          ),
          const SizedBox(height: 12),

          // Botão: reportar (o que já existia)
          FloatingActionButton.extended(
            heroTag: 'btnReportar',
            onPressed: () {
              setState(() {
                _selecionandoLocalReport = !_selecionandoLocalReport;
              });
            },
            backgroundColor: _selecionandoLocalReport
                ? const Color(0xFFD85A30)
                : const Color(0xFF0E5FB5),
            icon: Icon(
              _selecionandoLocalReport
                  ? Icons.touch_app
                  : Icons.add_location_alt,
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
        ],
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

  void _mostrarDetalhesDoPin(String pinId, Map<String, dynamic> dados) {
    final String categoria = dados['categoria'] ?? 'acessivel';
    final String? subcategoria = dados['subcategoria'];
    final String? subRotulo = subcategoria != null
        ? Categorias.subRotulos[subcategoria]
        : null;
    final Color corPin = Categorias.cores[categoria] ?? const Color(0xFF0E5FB5);
    final String rotuloCategoria = Categorias.rotulos[categoria] ?? 'Local';
    final String titulo = dados['titulo'] ?? 'Sem título';
    final String descricao = dados['descricao'] ?? '';
    final String? fotoUrl = dados['fotoUrl'];
    final bool verificado = dados['verificado'] == true;
    final String status = dados['status'] ?? 'ativo';

    final reports = ReportsService();
    final auth = AuthService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // StreamBuilder para os contadores atualizarem ao vivo
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pins')
              .doc(pinId)
              .snapshots(),
          builder: (context, snap) {
            final atual = (snap.data?.data() as Map<String, dynamic>?) ?? dados;
            final int totalConfirma = atual['totalConfirma'] ?? 0;
            final int totalContesta = atual['totalContesta'] ?? 0;
            final String statusAtual = atual['status'] ?? status;
            final bool verificadoAtual =
                atual['verificado'] == true || verificado;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE1F5EE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // ── AVISO DE PENDENTE ──
                    if (statusAtual == 'pendente') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE0B050)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 18,
                              color: Color(0xFFB07800),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Aguardando confirmações da comunidade',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFFB07800),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── FOTO ──
                    GestureDetector(
                      onTap: fotoUrl != null
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _VisualizadorFoto(url: fotoUrl),
                              ),
                            )
                          : null,
                      child: Stack(
                        children: [
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
                                      Icon(
                                        Icons.image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
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
                          if (fotoUrl != null)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── CATEGORIA + VERIFICADO + CONTADORES ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                            if (verificadoAtual) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F6E56),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verificado',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Contadores confirma/contesta
                    Row(
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          size: 15,
                          color: Color(0xFF0E5FB5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalConfirma confirmam',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.thumb_down,
                          size: 15,
                          color: Color(0xFFA32D2D),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalContesta contestam',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (categoria == Categorias.parcial &&
                        subRotulo != null) ...[
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

                    // ── BOTÕES DE VOTAÇÃO ──
                    FutureBuilder<String?>(
                      future: auth.usuarioAtual != null
                          ? reports.votoDoUsuario(pinId, auth.usuarioAtual!.uid)
                          : Future.value(null),
                      builder: (context, votoSnap) {
                        final meuVoto = votoSnap.data;

                        Future<void> aoVotar(String tipo) async {
                          final user = await auth.entrarAnonimo();
                          if (user == null) return;
                          await reports.votar(
                            pinId: pinId,
                            uid: user.uid,
                            ehCadastrado: auth.estaCadastrado,
                            tipo: tipo,
                          );
                          // força rebuild do FutureBuilder
                          if (context.mounted) {
                            (context as Element).markNeedsBuild();
                          }
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => aoVotar('confirma'),
                                icon: Icon(
                                  meuVoto == 'confirma'
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                ),
                                label: Text(
                                  meuVoto == 'confirma'
                                      ? 'Confirmado'
                                      : 'Confirmar',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: meuVoto == 'confirma'
                                      ? const Color(0xFF0B4A8F)
                                      : const Color(0xFF0E5FB5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                onPressed: () => aoVotar('contesta'),
                                icon: Icon(
                                  meuVoto == 'contesta'
                                      ? Icons.thumb_down
                                      : Icons.thumb_down_alt_outlined,
                                ),
                                label: Text(
                                  meuVoto == 'contesta'
                                      ? 'Contestado'
                                      : 'Contestar',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFA32D2D),
                                  backgroundColor: meuVoto == 'contesta'
                                      ? const Color(0xFFF7E0E0)
                                      : null,
                                  side: const BorderSide(
                                    color: Color(0xFFA32D2D),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  VISUALIZADOR DE FOTO EM TELA CHEIA (com zoom)
// ══════════════════════════════════════════════════════════════════
class _VisualizadorFoto extends StatelessWidget {
  final String url;
  const _VisualizadorFoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (context, error, stack) =>
                const Icon(Icons.broken_image, color: Colors.white54, size: 64),
          ),
        ),
      ),
    );
  }
}
