import 'dart:ui';

/// Categorias dos pins e suas cores/hues.
class Categorias {
  static const acessivel = 'acessivel';
  static const parcial = 'parcial';
  static const bloqueio = 'bloqueio';

  /// Cor de cada categoria (para badges e detalhes)
  static const Map<String, Color> cores = {
    acessivel: Color(0xFF0E5FB5),
    parcial: Color(0xFFD85A30),
    bloqueio: Color(0xFFA32D2D),
  };

  /// Rótulo legível
  static const Map<String, String> rotulos = {
    acessivel: 'Local Acessível',
    parcial: 'Barreira Parcial',
    bloqueio: 'Bloqueio Total',
  };

  /// Hue do marcador do Google Maps por categoria
  static double hue(String categoria) {
    switch (categoria) {
      case acessivel:
        return 210.0; // azul (hueAzure)
      case parcial:
        return 30.0; // laranja (hueOrange)
      case bloqueio:
        return 0.0; // vermelho (hueRed)
      default:
        return 210.0;
    }
  }

  /// Subcategorias do tipo parcial (espelha o enum DificuldadeParcial
  /// da tela de report — NovoReportScreen)
  static const subParcial = [
    'cadeira_manual',
    'dificil_passagem',
    'passagem_estreita',
    'rampa_inclinada',
    'inclinacao_lateral',
    'piso_escorregadio',
    'fluxo_intenso',
    'superficie_irregular',
    'pequenos_desniveis',
    'requer_ajuda',
  ];

  static const subRotulos = {
    // parcial
    'cadeira_manual': 'Apenas Cadeiras Manuais',
    'dificil_passagem': 'Difícil Passagem',
    'passagem_estreita': 'Passagem Estreita',
    'rampa_inclinada': 'Rampa muito Inclinada',
    'inclinacao_lateral': 'Inclinação Lateral',
    'piso_escorregadio': 'Piso Escorregadio',
    'fluxo_intenso': 'Fluxo Intenso de Pessoas',
    'superficie_irregular': 'Superfície Irregular',
    'pequenos_desniveis': 'Pequenos Desníveis',
    'requer_ajuda': 'Requer Ajuda de outra pessoa',
    // bloqueio
    'escada_sem_alternativa': 'Escada sem alternativa',
    'passagem_bloqueada': 'Passagem bloqueada',
    'desnivel_intransponivel': 'Desnível intransponível',
    'porta_estreita': 'Porta muito estreita',
  };
}