import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


void main() {
  runApp(const ReportScreen());
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novo Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const NovoReportScreen(),
    );
  }
}

enum SeveridadeBarreira { nenhuma, total, parcial }

enum DificuldadeParcial { nenhuma, apenasManual, dificilPassagem }

class NovoReportScreen extends StatefulWidget {
  const NovoReportScreen({super.key});

  @override
  State<NovoReportScreen> createState() => _NovoReportScreenState();
}

class _NovoReportScreenState extends State<NovoReportScreen> {
  SeveridadeBarreira _severidade = SeveridadeBarreira.nenhuma;
  DificuldadeParcial _dificuldade = DificuldadeParcial.nenhuma;
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  File? _fotoSelecionada;
  final ImagePicker _picker = ImagePicker();

  static const Color _vermelho = Color(0xFFD32F2F);
  static const Color _laranja = Color(0xFFE65100);
  static const Color _verde = Color(0xFF2E7D32);
  static const Color _cinzaFundo = Color(0xFFF5F5F5);
  static const Color _cinzaBorda = Color(0xFFBDBDBD);
  static const Color _textoPrimario = Color(0xFF212121);
  static const Color _textoSecundario = Color(0xFF757575);

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _abrirCamera() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (foto != null) {
        setState(() => _fotoSelecionada = File(foto.path));
      }
    } catch (e) {
      _mostrarErro('Não foi possível abrir a câmera: $e');
    }
  }

  Future<void> _abrirGaleria() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (foto != null) {
        setState(() => _fotoSelecionada = File(foto.path));
      }
    } catch (e) {
      _mostrarErro('Não foi possível abrir a galeria: $e');
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: _vermelho,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmar() {
    if (_severidade == SeveridadeBarreira.nenhuma) {
      _mostrarErro('Selecione a severidade da barreira.');
      return;
    }
    if (_severidade == SeveridadeBarreira.parcial &&
        _dificuldade == DificuldadeParcial.nenhuma) {
      _mostrarErro('Selecione o tipo de dificuldade.');
      return;
    }
    if (_tituloController.text.trim().isEmpty) {
      _mostrarErro('Informe o título.');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report enviado com sucesso!'),
        backgroundColor: _verde,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecaoLabel('SEVERIDADE DA BARREIRA'),
            const SizedBox(height: 10),

            // PIN VERMELHO em cima (conforme solicitado)
            _buildOpcaoSeveridade(
              valor: SeveridadeBarreira.total,
              titulo: 'Totalmente inacessível',
              subtitulo: 'Passagem bloqueada',
              cor: _vermelho,
            ),
            const SizedBox(height: 10),

            // PIN LARANJA embaixo
            _buildOpcaoSeveridade(
              valor: SeveridadeBarreira.parcial,
              titulo: 'Parcialmente inacessível',
              subtitulo: 'Passa, mas com dificuldade',
              cor: _laranja,
            ),

            // Campo extra animado para opção parcial
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _severidade == SeveridadeBarreira.parcial
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildCampoDificuldade(),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),
            _buildSecaoLabel('TÍTULO'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _tituloController,
              hint: 'Escada sem rampa',
              maxLines: 1,
            ),

            const SizedBox(height: 20),
            _buildSecaoLabel('DESCRIÇÃO'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descricaoController,
              hint:
                  'Entrada lateral do bloco\nsó tem 4 degraus, sem\nrampa alternativa.',
              maxLines: 4,
            ),

            const SizedBox(height: 20),
            _buildSecaoLabel('FOTO'),
            const SizedBox(height: 10),
            _buildSeletorFoto(),

          if (_fotoSelecionada != null) ...[
              const SizedBox(height: 12),
              _buildPreviewFoto(),
            ],

            const SizedBox(height: 32),
            _buildBotoes(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: TextButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text(
          '← Voltar',
          style: TextStyle(
            color: _verde,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      leadingWidth: 100,
      title: const Text(
        'Novo Report',
        style: TextStyle(
          color: _textoPrimario,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSecaoLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _textoSecundario,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildOpcaoSeveridade({
    required SeveridadeBarreira valor,
    required String titulo,
    required String subtitulo,
    required Color cor,
  }) {
    final bool selecionado = _severidade == valor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _severidade = valor;
          if (valor != SeveridadeBarreira.parcial) {
            _dificuldade = DificuldadeParcial.nenhuma;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selecionado ? cor.withOpacity(0.06) : Colors.white,
          border: Border.all(
            color: selecionado ? cor : _cinzaBorda,
            width: selecionado ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selecionado ? cor : _cinzaBorda,
                  width: 2,
                ),
              ),
              child: selecionado
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selecionado ? cor : _textoPrimario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: selecionado
                        ? cor.withOpacity(0.8)
                        : _textoSecundario,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoDificuldade() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _laranja.withOpacity(0.05),
        border: Border.all(color: _laranja.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TIPO DE DIFICULDADE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _laranja,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildOpcaoDificuldade(
            valor: DificuldadeParcial.apenasManual,
            label: 'Apenas Cadeiras Manuais',
          ),
          const SizedBox(height: 10),
          _buildOpcaoDificuldade(
            valor: DificuldadeParcial.dificilPassagem,
            label: 'Difícil Passagem',
          ),
        ],
      ),
    );
  }

  Widget _buildOpcaoDificuldade({
    required DificuldadeParcial valor,
    required String label,
  }) {
    final bool selecionado = _dificuldade == valor;
    return GestureDetector(
      onTap: () => setState(() => _dificuldade = valor),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selecionado ? _laranja : _cinzaBorda,
                width: 2,
              ),
              color: Colors.transparent,
            ),
            child: selecionado
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _laranja,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  selecionado ? FontWeight.w600 : FontWeight.normal,
              color: selecionado ? _laranja : _textoPrimario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: _textoPrimario),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textoSecundario, fontSize: 14),
        filled: true,
        fillColor: _cinzaFundo,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _cinzaBorda, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _cinzaBorda, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _verde, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSeletorFoto() {
    return Row(
      children: [
        _buildBotaoFoto(
          icone: Icons.camera_alt_outlined,
          label: 'Câmera',
          destaque: true,
          onTap: _abrirCamera,
          cor: _verde,
        ),
        const SizedBox(width: 12),
        _buildBotaoFoto(
          icone: Icons.photo_outlined,
          label: 'Galeria',
          destaque: false,
          onTap: _abrirGaleria,
          cor: _textoSecundario,
        ),
      ],
    );
  }

  Widget _buildBotaoFoto({
    required IconData icone,
    required String label,
    required bool destaque,
    required VoidCallback onTap,
    required Color cor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 80,
        decoration: BoxDecoration(
          color: destaque ? cor.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color: destaque ? cor : _cinzaBorda,
            width: destaque ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: cor, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cor,
                fontWeight:
                    destaque ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewFoto() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            _fotoSelecionada!,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _fotoSelecionada = null),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotoes() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: _cinzaBorda, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 15,
                color: _textoPrimario,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmar,
            style: ElevatedButton.styleFrom(
              backgroundColor: _verde,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}