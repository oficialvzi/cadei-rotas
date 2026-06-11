import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TelaDeInstrucoes extends StatefulWidget {
  const TelaDeInstrucoes({super.key});

  @override
  State<TelaDeInstrucoes> createState() => _TelaDeInstrucoesState();
}

class _TelaDeInstrucoesState extends State<TelaDeInstrucoes> {
  final PageController _controlador = PageController(); //rolagem da pagina

  int _paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(

          gradient: _paginaAtual == 0
              ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF4FF),
              Colors.white,
            ],
          )
              : null,
          //depois do slide 1, todos brancos
          color: _paginaAtual != 0 ? const Color(0xFFFFFFFF) : null,
        ),

        child: SafeArea(
          child: Column(
            children: [

              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                  },
                  child: const Text(
                    'Pular',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),

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

              //indicativo de pagina
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

              //botao de passar de pagina
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


//TELA1: BOAS VINDAS
  Widget _construirSlide1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/logo-icone-azul.svg',
            height: 280,
          ),

          const SizedBox(height: 20),

          const Text(
              'Bem-vindo ao\nCadei-Rotas',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0055A4)
              )
          ),

          const SizedBox(height: 15),

          const Text(
              'Um app feito para\ntornar a UnB mais acessível',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF666666)
              )
          ),

          const SizedBox(height: 30),

          //itens tela inicial
          _itemLista(Colors.blue, 'Mapeie rampas e elevadores'),
          _itemLista(Colors.orange, 'Reporte barreiras arquitetônicas'),
          _itemLista(Colors.green, 'Ajude a comunidade UnB'),
        ],
      ),
    );
  }

  //TELA 2: PINS
  Widget _construirSlide2() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/mapa-pins-TelaInstrucao.png',
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 35),

            const Text(
                'Cores dos pins',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333)
                )
            ),

            const SizedBox(height: 10),

            const Text(
                'Veja a acessibilidade em um piscar',
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF666666)
                )
            ),

            const SizedBox(height: 35),

            //itens em baixo da tela
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/mapa-report-TelaInstrucao.png',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
              'Encontrou um obstáculo?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)
              )
          ),

          const SizedBox(height: 8),

          const Text(
              'Reporte em 4 passos simples',
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF666666)
              )
          ),

          const SizedBox(height: 25),

          _passoNumerado('1', 'Toque no botão laranja', 'no canto inferior da tela'),
          _passoNumerado('2', 'Escolha a severidade', 'parcial ou total'),
          _passoNumerado('3', 'Adicione título e foto', 'câmera ou galeria'),
          _passoNumerado('4', 'Marque no mapa', 'com um único toque'),
        ],
      ),
    );
  }

//TELA 4: COMUNIDADE
  Widget _construirSlide4() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/comunidade-TelaInstrucao.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
              'Juntos somos mais fortes',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)
              )
          ),

          const SizedBox(height: 8),

          const Text(
              'Sua contribuição transforma o campus',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF666666)
              )
          ),

          const SizedBox(height: 25),

          _caixaComunidade(const Color(0xFFE8F5E9), Icons.check_circle, const Color(0xFF2E7D32), 'Confirme reports válidos', 'A barreira ainda existe?'),
          _caixaComunidade(const Color(0xFFFFF3E0), Icons.cancel, const Color(0xFFEF6C00), 'Conteste se já foi resolvido', 'A passagem está livre agora?'),
          _caixaComunidade(const Color(0xFFF3E5F5), Icons.smart_toy, const Color(0xFF6A1B9A), 'Validação automática', 'IA verifica cada foto enviada'),
        ],
      ),
    );
  }

  //widget de cada tela
  Widget _itemLista(Color cor, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 16, color: cor),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF333333),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 40, color: corIcone),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)
                    )
                ),
                const SizedBox(height: 4),
                Text(
                    subtitulo,
                    style: const TextStyle(
                        fontSize: 15,
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
                    fontSize: 18
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)
                    )
                ),
                const SizedBox(height: 2),
                Text(
                    subtitulo,
                    style: const TextStyle(
                        fontSize: 15,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)
                    )
                ),
                const SizedBox(height: 4),
                Text(
                    subtitulo,
                    style: const TextStyle(
                        fontSize: 15,
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