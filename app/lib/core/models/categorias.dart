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

  /// Subcategorias do tipo parcial
  static const subParcial = [
    'rampa_inclinacao_irregular',
    'cadeira_manual',
    'cadeira_eletrica',
    'piso_irregular',
    'obstaculo_contornavel',
  ];

  /// Subcategorias do tipo bloqueio
  static const subBloqueio = [
    'escada_sem_alternativa',
    'passagem_bloqueada',
    'desnivel_intransponivel',
    'porta_estreita',
  ];

  static const subRotulos = {
    'rampa_inclinacao_irregular': 'Rampa com inclinação fora da norma',
    'cadeira_manual': 'Não passa cadeira manual',
    'cadeira_eletrica': 'Não passa cadeira elétrica',
    'piso_irregular': 'Piso irregular',
    'obstaculo_contornavel': 'Obstáculo contornável',
    'escada_sem_alternativa': 'Escada sem alternativa',
    'passagem_bloqueada': 'Passagem bloqueada',
    'desnivel_intransponivel': 'Desnível intransponível',
    'porta_estreita': 'Porta muito estreita',
  };
}
