import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class ListaFrequenciaScreen extends StatefulWidget {
  const ListaFrequenciaScreen({super.key});

  @override
  State<ListaFrequenciaScreen> createState() => _ListaFrequenciaScreenState();
}

class _ListaFrequenciaScreenState extends State<ListaFrequenciaScreen> {
  final _configService = ConfigService();
  final _mes = TextEditingController();
  final _anoLetivo = TextEditingController(text: DateTime.now().year.toString());
  final _turma = TextEditingController();
  final _serie = TextEditingController();
  final _turno = TextEditingController();
  final _professor = TextEditingController();
  final _diasLetivos = TextEditingController();
  final _nomesAlunos = TextEditingController();
  final _linhasEmBranco = TextEditingController(text: '25');

  final _turmasAcumuladas = <Map<String, dynamic>>[];
  bool _gerando = false;

  Future<bool> _perguntarMais(String turmaAdicionada) async {
    final resposta = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar outra turma?'),
        content: Text('Turma "$turmaAdicionada" adicionada (${_turmasAcumuladas.length} turma(s) até agora).\n\n'
            'Deseja preencher e adicionar outra turma antes de gerar o arquivo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não, finalizar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim, adicionar outra')),
        ],
      ),
    );
    return resposta ?? false;
  }

  void _limparCamposTurma() {
    _turma.clear();
    _serie.clear();
    _turno.clear();
    _professor.clear();
    _nomesAlunos.clear();
  }

  Future<void> _gerar() async {
    final dadosEscola = await _configService.carregarDadosEscola();
    if ((dadosEscola['nome_escola'] ?? '').toString().trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha os Dados da Escola antes de gerar.');
      return;
    }
    if (_turma.text.trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha a Turma.');
      return;
    }

    int linhasBrancas = int.tryParse(_linhasEmBranco.text.trim()) ?? 25;
    final turmaAtual = {
      'mes': _mes.text.trim(),
      'ano_letivo': _anoLetivo.text.trim(),
      'turma': _turma.text.trim(),
      'serie': _serie.text.trim(),
      'turno': _turno.text.trim(),
      'professor': _professor.text.trim(),
      'dias_letivos': _diasLetivos.text.trim(),
      'nomes_alunos': _nomesAlunos.text.trim(),
      'linhas_em_branco': linhasBrancas,
    };
    _turmasAcumuladas.add(turmaAtual);

    final querMais = await _perguntarMais(turmaAtual['turma'] as String);
    if (!mounted) return;
    if (querMais) {
      _limparCamposTurma();
      setState(() {});
      return;
    }

    setState(() => _gerando = true);
    const endpoint = '/gerar/lista-frequencia';
    final payload = _turmasAcumuladas.length == 1
        ? {'dados_escola': dadosEscola, 'dados_frequencia': _turmasAcumuladas.first}
        : {'dados_escola': dadosEscola, 'dados_comuns': <String, dynamic>{}, 'turmas': _turmasAcumuladas};
    final nome = _turmasAcumuladas.length == 1
        ? 'Lista de Frequencia - Turma ${_turmasAcumuladas.first['turma']}.docx'
        : 'Lista de Frequencia - Varias Turmas.docx';

    await gerarEAbrirDocumento(context: context, endpoint: endpoint, payload: payload, nomeArquivo: nome);
    _turmasAcumuladas.clear();
    _limparCamposTurma();
    if (mounted) setState(() => _gerando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Lista de Frequência'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: TextField(controller: _mes, decoration: const InputDecoration(labelText: 'Mês (ex: Setembro)'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _anoLetivo, decoration: const InputDecoration(labelText: 'Ano letivo'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _turma, decoration: const InputDecoration(labelText: 'Turma'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _serie, decoration: const InputDecoration(labelText: 'Série'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _turno, decoration: const InputDecoration(labelText: 'Turno'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _professor, decoration: const InputDecoration(labelText: 'Professor(a)'))),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _diasLetivos,
            decoration: const InputDecoration(labelText: 'Dias letivos do mês (ex: 1-4,7-11,14-18)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nomesAlunos,
            decoration: const InputDecoration(labelText: 'Nomes dos alunos (um por linha)'),
            maxLines: 10,
          ),
          const SizedBox(height: 12),
          TextField(controller: _linhasEmBranco, decoration: const InputDecoration(labelText: 'Linhas em branco (se nomes ficar vazio)'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          if (_turmasAcumuladas.isNotEmpty)
            Text('${_turmasAcumuladas.length} turma(s) já adicionada(s), aguardando finalizar.',
                style: const TextStyle(color: corTextoFraco, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Lista de Frequência'),
          ),
        ],
      ),
    );
  }
}
