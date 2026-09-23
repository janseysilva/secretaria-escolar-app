import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'config_service.dart';

/// Fala com o servidor (main.py) que usa a mesma lógica de geração de
/// documentos já testada na versão de Windows.
class ApiService {
  Future<Uint8List> gerarDocumento(
    String caminhoEndpoint,
    Map<String, dynamic> payload,
  ) async {
    final resposta = await http
        .post(
          Uri.parse('$kApiBaseUrl$caminhoEndpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));

    if (resposta.statusCode != 200) {
      throw Exception(
        'O servidor recusou o pedido (código ${resposta.statusCode}). '
        'Confira se o servidor está ligado e se o celular está na mesma rede.',
      );
    }
    return resposta.bodyBytes;
  }

  /// Usado só pelo Relatório do Bolsa Família, que manda arquivos de
  /// verdade (PDFs + lista) em vez de só texto.
  Future<Uint8List> gerarDocumentoComArquivos(
    String caminhoEndpoint, {
    required Map<String, String> campos,
    required List<MapEntry<String, http.MultipartFile>> arquivos,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$kApiBaseUrl$caminhoEndpoint'));
    request.fields.addAll(campos);
    for (final arquivo in arquivos) {
      request.files.add(arquivo.value);
    }

    final resposta = await http.Response.fromStream(
      await request.send().timeout(const Duration(seconds: 60)),
    );

    if (resposta.statusCode != 200) {
      throw Exception(
        'O servidor recusou o pedido (código ${resposta.statusCode}): '
        '${resposta.body}',
      );
    }
    return resposta.bodyBytes;
  }
}
