import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Upload de imagens via Firebase Storage.
/// Cada foto é salva em uma estrutura organizada por categoria/id.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Faz upload da foto de um report e retorna a URL pública de download.
  Future<String> uploadFotoReport({
    required String reportId,
    required String caminhoLocal,
  }) async {
    final arquivo = File(caminhoLocal);
    final ref = _storage.ref('reports/$reportId/foto.jpg');

    final tarefa = await ref.putFile(
      arquivo,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=86400', // cache de 1 dia
      ),
    );

    return await tarefa.ref.getDownloadURL();
  }

  /// Upload do avatar do usuário.
  Future<String> uploadAvatar({
    required String uid,
    required String caminhoLocal,
  }) async {
    final arquivo = File(caminhoLocal);
    final ref = _storage.ref('usuarios/$uid/avatar.jpg');

    final tarefa = await ref.putFile(
      arquivo,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await tarefa.ref.getDownloadURL();
  }

  /// Deleta uma foto (útil para limpar reports rejeitados).
  Future<void> deletarFoto(String urlOuCaminho) async {
    try {
      if (urlOuCaminho.startsWith('http')) {
        await _storage.refFromURL(urlOuCaminho).delete();
      } else {
        await _storage.ref(urlOuCaminho).delete();
      }
    } catch (_) {
      // foto pode já ter sido deletada — ignora
    }
  }
}
