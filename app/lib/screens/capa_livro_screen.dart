import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/data_utils.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class CapaLivroScreen extends StatefulWidget {
  const CapaLivroScreen({super.key});

  @override
  State<CapaLivroScreen> createState() => _CapaLivroScreenState();
}

class _CapaLivroScreenState extends State<CapaLivroScreen> {
  final _configService = ConfigService();
  final _tipoLivro = TextEditingController();
  final _numero = TextEditingController();
  final _qtdFolhas = TextEditingController();
  final _finalidade = TextEditingController();
  final _responsavelAbertura = TextEditingController();
  final _cargoAbertura = TextEditingController();

  bool _gerando = false;

  @override
  void initState() {
    super.initState();
    _configService.carregarDadosEscola().then((dados) {
      _responsavelAbertura.text = dados['diretor_nome'] ?? '';
      _cargoAbertura.text = dados['diretor_cargo'] ?? '';
      setState(() {});
    });
  }

  Future<void> _gerar() async {
    final dadosEscola = await _configService.carregarDadosEscola();
    if ((dadosEscola['nome_escola'] ?? '').toString().trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha os Dados da Escola antes de gerar.');
      return;
    }
    if (_tipoLivro.text.trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha o tipo de livro.');
      return;
    }

    setState(() => _gerando = true);
    final dadosLivro = {
      'tipo_livro': _tipoLivro.text.trim(),
      'numero': _numero.text.trim(),
      'finalidade': _finalidade.text.trim(),
      'qtd_folhas': _qtdFolhas.text.trim(),
      'data': dataPorExtenso(dadosEscola['cidade'] ?? ''),
      'responsavel_abertura': _responsavelAbertura.text.trim(),
      'cargo_abertura': _cargoAbertura.text.trim(),
    };
    if (!mounted) return;
    await gerarEAbrirDocumento(
      context: context,
      endpoint: '/gerar/capa-livro',
      payload: {'dados_escola': dadosEscola, 'dados_livro': dadosLivro},
      nomeArquivo: 'Termo de Abertura - ${_tipoLivro.text.trim()}.docx',
    );
    if (mounted) setState(() => _gerando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Capa de Abertura de Livro'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _tipoLivro, decoration: const InputDecoration(labelText: 'Tipo de livro (ex: Livro de Atas)')),
          const SizedBox(height: 12),
          TextField(controller: _numero, decoration: const InputDecoration(labelText: 'Número do livro')),
          const SizedBox(height: 12),
          TextField(controller: _qtdFolhas, decoration: const InputDecoration(labelText: 'Quantidade de folhas numeradas'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _finalidade, decoration: const InputDecoration(labelText: 'Finalidade')),
          const SizedBox(height: 12),
          TextField(controller: _responsavelAbertura, decoration: const InputDecoration(labelText: 'Responsável pela abertura')),
          const SizedBox(height: 12),
          TextField(controller: _cargoAbertura, decoration: const InputDecoration(labelText: 'Cargo')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Termo de Abertura'),
          ),
        ],
      ),
    );
  }
}
