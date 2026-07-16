import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cadeirotas_app/core/services/auth_service.dart';
import 'package:cadeirotas_app/core/services/reports_service.dart';
import 'package:cadeirotas_app/screens/instruction_slides.dart';

class TelaDePerfil extends StatelessWidget {
  const TelaDePerfil({super.key});

  // Link do repositório do projeto
  static const String _githubUrl = 'https://github.com/oficialvzi/cadei-rotas';
  static const String _githubIssuesUrl =
      'https://github.com/oficialvzi/cadei-rotas/issues';

  // Integrantes da equipe (ordem alfabética)
  static const List<String> _equipe = [
    'Arthur Choi Braga',
    'Eduardo Flor Ocampo',
    'Matheus Cunha de Freitas',
    'Ruan Dias Alves Teixeira',
    'Yago de Oliveira Araújo',
  ];

  Future<void> _abrirUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? usuario = FirebaseAuth.instance.currentUser;

    // Considera "visitante" se não há usuário OU se é anônimo
    final bool ehVisitante = usuario == null || usuario.isAnonymous;

    final String nome = ehVisitante
        ? 'Visitante'
        : (usuario.displayName ??
              (usuario.email != null
                  ? usuario.email!.split('@').first
                  : 'Usuário'));
    final String email = ehVisitante
        ? 'Você não está logado'
        : (usuario.email ?? 'Sem e-mail');
    final String? fotoUrl = ehVisitante ? null : usuario.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F1),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF003366),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/mapa');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // CAIXA AZUL DO TOPO
            Container(
              width: double.infinity,
              color: const Color(0xFF003366),
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                        ),
                        tooltip: 'Instruções',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TelaDeInstrucoes(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: fotoUrl != null
                        ? NetworkImage(fotoUrl)
                        : null,
                    child: fotoUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARTÃO DE ESTATÍSTICAS (dados reais do Firestore)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: FutureBuilder<Map<String, int>>(
                  future: usuario != null
                      ? ReportsService().estatisticasUsuario(usuario.uid)
                      : Future.value({
                          'reports': 0,
                          'confirmacoes': 0,
                          'contestacoes': 0,
                        }),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 50,
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final dados =
                        snap.data ??
                        {'reports': 0, 'confirmacoes': 0, 'contestacoes': 0};

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _estatistica(
                          '${dados['reports']}',
                          'REPORTS',
                          Colors.blue,
                        ),
                        Container(
                            height: 40, width: 2, color: Colors.grey[300]),
                        _estatistica(
                          '${dados['confirmacoes']}',
                          'CONFIRMAÇÕES',
                          Colors.green,
                        ),
                        Container(
                            height: 40, width: 2, color: Colors.grey[300]),
                        _estatistica(
                          '${dados['contestacoes']}',
                          'CONTESTAÇÕES',
                          Colors.redAccent,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ─── SEÇÃO: LINKS ÚTEIS ───────────────────────────────
            _tituloSecao('LINKS ÚTEIS'),
            const SizedBox(height: 10),

            _cartaoLink(
              context: context,
              icone: Icons.code,
              corIcone: const Color(0xFF0E5FB5),
              corFundo: Colors.blue[50]!,
              titulo: 'Sobre o projeto',
              subtitulo: 'Ver o repositório no GitHub',
              onTap: () => _abrirUrl(context, _githubUrl),
            ),

            _cartaoLink(
              context: context,
              icone: Icons.bug_report_outlined,
              corIcone: const Color(0xFFD85A30),
              corFundo: Colors.orange[50]!,
              titulo: 'Reportar um problema',
              subtitulo: 'Abrir uma issue no GitHub',
              onTap: () => _abrirUrl(context, _githubIssuesUrl),
            ),

            const SizedBox(height: 24),

            // ─── SEÇÃO: EQUIPE ────────────────────────────────────
            _tituloSecao('EQUIPE'),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: _equipe.map((membro) {
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF003366),
                        child: Text(
                          membro[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        membro,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOTÃO CONDICIONAL: Login/Cadastro (visitante) OU Sair (logado)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ehVisitante
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E5FB5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Login / Cadastro',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () async {
                          await AuthService().sair();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        child: const Text(
                          'Sair da conta',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Widgets auxiliares ─────────────────────────────────────

  Widget _tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _cartaoLink({
    required BuildContext context,
    required IconData icone,
    required Color corIcone,
    required Color corFundo,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: corFundo,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: corIcone),
          ),
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitulo),
          trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _estatistica(String numero, String label, Color cor) {
    return Column(
      children: [
        Text(
          numero,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
