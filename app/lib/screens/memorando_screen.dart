import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/arquivo_service.dart';
import '../services/config_service.dart';
import '../theme.dart';

class MemorandoScreen extends StatefulWidget {
  const MemorandoScreen({super.key});

  @override
  State<MemorandoScreen> createState() => _MemorandoScreenState();
}

class _MemorandoScreenState extends State<MemorandoScreen> {
  final _configService = ConfigService();
  final _apiService = ApiService();
  final _arquivoService = ArquivoService();

  final _numero = TextEditingController();
  final _ano = TextEditingController(text: DateTime.now().year.toString());
  final _para = TextEditingController();
  final _assunto = TextEditingController();
  final _corpo = TextEditingController(text: 'Venho, por meio deste, ');
  final _assinadoPor = TextEditingController();

  bool _gerando = false;

  Future<void> _gerar() async {
    final dadosEscola = await _configService.carregarDadosEscola();
    if ((dadosEscola['nome_escola'] ?? '').toString().trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os Dados da Escola antes de gerar.')),
      );
      return;
    }
    if (_para.text.trim().isEmpty || _assunto.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha ao menos "Para" e "Assunto".')),
      );
      return;
    }

    setState(() => _gerando = true);
    try {
      final hoje = DateTime.now();
      final data = '${hoje.day} de ${_nomeMes(hoje.month)} de ${hoje.year}';
      final dadosMemo = {
        'numero': _numero.text.trim(),
        'ano': _ano.text.trim(),
        'para': _para.text.trim(),
        'assunto': _assunto.text.trim(),
        'corpo': _corpo.text.trim(),
        'data': dadosEscola['cidade'] != null && dadosEscola['cidade'].toString().isNotEmpty
            ? '${dadosEscola['cidade']}, $data'
            : data,
        'assinado_por': _assinadoPor.text.trim().isEmpty
            ? (dadosEscola['diretor_nome'] ?? '')
            : _assinadoPor.text.trim(),
      };

      final bytes = await _apiService.gerarDocumento('/gerar/memorando', {
        'dados_escola': dadosEscola,
        'dados_memo': dadosMemo,
      });

      final arquivo = await _arquivoService.salvarDocx(
        bytes,
        'Memorando ${_numero.text.trim()}-${_ano.text.trim()}.docx',
      );
      await _arquivoService.abrirOuCompartilhar(arquivo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar: $e')),
      );
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  String _nomeMes(int mes) {
    const nomes = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return nomes[mes - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Memorando'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _numero,
                  decoration: const InputDecoration(labelText: 'Número'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ano,
                  decoration: const InputDecoration(labelText: 'Ano'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _para,
            decoration: const InputDecoration(labelText: 'Para'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _assunto,
            decoration: const InputDecoration(labelText: 'Assunto'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _corpo,
            decoration: const InputDecoration(labelText: 'Corpo'),
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _assinadoPor,
            decoration: const InputDecoration(
              labelText: 'Assinado por (deixe em branco pra usar o(a) diretor(a) cadastrado)',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(
              backgroundColor: corAzul,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _gerando
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Gerar Memorando'),
          ),
        ],
      ),
    );
  }
}
