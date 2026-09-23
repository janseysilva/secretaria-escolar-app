import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Endereço do servidor que gera os documentos (documentos.py por trás).
/// Por enquanto aponta pro "localhost" do próprio celular - funciona
/// porque o teste usa "adb reverse" (cabo USB), que faz o celular
/// enxergar a porta 8123 do computador como se fosse dele mesmo. Quando
/// o servidor for hospedado de verdade na internet, troca esse
/// endereço pelo definitivo (não vai precisar mais de cabo).
const String kApiBaseUrl = 'http://127.0.0.1:8123';

const _chaveDadosEscola = 'dados_escola';

/// Guarda os dados da escola (nome, secretaria, diretor etc.) no
/// aparelho - mesma ideia do dados_escola/config.json da versão de PC,
/// só que aqui fica salvo localmente no celular via shared_preferences.
class ConfigService {
  Future<Map<String, dynamic>> carregarDadosEscola() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chaveDadosEscola);
    if (texto == null) return {};
    return jsonDecode(texto) as Map<String, dynamic>;
  }

  Future<void> salvarDadosEscola(Map<String, dynamic> dados) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveDadosEscola, jsonEncode(dados));
  }
}
