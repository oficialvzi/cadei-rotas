import 'package:flutter/material.dart';
import 'package:cadeirotas_app/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── PALETA DO APP ────────────── Designer pode alterar por aqui
const Color kAzul = Color(0xFF1A5CB8);
const Color kAzulEscuro = Color(0xFF0D3D7A);
const Color kLaranja = Color(0xFFE65100);
const Color kVermelho = Color(0xFFC62828);
const Color kFundo = Color(0xFFF4F6FA);
const Color kBranco = Colors.white;
const Color kTexto = Color(0xFF1A1A2E);
const Color kSubtexto = Color(0xFF6B7280);
const Color kBorda = Color(0xFFD1D9E6);


// ═════════════════════════════════════════════════════════════════════════════
//  TELA DE LOGIN
// ═════════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _senhaVisivel = false;
  bool _carregando = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  void _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await AuthService().entrarComEmail(
        _emailCtrl.text.trim(),
        _senhaCtrl.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/splash');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mensagemErro(e.code)),
            backgroundColor: kVermelho,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String _mensagemErro(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Usuário desativado.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde.';
      default:
        return 'Erro ao entrar. Tente novamente.';
    }
  }

  void _esqueceuSenha() {
    showDialog(
      context: context,
      builder: (_) => const _EsqueceuSenhaDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFundo,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // ── Logo ──
                _Logo(),
                const SizedBox(height: 40),
                // ── Card ──
                _Card(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _CardTitle('Bem-vindo de volta'),
                        const SizedBox(height: 4),
                        const _CardSubtitle('Faça login para continuar'),
                        const SizedBox(height: 28),
                        _CampoEmail(controller: _emailCtrl),
                        const SizedBox(height: 16),
                        _CampoSenha(
                          controller: _senhaCtrl,
                          visivel: _senhaVisivel,
                          onToggle: () =>
                              setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _esqueceuSenha,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(
                                color: kAzul,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _BotaoPrimario(
                          rotulo: 'Entrar',
                          carregando: _carregando,
                          onPressed: _entrar,
                        ),
                        const SizedBox(height: 20),
                        _Divisor(),
                        const SizedBox(height: 20),
                        _BotaoGoogle(
                          onPressed: () async {
                            setState(() => _carregando = true);
                            try {
                              final user = await AuthService()
                                  .entrarComGoogle();
                              if (user != null && mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/splash',
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Erro ao entrar com Google. Tente novamente.',
                                    ),
                                    backgroundColor: kVermelho,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _carregando = false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // ── Rodapé ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(color: kSubtexto, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/cadastro'),
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: kAzul,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── DIALOG ESQUECEU SENHA ────────────────────────────────────────────────────
class _EsqueceuSenhaDialog extends StatefulWidget {
  const _EsqueceuSenhaDialog();
  @override
  State<_EsqueceuSenhaDialog> createState() => _EsqueceuSenhaDialogState();
}

class _EsqueceuSenhaDialogState extends State<_EsqueceuSenhaDialog> {
  final _ctrl = TextEditingController();
  bool _enviado = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Recuperar senha',
        style: TextStyle(
            color: kTexto, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: _enviado
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mark_email_read_outlined, color: kAzul, size: 48),
                SizedBox(height: 12),
                Text(
                  'E-mail enviado! Verifique sua caixa de entrada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kSubtexto),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Informe seu e-mail e enviaremos um link para redefinir sua senha.',
                  style: TextStyle(color: kSubtexto, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _CampoEmail(controller: _ctrl),
              ],
            ),
      actions: _enviado
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar',
                    style: TextStyle(color: kAzul, fontWeight: FontWeight.w600)),
              )
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: kSubtexto)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAzul,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  try {
                    await AuthService().enviarEmailReset(_ctrl.text.trim());
                  } catch (_) {
                    // mesmo em caso de erro não revelamos se o email existe
                  } finally {
                    if (mounted) setState(() => _enviado = true);
                  }
                },
                child: const Text('Enviar',
                    style: TextStyle(color: kBranco, fontWeight: FontWeight.w600)),
              ),
            ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TELA DE CADASTRO
// ═════════════════════════════════════════════════════════════════════════════
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _repetirCtrl = TextEditingController();
  bool _senhaVisivel = false;
  bool _repetirVisivel = false;
  bool _carregando = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _repetirCtrl.dispose();
    super.dispose();
  }

  void _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await AuthService().cadastrarComEmail(
        _emailCtrl.text.trim(),
        _senhaCtrl.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/splash');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mensagemErroCadastro(e.code)),
            backgroundColor: kVermelho,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String _mensagemErroCadastro(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      default:
        return 'Erro ao criar conta. Tente novamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFundo,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _Logo(),
                const SizedBox(height: 40),
                _Card(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _CardTitle('Criar conta'),
                        const SizedBox(height: 4),
                        const _CardSubtitle(
                            'Junte-se ao Cadei-Rotas e ajude a mapear a acessibilidade'),
                        const SizedBox(height: 28),
                        _CampoEmail(controller: _emailCtrl),
                        const SizedBox(height: 16),
                        _CampoSenha(
                          controller: _senhaCtrl,
                          label: 'Senha',
                          visivel: _senhaVisivel,
                          onToggle: () =>
                              setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                        const SizedBox(height: 16),
                        _CampoSenha(
                          controller: _repetirCtrl,
                          label: 'Repetir senha',
                          hint: 'Confirme sua senha',
                          visivel: _repetirVisivel,
                          onToggle: () =>
                              setState(() => _repetirVisivel = !_repetirVisivel),
                          validador: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Confirme sua senha';
                            }
                            if (v != _senhaCtrl.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 26),
                        _BotaoPrimario(
                          rotulo: 'Criar conta',
                          carregando: _carregando,
                          onPressed: _cadastrar,
                        ),
                        const SizedBox(height: 20),
                        _Divisor(),
                        const SizedBox(height: 20),
                        _BotaoGoogle(
                          onPressed: () async {
                            setState(() => _carregando = true);
                            try {
                              final user = await AuthService()
                                  .entrarComGoogle();
                              if (user != null && mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/splash',
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Erro ao entrar com Google. Tente novamente.',
                                    ),
                                    backgroundColor: kVermelho,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _carregando = false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta? ',
                      style: TextStyle(color: kSubtexto, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        'Ir para Login',
                        style: TextStyle(
                          color: kAzul,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  WIDGETS COMPARTILHADOS
// ═════════════════════════════════════════════════════════════════════════════

// ── Logo do App ──────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: kAzul,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kAzul.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.wheelchair_pickup, color: kBranco, size: 36),
        ),
        const SizedBox(height: 14),
        const Text(
          'Cadei-Rotas',
          style: TextStyle(
            color: kAzulEscuro,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'ACESSIBILIDADE EM ROTA',
          style: TextStyle(
            color: kSubtexto,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

// ── Card Container ────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kBranco,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kAzul.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Título e subtítulo do card ─────────────────────────────────────────────────
class _CardTitle extends StatelessWidget {
  final String texto;
  const _CardTitle(this.texto);
  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(
          color: kTexto,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      );
}

class _CardSubtitle extends StatelessWidget {
  final String texto;
  const _CardSubtitle(this.texto);
  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(color: kSubtexto, fontSize: 13, height: 1.4),
      );
}

// ── Campo de Email ─────────────────────────────────────────────────────────────
class _CampoEmail extends StatelessWidget {
  final TextEditingController controller;
  const _CampoEmail({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: kTexto, fontSize: 14),
      decoration: _inputDecoration(
        label: 'E-mail',
        hint: 'seu@email.com',
        icone: Icons.mail_outline_rounded,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Informe seu e-mail';
        if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v)) {
          return 'E-mail inválido';
        }
        return null;
      },
    );
  }
}

// ── Campo de Senha ─────────────────────────────────────────────────────────────
class _CampoSenha extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool visivel;
  final VoidCallback onToggle;
  final String? Function(String?)? validador;

  const _CampoSenha({
    required this.controller,
    this.label = 'Senha',
    this.hint = 'Sua senha',
    required this.visivel,
    required this.onToggle,
    this.validador,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visivel,
      style: const TextStyle(color: kTexto, fontSize: 14),
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icone: Icons.lock_outline_rounded,
        sufixo: IconButton(
          icon: Icon(
            visivel
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: kSubtexto,
            size: 20,
          ),
          onPressed: onToggle,
          splashRadius: 18,
        ),
      ),
      validator: validador ??
          (v) {
            if (v == null || v.isEmpty) return 'Informe sua senha';
            if (v.length < 6) return 'Mínimo de 6 caracteres';
            return null;
          },
    );
  }
}

// ── Decoração padrão dos inputs ───────────────────────────────────────────────
InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required IconData icone,
  Widget? sufixo,
}) {
  const radius = BorderRadius.all(Radius.circular(12));
  const borderColor = kBorda;
  const focusColor = kAzul;

  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: const TextStyle(color: kBorda, fontSize: 13),
    labelStyle: const TextStyle(color: kSubtexto, fontSize: 13),
    prefixIcon: Icon(icone, color: kSubtexto, size: 20),
    suffixIcon: sufixo,
    filled: true,
    fillColor: const Color(0xFFF8FAFF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: borderColor)),
    enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: borderColor)),
    focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: focusColor, width: 1.8)),
    errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: kVermelho)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: kVermelho, width: 1.8)),
  );
}

// ── Botão Primário ─────────────────────────────────────────────────────────────
class _BotaoPrimario extends StatelessWidget {
  final String rotulo;
  final bool carregando;
  final VoidCallback onPressed;

  const _BotaoPrimario({
    required this.rotulo,
    required this.carregando,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kAzul,
          foregroundColor: kBranco,
          disabledBackgroundColor: kAzul.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: carregando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: kBranco,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                rotulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

// ── Divisor "ou" ──────────────────────────────────────────────────────────────
class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: kBorda, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(
              color: kSubtexto.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: kBorda, thickness: 1)),
      ],
    );
  }
}

// ── Botão Google ──────────────────────────────────────────────────────────────
class _BotaoGoogle extends StatelessWidget {
  final VoidCallback onPressed;
  const _BotaoGoogle({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kBorda, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: kBranco,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone G estilizado
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CustomPaint(painter: _GoogleIconPainter()),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continuar com Google',
              style: TextStyle(
                color: kTexto,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ícone G do Google desenhado via Canvas ─────────────────────────────────────
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Azul
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.57, 3.14, true,
      Paint()..color = const Color(0xFF4285F4),
    );
    // Vermelho
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.57, 1.57, true,
      Paint()..color = const Color(0xFFEA4335),
    );
    // Amarelo
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.14, 0.79, true,
      Paint()..color = const Color(0xFFFBBC05),
    );
    // Verde
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.93, 0.79, true,
      Paint()..color = const Color(0xFF34A853),
    );
    // Centro branco
    canvas.drawCircle(
      Offset(cx, cy), r * 0.55,
      Paint()..color = Colors.white,
    );
    // Barra horizontal branca
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.15, r, r * 0.3),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}