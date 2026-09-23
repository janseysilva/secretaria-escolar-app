import 'package:flutter/material.dart';

import 'api_service.dart';
import 'arquivo_service.dart';

final _apiService = ApiService();
final _arquivoService = ArquivoService();

/// Fluxo comum a todas as telas de documento: chama o servidor, salva o
/// .docx recebido e abre/compartilha - usado por todas as telas pra não
/// repetir esse bloco 11 vezes.
Future<void> gerarEAbrirDocumento({
  required BuildContext context,
  required String endpoint,
  required Map<String, dynamic> payload,
  required String nomeArquivo,
}) async {
  try {
    final bytes = await _apiService.gerarDocumento(endpoint, payload);
    final arquivo = await _arquivoService.salvarArquivo(bytes, nomeArquivo);
    await _arquivoService.abrirOuCompartilhar(arquivo);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao gerar: $e')),
    );
  }
}

void avisar(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
}
