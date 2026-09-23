import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Salva os bytes do .docx recebido do servidor numa pasta temporária do
/// celular e devolve o arquivo pronto pra abrir/compartilhar.
class ArquivoService {
  Future<File> salvarDocx(Uint8List bytes, String nomeSugerido) async {
    final pasta = await getTemporaryDirectory();
    final caminho = '${pasta.path}/$nomeSugerido';
    final arquivo = File(caminho);
    await arquivo.writeAsBytes(bytes);
    return arquivo;
  }

  /// Tenta abrir com o Word (ou outro app instalado) - se não conseguir
  /// (nenhum app pra abrir .docx), oferece a tela de compartilhar do
  /// próprio Android como alternativa.
  Future<void> abrirOuCompartilhar(File arquivo) async {
    final resultado = await OpenFilex.open(arquivo.path);
    if (resultado.type != ResultType.done) {
      await Share.shareXFiles([XFile(arquivo.path)]);
    }
  }
}
