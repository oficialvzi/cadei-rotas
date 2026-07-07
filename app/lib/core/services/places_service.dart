import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/maps_config.dart';

/// Resultado unificado da busca (lugar do Google).
class ResultadoLugar {
  final String placeId;
  final String nomePrincipal;
  final String nomeSecundario;

  ResultadoLugar({
    required this.placeId,
    required this.nomePrincipal,
    required this.nomeSecundario,
  });
}

class PlacesService {
  /// Autocomplete da Places API (New) — restringe ao redor do campus.
  Future<List<ResultadoLugar>> autocomplete(String texto) async {
    if (texto.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );

    final body = jsonEncode({
      'input': texto,
      'locationBias': {
        'circle': {
          'center': {
            'latitude': MapsConfig.campusLat,
            'longitude': MapsConfig.campusLng,
          },
          'radius': MapsConfig.raioBuscaMetros,
        },
      },
      'languageCode': 'pt-BR',
    });

    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': MapsConfig.apiKey,
        'X-Goog-FieldMask':
            'suggestions.placePrediction.placeId,'
            'suggestions.placePrediction.structuredFormat',
      },
      body: body,
    );

    if (resp.statusCode != 200) {
      // ignore: avoid_print
      print('Erro Places autocomplete: ${resp.statusCode} ${resp.body}');
      return [];
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final sugestoes = (data['suggestions'] as List?) ?? [];

    return sugestoes.map((s) {
      final pred = s['placePrediction'];
      final structured = pred['structuredFormat'];
      final main = structured?['mainText']?['text'] ?? '';
      final secondary = structured?['secondaryText']?['text'] ?? '';
      return ResultadoLugar(
        placeId: pred['placeId'],
        nomePrincipal: main,
        nomeSecundario: secondary,
      );
    }).toList();
  }

  /// Busca as coordenadas de um lugar pelo seu placeId.
  Future<Map<String, double>?> detalhesLocalizacao(String placeId) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

    final resp = await http.get(
      url,
      headers: {
        'X-Goog-Api-Key': MapsConfig.apiKey,
        'X-Goog-FieldMask': 'location',
      },
    );

    if (resp.statusCode != 200) {
      // ignore: avoid_print
      print('Erro Places details: ${resp.statusCode} ${resp.body}');
      return null;
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final loc = data['location'];
    if (loc == null) return null;

    return {
      'lat': (loc['latitude'] as num).toDouble(),
      'lng': (loc['longitude'] as num).toDouble(),
    };
  }
}
