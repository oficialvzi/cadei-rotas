import 'package:flutter/material.dart';

class TelaDePerfil extends StatelessWidget {
  const TelaDePerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. O FUNDO DA TELA INTEIRA (Agora é um bege/cinza bem claro)
      backgroundColor: const Color(0xFFF5F4F1),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF003366),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),

      body: Column(
        children: [
          // ==========================================
          // CAIXA AZUL DO TOPO
          // ==========================================
          Container(
            width: double.infinity,
            color: const Color(0xFF003366),
            padding: const EdgeInsets.only(top: 80, bottom: 30),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.grey),
                ),
                SizedBox(height: 15),
                Text('Maria Silva', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 5),
                Text('[email protected]', style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ==========================================
          // CARTÃO BRANCO DE ESTATÍSTICAS
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // Margem externa
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0), // Margem interna (gordura da caixa)
              decoration: BoxDecoration(
                color: Colors.white, // A cor da caixa
                borderRadius: BorderRadius.circular(15), // O arredondamento das pontas
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Column(
                    children: [
                      Text('12', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('REPORTS', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  // LINHA DIVISÓRIA 1
                  Container(height: 40, width: 2, color: Colors.grey[300]),

                  const Column(
                    children: [
                      Text('38', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('CONFIRMAÇÕES', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  // LINHA DIVISÓRIA 2
                  Container(height: 40, width: 2, color: Colors.grey[300]),

                  const Column(
                    children: [
                      Text('5', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      Text('CONTESTAÇÕES', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ==========================================
          // TÍTULO "CONFIGURAÇÕES"
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CONFIGURAÇÕES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ==========================================
          // CARTÕES BRANCOS DE CONFIGURAÇÃO
          // ==========================================

          // Cartão do Tema
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                  child: const Icon(Icons.dark_mode, color: Colors.blue),
                ),
                title: const Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Modo claro'),
                trailing: Switch(value: false, onChanged: (bool valor) {}),
              ),
            ),
          ),

          // Cartão de Notificações
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                  child: const Icon(Icons.notifications, color: Colors.green),
                ),
                title: const Text('Notificações', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Reports próximos'),
                trailing: Switch(value: true, activeThumbColor: Colors.green, onChanged: (bool valor) {}),
              ),
            ),
          ),

          const Spacer(),

          // ==========================================
          // BOTÃO DE SAIR DA CONTA
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white, // Fundo branco para o botão também
                  side: const BorderSide(color: Colors.red, width: 1.5), // Borda vermelha mais fina
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {},
                child: const Text('Sair da conta', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}