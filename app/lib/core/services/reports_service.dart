import 'package:cloud_firestore/cloud_firestore.dart';


class ReportsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Cria um pin diretamente na coleção 'pins' (sem credibilidade por enquanto).
  Future<void> criarPin({
    required double lat,
    required double lng,
    required String categoria, // 'acessivel' | 'parcial' | 'bloqueio'
    String? subcategoria,
    required String titulo,
    required String descricao,
    String? fotoUrl,
    required String criadoPor, // uid do usuário (ou 'anonimo')
  }) async {
    await _db.collection('pins').add({
      'localizacao': GeoPoint(lat, lng),
      'categoria': categoria,
      'subcategoria': subcategoria,
      'titulo': titulo,
      'descricao': descricao,
      'fotoUrl': fotoUrl,
      'totalReports': 1,
      'criadoPor': criadoPor,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Stream em tempo real de todos os pins (para o mapa).
  Stream<QuerySnapshot> streamPins() {
    return _db.collection('pins').snapshots();
  }
}
