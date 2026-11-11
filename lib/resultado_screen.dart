import 'package:flutter/material.dart';
import 'main.dart'; // Importa o molde da Pergunta

class ResultadoScreen extends StatelessWidget {
  final List<Pergunta> perguntas;
  final Map<int, String> respostasUtilizador;

  const ResultadoScreen({
    Key? key,
    required this.perguntas,
    required this.respostasUtilizador,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double notaFinal = 0;
    for (var pergunta in perguntas) {
      if (respostasUtilizador[pergunta.id] == pergunta.respostaCorreta) {
        notaFinal += 0.4; // 0.4 valores por questão
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grelha de Correcção'),
        backgroundColor: const Color(0xFF006633),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Placar da nota
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.grey[200],
            child: Column(
              children: [
                const Text('Sua Nota Final:', style: TextStyle(fontSize: 18)),
                Text(
                  '${notaFinal.toStringAsFixed(1)} Valores',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF006633)),
                ),
              ],
            ),
          ),
          
          // Tabela de correção
          Expanded(
            child: ListView.builder(
              itemCount: perguntas.length,
              itemBuilder: (context, index) {
                final pergunta = perguntas[index];
                final respostaUser = respostasUtilizador[pergunta.id];
                final acertou = respostaUser == pergunta.respostaCorreta;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: acertou ? Colors.green : Colors.red,
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(acertou ? 'Resposta Correcta' : 'Resposta Errada'),
                    subtitle: Text(
                      'Sua resposta: ${respostaUser?.toUpperCase() ?? "Nenhuma"}\n'
                      'Resposta certa: ${pergunta.respostaCorreta.toUpperCase()}',
                    ),
                    trailing: Text(
                      acertou ? '+0.4' : '0.0',
                      style: TextStyle(
                        color: acertou ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Justificação:", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(pergunta.justificacao),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}