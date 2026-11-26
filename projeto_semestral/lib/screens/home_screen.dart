import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _mesSelecionado = 'Outubro 2026';

  static const _meses = {
    'Outubro 2026': '2026-10',
    'Setembro 2026': '2026-09',
  };

  // Horários das turmas (GET /api/turmas)
  Future<List> fetchTurmasDaApi() => ApiService.turmas();

  // Frequência do mês selecionado (GET /api/frequencia)
  Future fetchFrequenciaDaApi() =>
      ApiService.frequencia(mes: _meses[_mesSelecionado]);

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  // --- ABA 1: HORÁRIOS ---
  Widget _buildHorarios() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confira seus horários de aula e organize sua rotina.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List>(
              future: fetchTurmasDaApi(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar dados'));
                }

                final turmas = snapshot.data!;
                return ListView.builder(
                  itemCount: turmas.length,
                  itemBuilder: (context, index) {
                    final turma = turmas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.blue,
                        ),
                        title: Text(
                          turma['disciplina'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Nível: ${turma['nivel']}\n${turma['horario']}',
                        ),
                        trailing: Chip(
                          label: Text(turma['sala']),
                          backgroundColor: Colors.blue.shade50,
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ABA 2: FREQUÊNCIA (IGUAL AO PROTÓTIPO DO RELATÓRIO) ---
  Widget _buildFrequencia() {
    return FutureBuilder(
      future: fetchFrequenciaDaApi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar frequência'));
        }

        final dados = snapshot.data!;
        final List historico = dados['historico'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Acompanhe sua presença nas aulas de inglês.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // 3 Cards de Resumo (Presença, Aulas frequentadas, Faltas)
              Row(
                children: [
                  _buildKpiCard(
                    titulo: 'Presença',
                    valor: dados['percentual'],
                    icone: Icons.check_circle_outline,
                    cor: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildKpiCard(
                    titulo: 'Frequentadas',
                    valor: dados['frequentadas'],
                    icone: Icons.calendar_today_outlined,
                    cor: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildKpiCard(
                    titulo: 'Faltas',
                    valor: dados['faltas'],
                    icone: Icons.error_outline,
                    cor: Colors.deepOrange,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Cabeçalho do Histórico + Filtro de Mês
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Histórico de frequência',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: _mesSelecionado,
                    underline: const SizedBox(),
                    items: ['Outubro 2026', 'Setembro 2026']
                        .map(
                          (mes) => DropdownMenuItem(
                            value: mes,
                            child: Text(
                              mes,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _mesSelecionado = val!),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Lista do Histórico de Aulas
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historico.length,
                itemBuilder: (context, index) {
                  final item = historico[index];
                  final bool isPresente = item['presente'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        '${item['data']} • ${item['aula']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text('Horário: ${item['horario']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPresente
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPresente ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: isPresente ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPresente ? 'Presente' : 'Falta',
                              style: TextStyle(
                                color: isPresente
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Caixa informativa inferior (igual ao protótipo)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A frequência é atualizada pela escola após cada aula.',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget auxiliar para os 3 cards do topo
  Widget _buildKpiCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 24),
              const SizedBox(height: 6),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                titulo,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Horários' : 'Frequência'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _selectedIndex == 0 ? _buildHorarios() : _buildFrequencia(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Horários',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Frequência',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
