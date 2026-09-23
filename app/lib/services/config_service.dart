import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Endereço do servidor que gera os documentos (documentos.py por trás),
/// hospedado de verdade no Render - funciona de qualquer lugar, sem
/// precisar estar na mesma rede nem conectar por cabo.
const String kApiBaseUrl = 'https://secretaria-escolar-app.onrender.com';

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
