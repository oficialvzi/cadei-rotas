import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class ReportsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Parâmetros do sistema de credibilidade ───────────────────
  static const double pesoCadastrado = 1.0;
  static const double pesoAnonimo = 0.34; // ~3 anônimos = 1 cadastrado
  static const double limiarEfetivacao = 1.0; // vira 'ativo'
  static const double limiarArquivamento = 1.0;
  static const double raioJuncaoMetros = 5.0; // pins mais próximos se juntam

  // ─── Verificação automática ───────────────────────────────────
  static const int minConfirmaVerificado = 3; // 3+ confirmações
  static const int maxContestaVerificado = 0; // e ZERO contestações

  // ─── Status possíveis ─────────────────────────────────────────
  static const statusPendente = 'pendente';
  static const statusAtivo = 'ativo';
  static const statusArquivado = 'arquivado';

  String gerarIdPin() => _db.collection('pins').doc().id;

  double _peso(bool ehCadastrado) =>
      ehCadastrado ? pesoCadastrado : pesoAnonimo;

  /// Regra de status a partir das credibilidades.
  String _calcularStatus(double confirma, double contesta) {
    if (contesta >= limiarArquivamento && contesta >= confirma) {
      return statusArquivado;
    }
    if (confirma >= limiarEfetivacao) return statusAtivo;
    return statusPendente;
  }

  /// Um pin é verificado automaticamente com 3+ confirmações e 0 contestações.
  bool _calcularVerificado(int totalConfirma, int totalContesta) {
    return totalConfirma >= minConfirmaVerificado &&
        totalContesta <= maxContestaVerificado;
  }

  /// Procura um pin da MESMA categoria dentro do raio de junção.
  Future<QueryDocumentSnapshot?> _buscarPinParecido({
    required double lat,
    required double lng,
    required String categoria,
  }) async {
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
  /// registra o report como confirmação daquele pin.
  ///
  /// Retorna: { 'juntado': bool, 'pinId': String }
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

      // credibilidade — o criador conta como primeira confirmação
      'credibilidadeConfirma': peso,
      'credibilidadeContesta': 0.0,
      'totalConfirma': 1,
      'totalContesta': 0,
      'status': status,

      // verificação automática (1 confirmação ainda não basta)
      'verificado': false,
    });

    // registra o voto do criador
    await _db
        .collection('pins')
        .doc(pinId)
        .collection('votos')
        .doc(criadoPor)
        .set({
          'uid': criadoPor,
          'tipo': 'confirma',
          'peso': peso,
          'em': FieldValue.serverTimestamp(),
        });

    // contadores do usuário
    await _db.collection('usuarios').doc(criadoPor).set({
      'reports': FieldValue.increment(1),
      'confirmacoes': FieldValue.increment(1),
    }, SetOptions(merge: true));

    return {'juntado': false, 'pinId': pinId};
  }

  /// Registra, troca ou desfaz o voto de um usuário em um pin.
  /// tipo: 'confirma' | 'contesta'
  Future<void> votar({
    required String pinId,
    required String uid,
    required bool ehCadastrado,
    required String tipo,
  }) async {
    final pinRef = _db.collection('pins').doc(pinId);
    final votoRef = pinRef.collection('votos').doc(uid);
    final userRef = _db.collection('usuarios').doc(uid);
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

      // ─── Já votou antes? ───────────────────────────────────
      if (votoSnap.exists) {
        final anterior = votoSnap.data() as Map<String, dynamic>;
        final tipoAnterior = anterior['tipo'];
        final pesoAnterior = (anterior['peso'] ?? 0).toDouble();

        // Mesmo voto de novo → DESFAZ (toggle)
        if (tipoAnterior == tipo) {
          if (tipo == 'confirma') {
            confirma -= pesoAnterior;
            totalConfirma -= 1;
          } else {
            contesta -= pesoAnterior;
            totalContesta -= 1;
          }
          if (confirma < 0) confirma = 0;
          if (contesta < 0) contesta = 0;
          if (totalConfirma < 0) totalConfirma = 0;
          if (totalContesta < 0) totalContesta = 0;

          tx.delete(votoRef);
          tx.update(pinRef, {
            'credibilidadeConfirma': confirma,
            'credibilidadeContesta': contesta,
            'totalConfirma': totalConfirma,
            'totalContesta': totalContesta,
            'status': _calcularStatus(confirma, contesta),
            'verificado': _calcularVerificado(totalConfirma, totalContesta),
          });
          tx.set(userRef, {
            tipo == 'confirma' ? 'confirmacoes' : 'contestacoes':
                FieldValue.increment(-1),
          }, SetOptions(merge: true));
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

      // ─── Aplica o novo voto ────────────────────────────────
      if (tipo == 'confirma') {
        confirma += peso;
        totalConfirma += 1;
      } else {
        contesta += peso;
        totalContesta += 1;
      }

      if (confirma < 0) confirma = 0;
      if (contesta < 0) contesta = 0;
      if (totalConfirma < 0) totalConfirma = 0;
      if (totalContesta < 0) totalContesta = 0;

      tx.set(votoRef, {
        'uid': uid,
        'tipo': tipo,
        'peso': peso,
        'em': FieldValue.serverTimestamp(),
      });

      tx.update(pinRef, {
        'credibilidadeConfirma': confirma,
        'credibilidadeContesta': contesta,
        'totalConfirma': totalConfirma,
        'totalContesta': totalContesta,
        'status': _calcularStatus(confirma, contesta),
        'verificado': _calcularVerificado(totalConfirma, totalContesta),
      });

      // ─── Contadores do usuário ─────────────────────────────
      final Map<String, dynamic> deltas = {};
      if (votoSnap.exists) {
        final tipoAnterior = (votoSnap.data() as Map<String, dynamic>)['tipo'];
        if (tipoAnterior != tipo) {
          deltas[tipoAnterior == 'confirma' ? 'confirmacoes' : 'contestacoes'] =
              FieldValue.increment(-1);
        }
      }
      deltas[tipo == 'confirma' ? 'confirmacoes' : 'contestacoes'] =
          FieldValue.increment(1);

      tx.set(userRef, deltas, SetOptions(merge: true));
    });
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

  /// Estatísticas do usuário para a tela de perfil.
  /// Leitura direta de um documento — não precisa de índice.
  Future<Map<String, int>> estatisticasUsuario(String uid) async {
    final snap = await _db.collection('usuarios').doc(uid).get();
    final dados = snap.data() ?? {};
    return {
      'reports': (dados['reports'] ?? 0) as int,
      'confirmacoes': (dados['confirmacoes'] ?? 0) as int,
      'contestacoes': (dados['contestacoes'] ?? 0) as int,
    };
  }

  /// Stream dos pins visíveis no mapa (arquivados não aparecem).
  Stream<QuerySnapshot> streamPins() {
    return _db
        .collection('pins')
        .where('status', whereIn: [statusPendente, statusAtivo])
        .snapshots();
  }
}
