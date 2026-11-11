import 'package:flutter/material.dart';
import 'main.dart';
import 'dados_perguntas.dart';
import 'dados_perguntas_parte2.dart';
import 'dados_perguntas_2024_parte1.dart';
import 'dados_perguntas_2024_parte2.dart';
import 'dados_2023_opcaoB_parte1.dart';
import 'dados_2023_opcaoB_parte2.dart';
import 'dados_2024_opcaoB_parte1.dart';
import 'dados_2024_opcaoB_parte2.dart';
import 'chat_ia_screen.dart'; // Importa apenas o Chat da IA

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006633),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.school, size: 70, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'OCAM Exames',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                
                // ANO 2023
                const Text("EXAMES DE 2023", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _abrirSimulador(context, perguntasExame2023, '2023 - Opção A (P1)'),
                        child: const Text('Opção A - P1'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _abrirSimulador(context, perguntasExame2023Parte2, '2023 - Opção A (P2)'),
                        child: const Text('Opção A - P2'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _abrirSimulador(context, perguntas2023OpcaoBParte1, '2023 - Opção B (P1)'),
                        child: const Text('Opção B - P1'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _abrirSimulador(context, perguntas2023OpcaoBParte2, '2023 - Opção B (P2)'),
                        child: const Text('Opção B - P2'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ANO 2024
                const Text("EXAMES DE 2024", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _abrirSimulador(context, perguntasExame2024Parte1, '2024 - Opção A (P1)'),
                        child: const Text('Opção A - P1'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _abrirSimulador(context, perguntasExame2024Parte2, '2024 - Opção A (P2)'),
                        child: const Text('Opção A - P2'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _abrirSimulador(context, perguntas2024OpcaoBParte1, '2024 - Opção B (P1)'),
                        child: const Text('Opção B - P1'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _abrirSimulador(context, perguntas2024OpcaoBParte2, '2024 - Opção B (P2)'),
                        child: const Text('Opção B - P2'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Divider(color: Colors.white54),
                const SizedBox(height: 20),

                // BOTÃO DA IA
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.smart_toy),
                  label: const Text('FALAR COM O ASSISTENTE (IA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatIAScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _abrirSimulador(BuildContext context, List<Pergunta> perguntas, String titulo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimuladorScreen(
          perguntas: perguntas,
          tituloExame: titulo,
        ),
      ),
    );
  }
}