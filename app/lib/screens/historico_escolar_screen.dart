import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/data_utils.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class HistoricoEscolarScreen extends StatefulWidget {
  const HistoricoEscolarScreen({super.key});

  @override
  State<HistoricoEscolarScreen> createState() => _HistoricoEscolarScreenState();
}

class _HistoricoEscolarScreenState extends State<HistoricoEscolarScreen> {
  final _configService = ConfigService();
  final _codigoAluno = TextEditingController();
  final _nomeAluno = TextEditingController();
  final _dataNascimento = TextEditingController();
  final _registroGeral = TextEditingController();
  final _municipio = TextEditingController();
  final _naturalidade = TextEditingController();
  final _nacionalidade = TextEditingController(text: 'Brasileira');

  final _anoLetivo = TextEditingController();
  final _ensino = TextEditingController();
  final _fase = TextEditingController();
  final _estabelecimento = TextEditingController();
  String _situacao = 'promovido';

  final _discNome = TextEditingController();
  final _discNota = TextEditingController();
  final _discCh = TextEditingController();
  final _discFaltas = TextEditingController();

  final _amparoLegal = TextEditingController();
  final _regras = TextEditingController();
  final _diretorPortaria = TextEditingController();
  final _diretorNome = TextEditingController();
  final _secretarioPortaria = TextEditingController();
  final _secretarioNome = TextEditingController();

  final _disciplinasAcumuladas = <Map<String, dynamic>>[];
  final _anosAcumulados = <Map<String, dynamic>>[];
  bool _gerando = false;

  @override
  void initState() {
    super.initState();
    _configService.carregarDadosEscola().then((dados) {
      _diretorNome.text = dados['diretor_nome'] ?? '';
      _secretarioNome.text = dados['secretario_nome'] ?? '';
      setState(() {});
    });
  }

  void _adicionarDisciplina() {
    if (_discNome.text.trim().isEmpty) {
      avisar(context, 'Preencha o nome da disciplina.');
      return;
    }
    setState(() {
      _disciplinasAcumuladas.add({
        'nome': _discNome.text.trim(),
        'nota': _discNota.text.trim(),
        'carga_horaria': _discCh.text.trim(),
        'faltas': _discFaltas.text.trim(),
      });
      _discNome.clear();
      _discNota.clear();
      _discCh.clear();
      _discFaltas.clear();
    });
  }

  void _limparCamposAno() {
    _anoLetivo.clear();
    _ensino.clear();
    _fase.clear();
    _estabelecimento.clear();
    _disciplinasAcumuladas.clear();
  }

  Future<bool> _perguntarMais(String anoAdicionado) async {
    final resposta = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar outro ano?'),
        content: Text('Ano letivo "$anoAdicionado" adicionado (${_anosAcumulados.length} ano(s) até agora).\n\n'
            'Deseja preencher e adicionar outro ano antes de gerar o arquivo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não, finalizar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim, adicionar outro')),
        ],
      ),
    );
    return resposta ?? false;
  }

  Future<void> _gerar() async {
    final dadosEscola = await _configService.carregarDadosEscola();
    if ((dadosEscola['nome_escola'] ?? '').toString().trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha os Dados da Escola antes de gerar.');
      return;
    }
    if (_nomeAluno.text.trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha o nome do aluno.');
      return;
    }
    if (_anoLetivo.text.trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha o Ano letivo.');
      return;
    }

    final anoAtual = {
      'ano_letivo': _anoLetivo.text.trim(),
      'ensino': _ensino.text.trim(),
      'fase': _fase.text.trim(),
      'estabelecimento': _estabelecimento.text.trim(),
      'situacao': _situacao,
      'disciplinas': List<Map<String, dynamic>>.from(_disciplinasAcumuladas),
    };
    _anosAcumulados.add(anoAtual);

    final querMais = await _perguntarMais(anoAtual['ano_letivo'] as String);
    if (!mounted) return;
    if (querMais) {
      _limparCamposAno();
      setState(() {});
      return;
    }

    setState(() => _gerando = true);
    final dadosHistorico = {
      'nome_aluno': _nomeAluno.text.trim(),
      'codigo_aluno': _codigoAluno.text.trim(),
      'data_nascimento': _dataNascimento.text.trim(),
      'registro_geral': _registroGeral.text.trim(),
      'municipio': _municipio.text.trim(),
      'naturalidade': _naturalidade.text.trim(),
      'nacionalidade': _nacionalidade.text.trim(),
      'anos': _anosAcumulados,
      'amparo_legal': _amparoLegal.text.trim(),
      'regras': _regras.text.trim(),
      'data': dataPorExtenso(dadosEscola['cidade'] ?? ''),
      'diretor_portaria': _diretorPortaria.text.trim(),
      'diretor_nome': _diretorNome.text.trim(),
      'secretario_portaria': _secretarioPortaria.text.trim(),
      'secretario_nome': _secretarioNome.text.trim(),
    };
    await gerarEAbrirDocumento(
      context: context,
      endpoint: '/gerar/historico-escolar',
      payload: {'dados_escola': dadosEscola, 'dados_historico': dadosHistorico},
      nomeArquivo: 'Historico Escolar - ${_nomeAluno.text.trim()}.docx',
    );
    _anosAcumulados.clear();
    _limparCamposAno();
    if (mounted) setState(() => _gerando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Histórico Escolar'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(flex: 1, child: TextField(controller: _codigoAluno, decoration: const InputDecoration(labelText: 'Código'))),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: TextField(controller: _nomeAluno, decoration: const InputDecoration(labelText: 'Nome do aluno'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _dataNascimento, decoration: const InputDecoration(labelText: 'Nascimento'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _registroGeral, decoration: const InputDecoration(labelText: 'Nº Registro Geral'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _municipio, decoration: const InputDecoration(labelText: 'Município'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _naturalidade, decoration: const InputDecoration(labelText: 'Naturalidade'))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _nacionalidade, decoration: const InputDecoration(labelText: 'Nacionalidade')),

          const Divider(height: 32),
          Text('Ano letivo (adicione um por vez)', style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _anoLetivo, decoration: const InputDecoration(labelText: 'Ano letivo'))),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _situacao,
                decoration: const InputDecoration(labelText: 'Situação'),
                items: const [
                  DropdownMenuItem(value: 'promovido', child: Text('Promovido')),
                  DropdownMenuItem(value: 'retido', child: Text('Retido')),
                  DropdownMenuItem(value: 'retido_frequencia', child: Text('Retido p/ frequência')),
                ],
                onChanged: (v) => setState(() => _situacao = v!),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _ensino, decoration: const InputDecoration(labelText: 'Ensino (ex: Ensino Fundamental de 1º ao 5º Ano)')),
          const SizedBox(height: 12),
          TextField(controller: _fase, decoration: const InputDecoration(labelText: 'Fase/Série (ex: 3º Ano)')),
          const SizedBox(height: 12),
          TextField(controller: _estabelecimento, decoration: const InputDecoration(labelText: 'Estabelecimento')),

          const SizedBox(height: 16),
          Text('Disciplinas deste ano letivo', style: const TextStyle(fontWeight: FontWeight.bold, color: corTexto)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(flex: 2, child: TextField(controller: _discNome, decoration: const InputDecoration(labelText: 'Disciplina'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _discNota, decoration: const InputDecoration(labelText: 'Nota'))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _discCh, decoration: const InputDecoration(labelText: 'Carga Horária'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _discFaltas, decoration: const InputDecoration(labelText: 'Faltas'))),
          ]),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _adicionarDisciplina,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar disciplina'),
          ),
          if (_disciplinasAcumuladas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${_disciplinasAcumuladas.length} disciplina(s) neste ano: ${_disciplinasAcumuladas.map((d) => d['nome']).join(', ')}',
              style: const TextStyle(color: corTextoFraco, fontSize: 12),
            ),
          ],
          if (_anosAcumulados.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('${_anosAcumulados.length} ano(s) já adicionado(s), aguardando finalizar.',
                style: const TextStyle(color: corTextoFraco, fontSize: 12)),
          ],

          const Divider(height: 32),
          Text('Base legal e assinaturas', style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
          const SizedBox(height: 8),
          TextField(controller: _amparoLegal, decoration: const InputDecoration(labelText: 'Amparo legal (opcional)')),
          const SizedBox(height: 12),
          TextField(controller: _regras, decoration: const InputDecoration(labelText: 'Regras (opcional)'), maxLines: 3),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _diretorPortaria, decoration: const InputDecoration(labelText: 'Portaria do(a) diretor(a)'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _diretorNome, decoration: const InputDecoration(labelText: 'Diretor(a)'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _secretarioPortaria, decoration: const InputDecoration(labelText: 'Portaria do(a) secretário(a)'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _secretarioNome, decoration: const InputDecoration(labelText: 'Secretário(a)'))),
          ]),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Histórico Escolar'),
          ),
        ],
      ),
    );
  }
}
