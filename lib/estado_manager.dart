import 'package:shared_preferences/shared_preferences.dart';

class EstadoManager {
  // Guardar a pergunta atual
  static Future<void> guardarProgresso(String idExame, int perguntaIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progresso_$idExame', perguntaIndex);
  }

  // Obter a pergunta onde parou
  static Future<int> obterProgresso(String idExame) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('progresso_$idExame') ?? 0; // 0 é a primeira pergunta
  }
}