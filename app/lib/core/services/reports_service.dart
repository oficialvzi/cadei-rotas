import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class ReportsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Parâmetros do sistema de credibilidade ───────────────────
  static const double pesoCadastrado = 1.0;
  static const double pesoAnonimo = 0.34; // ~3 anônimos = 1 cadastrado
  static const double limiarEfetivacao = 1.0; // vira 'ativo'
  static const double limiarArquivamento = 1.0;
  static const double raioJuncaoMetros = 10.0; // pins mais próximos que isso se juntam

  // ─── Status possíveis ─────────────────────────────────────────
  static const statusPendente = 'pendente';
  static const statusAtivo = 'ativo';
  static const statusArquivado = 'arquivado';

  String gerarIdPin() => _db.collection('pins').doc().id;

  double _peso(bool ehCadastrado) =>
      ehCadastrado ? pesoCadastrado : pesoAnonimo;

  /// Procura um pin da MESMA categoria dentro do raio de junção.
  /// Retorna o documento encontrado ou null.
  Future<QueryDocumentSnapshot?> _buscarPinParecido({
    required double lat,
    required double lng,
    required String categoria,
  }) async {
    // Busca pins da mesma categoria que não estejam arquivados.
    final snap = await _db
        .collection('pins')
        .where('categoria', isEqualTo: categoria)
        .where('status', whereIn: [statusPendente, statusAtivo])
        .get();

    for (final doc in snap.docs) {
      final dados = doc.data();
      final GeoPoint pos = dados['localizacao'] as GeoPoint;
      final distancia = Geolocator.distanceBetween(
        lat,
        lng,
        pos.latitude,
        pos.longitude,
      );
      if (distancia <= raioJuncaoMetros) return doc;
    }
    return null;
  }

  /// Cria um pin novo OU, se houver pin parecido por perto,
  /// registra o report como uma confirmação daquele pin.
  ///
  /// Retorna um mapa com:
  ///   'juntado': bool  — true se foi somado a um pin existente
  ///   'pinId': String  — o id do pin criado ou reforçado
  Future<Map<String, dynamic>> criarOuJuntarPin({
    required String pinId,
    required double lat,
    required double lng,
    required String categoria,
    String? subcategoria,
    required String titulo,
    required String descricao,
    String? fotoUrl,
    required String criadoPor,
    required bool ehCadastrado,
  }) async {
    // 1. Existe pin parecido por perto?
    final parecido = await _buscarPinParecido(
      lat: lat,
      lng: lng,
      categoria: categoria,
    );

    if (parecido != null) {
      // Junta: registra como confirmação do pin existente
      await votar(
        pinId: parecido.id,
        uid: criadoPor,
        ehCadastrado: ehCadastrado,
        tipo: 'confirma',
      );
      return {'juntado': true, 'pinId': parecido.id};
    }

    // 2. Não há parecido — cria pin novo
    final peso = _peso(ehCadastrado);
    final status = peso >= limiarEfetivacao ? statusAtivo : statusPendente;

    await _db.collection('pins').doc(pinId).set({
      'localizacao': GeoPoint(lat, lng),
      'categoria': categoria,
      'subcategoria': subcategoria,
      'titulo': titulo,
      'descricao': descricao,
      'fotoUrl': fotoUrl,
      'criadoPor': criadoPor,
      'criadoEm': FieldValue.serverTimestamp(),

      // credibilidade — o criador já conta como primeira confirmação
      'credibilidadeConfirma': peso,
      'credibilidadeContesta': 0.0,
      'totalConfirma': 1,
      'totalContesta': 0,
      'status': status,

      // verificação (manual por ora; gancho para IA depois)
      'verificado': false,
      'verificadoPor': null,
    });

    // registra o voto do criador na subcoleção
    await _db
        .collection('pins')
        .doc(pinId)
        .collection('votos')
        .doc(criadoPor)
        .set({
          'tipo': 'confirma',
          'peso': peso,
          'em': FieldValue.serverTimestamp(),
        });

    return {'juntado': false, 'pinId': pinId};
  }

  /// Registra (ou troca) o voto de um usuário em um pin.
  /// tipo: 'confirma' | 'contesta'
  Future<void> votar({
    required String pinId,
    required String uid,
    required bool ehCadastrado,
    required String tipo,
  }) async {
    final pinRef = _db.collection('pins').doc(pinId);
    final votoRef = pinRef.collection('votos').doc(uid);
    final peso = _peso(ehCadastrado);

    await _db.runTransaction((tx) async {
      final pinSnap = await tx.get(pinRef);
      if (!pinSnap.exists) return;

      final votoSnap = await tx.get(votoRef);
      final dados = pinSnap.data() as Map<String, dynamic>;

      double confirma = (dados['credibilidadeConfirma'] ?? 0).toDouble();
      double contesta = (dados['credibilidadeContesta'] ?? 0).toDouble();
      int totalConfirma = (dados['totalConfirma'] ?? 0);
      int totalContesta = (dados['totalContesta'] ?? 0);

      // Se já votou antes, remove o voto anterior primeiro
      if (votoSnap.exists) {
        final anterior = votoSnap.data() as Map<String, dynamic>;
        final tipoAnterior = anterior['tipo'];
        final pesoAnterior = (anterior['peso'] ?? 0).toDouble();

        // Votou igual de novo → desfaz o voto (toggle)
        if (tipoAnterior == tipo) {
          if (tipo == 'confirma') {
            confirma -= pesoAnterior;
            totalConfirma -= 1;
          } else {
            contesta -= pesoAnterior;
            totalContesta -= 1;
          }
          tx.delete(votoRef);
          tx.update(pinRef, {
            'credibilidadeConfirma': confirma < 0 ? 0.0 : confirma,
            'credibilidadeContesta': contesta < 0 ? 0.0 : contesta,
            'totalConfirma': totalConfirma < 0 ? 0 : totalConfirma,
            'totalContesta': totalContesta < 0 ? 0 : totalContesta,
            'status': _calcularStatus(confirma, contesta),
          });
          return;
        }

        // Mudou de ideia → tira do lado antigo
        if (tipoAnterior == 'confirma') {
          confirma -= pesoAnterior;
          totalConfirma -= 1;
        } else {
          contesta -= pesoAnterior;
          totalContesta -= 1;
        }
      }

      // Aplica o novo voto
      if (tipo == 'confirma') {
        confirma += peso;
        totalConfirma += 1;
      } else {
        contesta += peso;
        totalContesta += 1;
      }

      if (confirma < 0) confirma = 0;
      if (contesta < 0) contesta = 0;

      tx.set(votoRef, {
        'tipo': tipo,
        'peso': peso,
        'em': FieldValue.serverTimestamp(),
      });

      tx.update(pinRef, {
        'credibilidadeConfirma': confirma,
        'credibilidadeContesta': contesta,
        'totalConfirma': totalConfirma < 0 ? 0 : totalConfirma,
        'totalContesta': totalContesta < 0 ? 0 : totalContesta,
        'status': _calcularStatus(confirma, contesta),
      });
    });
  }

  /// Regra de status a partir das credibilidades.
  String _calcularStatus(double confirma, double contesta) {
    // Arquivado: contestações alcançaram/superaram as confirmações
    if (contesta >= limiarArquivamento && contesta >= confirma) {
      return statusArquivado;
    }
    if (confirma >= limiarEfetivacao) return statusAtivo;
    return statusPendente;
  }

  /// Busca o voto atual do usuário em um pin (null se não votou).
  Future<String?> votoDoUsuario(String pinId, String uid) async {
    final snap = await _db
        .collection('pins')
        .doc(pinId)
        .collection('votos')
        .doc(uid)
        .get();
    if (!snap.exists) return null;
    return (snap.data() as Map<String, dynamic>)['tipo'] as String?;
  }

  /// Stream dos pins visíveis no mapa (ativos e pendentes; arquivados somem).
  Stream<QuerySnapshot> streamPins() {
    return _db
        .collection('pins')
        .where('status', whereIn: [statusPendente, statusAtivo])
        .snapshots();
  }
}
