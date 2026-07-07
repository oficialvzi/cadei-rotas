/// Chave da API do Google usada para chamadas HTTP à Places API (New).
/// Pode ser a mesma chave do Maps SDK, desde que a Places API esteja
/// habilitada e a chave não tenha restrição que bloqueie o Places.
class MapsConfig {
  static const String apiKey = 'AIzaSyDjrbxxsXk3z1qsp_6LCSCkPuussPDZhio';

  // Centro do Campus Darcy Ribeiro — usado para enviesar a busca
  static const double campusLat = -15.7633;
  static const double campusLng = -47.8702;
  static const double raioBuscaMetros = 4000; // 4 km ao redor do campus
}
