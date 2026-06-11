import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TelaDeInstrucoes extends StatefulWidget {
  const TelaDeInstrucoes({super.key});

  @override
  State<TelaDeInstrucoes> createState() => _TelaDeInstrucoesState();
}

class _TelaDeInstrucoesState extends State<TelaDeInstrucoes> {
  // O controlador que "vira" as páginas do nosso carrossel
  final PageController _controlador = PageController();

  // Variável para guardar qual página estamos olhando agora (começa no 0)
  int _paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tiramos a cor fixa daqui para que o fundo dinâmico funcione
      backgroundColor: Colors.transparent,

      // Envolvemos a tela inteira neste Container que controla o papel de parede
      body: Container(
        decoration: BoxDecoration(
          // ==========================================
          // A LÓGICA DO GRADIENTE
          // ==========================================
          gradient: _paginaAtual == 0
              ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF4FF), // Azul super claro no topo
              Colors.white,      // Desvanece para branco na parte inferior
            ],
          )
              : null, // Desliga o gradiente se não estiver no Slide 1

          // Se não estiver no Slide 1, aplica a cor bege padrão
          color: _paginaAtual != 0 ? const Color(0xFFEAF4FF) : null,
        ),

        child: SafeArea(
          child: Column(
            children: [
              // ==========================================
              // 1. CABEÇALHO (Botão Pular)
              // ==========================================
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    // Lógica de pular
                  },
                  child: const Text(
                    'Pular',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),

              // ==========================================
              // 2. O PROJETOR DE SLIDES (PageView)
              // ==========================================
              Expanded(
                child: PageView(
                  controller: _controlador,
                  onPageChanged: (index) {
                    setState(() {
                      _paginaAtual = index;
                    });
                  },
                  children: [
                    _construirSlide1(),
                    _construirSlide2(),
                    _construirSlide3(),
                    _construirSlide4(),
                  ],
                ),
              ),

              // ==========================================
              // 3. INDICADOR DE PÁGINAS (As bolinhas)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _paginaAtual == index
                          ? (_paginaAtual == 3 ? Colors.green : const Color(0xFF0055A4))
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 4. BOTÃO PRINCIPAL INFERIOR
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _paginaAtual == 3 ? Colors.green : const Color(0xFF0055A4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      if (_paginaAtual < 3) {
                        _controlador.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // Ação do último slide
                      }
                    },
                    child: Text(
                      _paginaAtual == 3 ? 'Começar' : 'Próximo',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // ABAIXO ESTÃO OS BLOCOS INDEPENDENTES DE CADA SLIDE
  // =========================================================================

// --- SLIDE 1: BOAS-VINDAS ---
  Widget _construirSlide1() {
    return Padding(
      // Mantemos o padding lateral de 20.0
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/logo-icone-azul.svg',
            height: 280, // Mantemos o logo imponente
          ),

          // === AJUSTES DE ESPAÇAMENTO AQUI ===
          const SizedBox(height: 20), // Antes era 35

          const Text(
              'Bem-vindo ao\nCadei-Rotas',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0055A4)
              )
          ),

          const SizedBox(height: 15), // Antes era 20

          const Text(
              'Um app feito para\ntornar a UnB mais acessível',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF666666)
              )
          ),

          const SizedBox(height: 30), // Antes era 45
          // ===================================

          // Lista de itens (Manteremos o tamanho 20 para o texto)
          _itemLista(Colors.blue, 'Mapeie rampas e elevadores'),
          _itemLista(Colors.orange, 'Reporte barreiras arquitetônicas'),
          _itemLista(Colors.green, 'Ajude a comunidade UnB'),
        ],
      ),
    );
  }

  // --- SLIDE 2: CORES DOS PINS ---
  Widget _construirSlide2() {
    // Adicionamos a rolagem por segurança, igual no Slide 1
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simula a sua imagem do mapa (Bem maior agora)
            Container(
              height: 240, // <--- Aumentado de 150 para 240
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color(0xFFE2EAD3), // Ajustei a cor para ficar mais parecida com o fundo do seu mapa
                  borderRadius: BorderRadius.circular(20) // Bordas mais arredondadas
              ),
              child: const Icon(Icons.map, size: 100, color: Colors.white),
            ),

            const SizedBox(height: 35),

            const Text(
                'Cores dos pins',
                style: TextStyle(
                    fontSize: 32, // <--- Título muito maior
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333) // Cinza chumbo escuro
                )
            ),

            const SizedBox(height: 10),

            const Text(
                'Veja a acessibilidade em um piscar',
                style: TextStyle(
                    fontSize: 20, // <--- Subtítulo maior
                    color: Color(0xFF666666) // Cinza médio
                )
            ),

            const SizedBox(height: 35),

            // Caixas arredondadas coloridas (Elas vão crescer junto com a miniferramenta abaixo)
            // As cores dos fundos foram ajustadas para os tons pasteis mais próximos do mockup
            _caixaPin(const Color(0xFFE8F2FB), const Color(0xFF0055A4), 'Acessível', 'Rampa, elevador, banheiro PCD'),
            _caixaPin(const Color(0xFFFDEFE8), const Color(0xFFD65C2B), 'Parcialmente inacessível', 'Passa, mas com dificuldade'),
            _caixaPin(const Color(0xFFFBEBEB), const Color(0xFFA62A2A), 'Totalmente inacessível', 'Passagem bloqueada'),
          ],
        ),
      ),
    );
  }

  // --- SLIDE 3: COMO REPORTAR ---
  Widget _construirSlide3() {
    return Padding(
      // Removida a rolagem. Tela fixa novamente.
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder da imagem levemente achatado para salvar espaço
          Container(
            height: 180, // <--- Reduzido para caber os 4 passos grandes embaixo
            width: double.infinity,
            decoration: BoxDecoration(
                color: const Color(0xFFFDEFE8),
                borderRadius: BorderRadius.circular(20)
            ),
            child: const Icon(Icons.add_circle, size: 80, color: Colors.deepOrange),
          ),

          const SizedBox(height: 25), // Espaço reduzido

          const Text(
              'Encontrou um obstáculo?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30, // Mantido bem grande
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)
              )
          ),

          const SizedBox(height: 8), // Espaço reduzido

          const Text(
              'Reporte em 4 passos simples',
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF666666)
              )
          ),

          const SizedBox(height: 25), // Espaço reduzido

          // Passos numerados
          _passoNumerado('1', 'Toque no botão laranja', 'no canto inferior da tela'),
          _passoNumerado('2', 'Escolha a severidade', 'parcial ou total'),
          _passoNumerado('3', 'Adicione título e foto', 'câmera ou galeria'),
          _passoNumerado('4', 'Marque no mapa', 'com um único toque'),
        ],
      ),
    );
  }

// --- SLIDE 4: COMUNIDADE ---
  Widget _construirSlide4() {
    return Padding(
      // Tela fixa novamente, sem rolagem
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Retângulo ilustrativo achatado para não "empurrar" o resto para fora da tela
          Container(
            height: 160, // <--- Reduzido para caber as 3 caixas embaixo
            width: double.infinity,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20)
            ),
            child: const Icon(Icons.people, size: 70, color: Colors.teal),
          ),

          const SizedBox(height: 25), // Espaço reduzido

          const Text(
              'Juntos somos mais fortes',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30, // Mantido grande
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)
              )
          ),

          const SizedBox(height: 8), // Espaço reduzido

          const Text(
              'Sua contribuição transforma o campus',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18, // Ajuste sutil
                  color: Color(0xFF666666)
              )
          ),

          const SizedBox(height: 25), // Espaço reduzido

          // Caixas de comunidade
          _caixaComunidade(const Color(0xFFE8F5E9), Icons.check_circle, const Color(0xFF2E7D32), 'Confirme reports válidos', 'A barreira ainda existe?'),
          _caixaComunidade(const Color(0xFFFFF3E0), Icons.cancel, const Color(0xFFEF6C00), 'Conteste se já foi resolvido', 'A passagem está livre agora?'),
          _caixaComunidade(const Color(0xFFF3E5F5), Icons.smart_toy, const Color(0xFF6A1B9A), 'Validação automática', 'IA verifica cada foto enviada'),
        ],
      ),
    );
  }

  // =========================================================================
  // MINIFERRAMENTAS (Widgets auxiliares para não repetir código)
  // =========================================================================

  Widget _itemLista(Color cor, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Aumentei o espaçamento entre as linhas
      child: Row(
        children: [
          Icon(Icons.circle, size: 16, color: cor), // <--- Bolinhas maiores
          const SizedBox(width: 15),
          Expanded(
            child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 20, // <--- Texto da lista maior
                  color: Color(0xFF333333), // <--- Cinza chumbo profundo, igual ao mockup
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _caixaPin(Color corFundo, Color corIcone, String titulo, String subtitulo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      // Aumentei o padding interno para a caixa ficar mais "gordinha"
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(15) // Borda mais suave
      ),
      child: Row(
        children: [
          // Ícone do Pin maior
          Icon(Icons.location_on, size: 40, color: corIcone),
          const SizedBox(width: 20), // Mais espaço entre o pin e o texto
          Expanded( // Garante que textos longos não quebrem a tela
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 18, // <--- Título da caixa maior
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)
                    )
                ),
                const SizedBox(height: 4), // Pequeno espaço entre o título e o subtítulo
                Text(
                    subtitulo,
                    style: const TextStyle(
                        fontSize: 15, // <--- Subtítulo da caixa maior
                        color: Color(0xFF666666)
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passoNumerado(String numero, String titulo, String subtitulo) {
    return Padding(
      // O vertical foi de 12.0 para 8.0 (economizando espaço sem amassar o layout)
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF0055A4),
            child: Text(
                numero,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18 // Número grande
                )
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 18, // Título grande
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)
                    )
                ),
                const SizedBox(height: 2), // Diminuído de 4 para 2
                Text(
                    subtitulo,
                    style: const TextStyle(
                        fontSize: 15, // Subtítulo grande
                        color: Color(0xFF666666)
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _caixaComunidade(Color corFundo, IconData icone, Color corIcone, String titulo, String subtitulo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          Icon(icone, size: 40, color: corIcone),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 18, // Título maior
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)
                    )
                ),
                const SizedBox(height: 4),
                Text(
                    subtitulo,
                    style: const TextStyle(
                        fontSize: 15, // Subtítulo maior
                        color: Color(0xFF666666)
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}