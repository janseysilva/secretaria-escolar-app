import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../services/arquivo_service.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class BolsaFamiliaScreen extends StatefulWidget {
  const BolsaFamiliaScreen({super.key});

  @override
  State<BolsaFamiliaScreen> createState() => _BolsaFamiliaScreenState();
}

class _BolsaFamiliaScreenState extends State<BolsaFamiliaScreen> {
  final _apiService = ApiService();
  final _arquivoService = ArquivoService();
  final _percentualMinimo = TextEditingController(text: '60');

  final _gruposMeses = <List<PlatformFile>>[];
  PlatformFile? _arquivoLista;
  bool _formatoXlsx = true;
  bool _formatoDocx = true;
  bool _formatoPdf = true;
  bool _gerando = false;

  Future<void> _adicionarMes() async {
    final resultado = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (resultado.isEmpty) return;
    setState(() => _gruposMeses.add(resultado));
  }

  Future<void> _escolherLista() async {
    final resultado = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['docx', 'pdf'],
    );
    if (resultado == null) return;
    setState(() => _arquivoLista = resultado);
  }

  Future<void> _gerar() async {
    if (_gruposMeses.isEmpty) {
      avisar(context, 'Adicione ao menos um mês com PDFs de frequência.');
      return;
    }
    if (_arquivoLista == null) {
      avisar(context, 'Escolha o arquivo da lista de alunos do Bolsa Família.');
      return;
    }
    if (!_formatoXlsx && !_formatoDocx && !_formatoPdf) {
      avisar(context, 'Marque ao menos um formato pra salvar.');
      return;
    }

    setState(() => _gerando = true);
    try {
      final arquivos = <MapEntry<String, http.MultipartFile>>[];
      arquivos.add(MapEntry(
        'arquivo_lista',
        await http.MultipartFile.fromPath('arquivo_lista', _arquivoLista!.path!),
      ));
      for (var i = 0; i < _gruposMeses.length; i++) {
        for (final arquivo in _gruposMeses[i]) {
          arquivos.add(MapEntry(
            'grupo_$i',
            await http.MultipartFile.fromPath('grupo_$i', arquivo.path!),
          ));
        }
      }

      final bytes = await _apiService.gerarDocumentoComArquivos(
        '/gerar/bolsa-familia',
        campos: {
          'percentual_minimo': _percentualMinimo.text.trim().isEmpty ? '60' : _percentualMinimo.text.trim(),
          'formato_xlsx': _formatoXlsx.toString(),
          'formato_docx': _formatoDocx.toString(),
          'formato_pdf': _formatoPdf.toString(),
        },
        arquivos: arquivos,
      );

      final arquivoZip = await _arquivoService.salvarArquivo(bytes, 'Relatorio Bolsa Familia.zip');
      await _arquivoService.abrirOuCompartilhar(arquivoZip);
    } catch (e) {
      if (mounted) avisar(context, 'Erro ao gerar: $e');
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Relatório do Bolsa Família'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Adicione um "mês" por vez, escolhendo os PDFs de frequência '
            'desse mês. Depois escolha a lista de alunos do Bolsa Família '
            '(Word ou PDF).',
            style: TextStyle(color: corTextoFraco),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _adicionarMes,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar mês (PDFs de frequência)'),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _gruposMeses.length; i++)
            ListTile(
              dense: true,
              leading: const Icon(Icons.folder, color: corAzul),
              title: Text('Mês ${i + 1}: ${_gruposMeses[i].length} arquivo(s)'),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _gruposMeses.removeAt(i)),
              ),
            ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.list_alt, color: corAzul),
            title: Text(_arquivoLista?.name ?? 'Nenhuma lista escolhida'),
            trailing: TextButton(onPressed: _escolherLista, child: const Text('Escolher lista')),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _percentualMinimo,
            decoration: const InputDecoration(labelText: '% mínimo de presença'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Excel (.xlsx)'),
            value: _formatoXlsx,
            onChanged: (v) => setState(() => _formatoXlsx = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Word (.docx)'),
            value: _formatoDocx,
            onChanged: (v) => setState(() => _formatoDocx = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('PDF (.pdf)'),
            value: _formatoPdf,
            onChanged: (v) => setState(() => _formatoPdf = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 12),
          const Text(
            'O resultado sai num arquivo .zip com os formatos escolhidos '
            'dentro.',
            style: TextStyle(color: corTextoFraco, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Relatório do Bolsa Família'),
          ),
        ],
      ),
    );
  }
}
