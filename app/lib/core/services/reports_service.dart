import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Gera um ID novo para o pin (usado também no caminho da foto no Storage).
  String gerarIdPin() => _db.collection('pins').doc().id;

  /// Cria um pin com um ID específico (sem credibilidade por enquanto).
  Future<void> criarPin({
    required String pinId,
    required double lat,
    required double lng,
    required String categoria,
    String? subcategoria,
    required String titulo,
    required String descricao,
    String? fotoUrl,
    required String criadoPor,
  }) async {
    await _db.collection('pins').doc(pinId).set({
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

  Stream<QuerySnapshot> streamPins() {
    return _db.collection('pins').snapshots();
  }
}
