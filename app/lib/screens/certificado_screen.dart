import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/data_utils.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class CertificadoScreen extends StatefulWidget {
  const CertificadoScreen({super.key});

  @override
  State<CertificadoScreen> createState() => _CertificadoScreenState();
}

class _CertificadoScreenState extends State<CertificadoScreen> {
  final _configService = ConfigService();
  final _aluno = TextEditingController();
  final _etapaConcluida = TextEditingController();
  final _anoLetivo = TextEditingController(text: DateTime.now().year.toString());
  final _turma = TextEditingController();
  final _secretarioNome = TextEditingController();
  final _diretorNome = TextEditingController();
  final _amparoLegal = TextEditingController();
  final _registroNumero = TextEditingController();
  final _livroNumero = TextEditingController();
  final _folha = TextEditingController();
  final _registradoPor = TextEditingController();

  bool _gerando = false;

  @override
  void initState() {
    super.initState();
    _configService.carregarDadosEscola().then((dados) {
      _secretarioNome.text = dados['secretario_nome'] ?? '';
      _diretorNome.text = dados['diretor_nome'] ?? '';
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
    if (_aluno.text.trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha o nome do aluno.');
      return;
    }

    setState(() => _gerando = true);
    final dadosCertificado = {
      'nome_aluno': _aluno.text.trim(),
      'etapa_concluida': _etapaConcluida.text.trim(),
      'ano_letivo': _anoLetivo.text.trim(),
      'turma': _turma.text.trim(),
      'data': dataPorExtenso(dadosEscola['cidade'] ?? ''),
      'secretario_nome': _secretarioNome.text.trim(),
      'diretor_nome': _diretorNome.text.trim(),
      'amparo_legal': _amparoLegal.text.trim(),
      'registro_numero': _registroNumero.text.trim(),
      'livro_numero': _livroNumero.text.trim(),
      'folha': _folha.text.trim(),
      'registrado_por': _registradoPor.text.trim(),
    };
    if (!mounted) return;
    await gerarEAbrirDocumento(
      context: context,
      endpoint: '/gerar/certificado',
      payload: {'dados_escola': dadosEscola, 'dados_certificado': dadosCertificado},
      nomeArquivo: 'Certificado - ${_aluno.text.trim()}.docx',
    );
    if (mounted) setState(() => _gerando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Certificado de Conclusão'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _aluno, decoration: const InputDecoration(labelText: 'Nome do aluno')),
          const SizedBox(height: 12),
          TextField(controller: _etapaConcluida, decoration: const InputDecoration(labelText: 'Etapa concluída (ex: Ensino Fundamental)')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _anoLetivo, decoration: const InputDecoration(labelText: 'Ano letivo'), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _turma, decoration: const InputDecoration(labelText: 'Turma (opcional)'))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _secretarioNome, decoration: const InputDecoration(labelText: 'Secretário(a)')),
          const SizedBox(height: 12),
          TextField(controller: _diretorNome, decoration: const InputDecoration(labelText: 'Diretor(a)')),
          const SizedBox(height: 20),
          Text('Registro no livro da escola (opcional)', style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
          const SizedBox(height: 8),
          TextField(controller: _amparoLegal, decoration: const InputDecoration(labelText: 'Amparo legal')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _registroNumero, decoration: const InputDecoration(labelText: 'Registro Nº'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _livroNumero, decoration: const InputDecoration(labelText: 'Livro Nº'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _folha, decoration: const InputDecoration(labelText: 'Folha'))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _registradoPor, decoration: const InputDecoration(labelText: 'Registrado por')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Certificado'),
          ),
        ],
      ),
    );
  }
}
