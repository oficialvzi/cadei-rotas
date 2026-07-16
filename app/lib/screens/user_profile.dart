import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cadeirotas_app/core/services/auth_service.dart';
import 'package:cadeirotas_app/core/services/reports_service.dart';
import 'package:cadeirotas_app/screens/instruction_slides.dart';

class TelaDePerfil extends StatelessWidget {
  const TelaDePerfil({super.key});

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

      body: Column(
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

          // CARTÃO BRANCO DE ESTATÍSTICAS (ainda mock)
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
                  if (snap.hasError) {
                    debugPrint('❌ ERRO estatísticas: ${snap.error}');
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Erro: ${snap.error}',
                        style: const TextStyle(fontSize: 10, color: Colors.red),
                        textAlign: TextAlign.center,
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
                      Container(height: 40, width: 2, color: Colors.grey[300]),
                      _estatistica(
                        '${dados['confirmacoes']}',
                        'CONFIRMAÇÕES',
                        Colors.green,
                      ),
                      Container(height: 40, width: 2, color: Colors.grey[300]),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CONFIGURAÇÕES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Cartão do Tema
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 5.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.dark_mode, color: Colors.blue),
                ),
                title: const Text(
                  'Tema',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Modo claro'),
                trailing: Switch(value: false, onChanged: (bool valor) {}),
              ),
            ),
          ),

          // Cartão de Notificações
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 5.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications, color: Colors.green),
                ),
                title: const Text(
                  'Notificações',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Reports próximos'),
                trailing: Switch(
                  value: true,
                  activeColor: Colors.green,
                  onChanged: (bool valor) {},
                ),
              ),
            ),
          ),

          const Spacer(),

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
