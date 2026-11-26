import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.perfil(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar perfil'));
          }

          final aluno = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  '${aluno['nome']}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Aluno(a) - Matrícula: ${aluno['matricula']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informações Pessoais',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('E-mail'),
                          subtitle: Text('${aluno['email'] ?? '-'}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Telefone'),
                          subtitle: Text('${aluno['telefone'] ?? '-'}'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sair do Sistema',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      ApiService.logout();
                      // Remove todas as telas do histórico e volta para o Login
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
