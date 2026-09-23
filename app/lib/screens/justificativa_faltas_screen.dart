import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/data_utils.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class JustificativaFaltasScreen extends StatefulWidget {
  const JustificativaFaltasScreen({super.key});

  @override
  State<JustificativaFaltasScreen> createState() => _JustificativaFaltasScreenState();
}

class _JustificativaFaltasScreenState extends State<JustificativaFaltasScreen> {
  final _configService = ConfigService();
  final _aluno = TextEditingController();
  final _turma = TextEditingController();
  final _turno = TextEditingController();
  final _responsavel = TextEditingController();
  final _periodo = TextEditingController();
  final _diasLetivos = TextEditingController();
  final _faltas = TextEditingController();
  final _motivoOutro = TextEditingController();
  final _observacoes = TextEditingController();
  final _recebidoPor = TextEditingController();
  final _cargoRecebidoPor = TextEditingController();

  String _etapaEnsino = 'infantil';
  String _motivo = 'doenca_aluno';
  bool _gerando = false;

  @override
  void initState() {
    super.initState();
    _configService.carregarDadosEscola().then((dados) {
      _recebidoPor.text = dados['diretor_nome'] ?? '';
      _cargoRecebidoPor.text = dados['diretor_cargo'] ?? '';
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
    final dadosJustificativa = {
      'nome_aluno': _aluno.text.trim(),
      'turma': _turma.text.trim(),
      'turno': _turno.text.trim(),
      'nome_responsavel': _responsavel.text.trim(),
      'etapa_ensino': _etapaEnsino,
      'periodo': _periodo.text.trim(),
      'dias_letivos': _diasLetivos.text.trim(),
      'faltas': _faltas.text.trim(),
      'motivo': _motivo,
      'motivo_outro': _motivoOutro.text.trim(),
      'observacoes': _observacoes.text.trim(),
      'data': dataPorExtenso(dadosEscola['cidade'] ?? ''),
      'recebido_por': _recebidoPor.text.trim(),
      'cargo_recebido_por': _cargoRecebidoPor.text.trim(),
    };
    if (!mounted) return;
    await gerarEAbrirDocumento(
      context: context,
      endpoint: '/gerar/justificativa-faltas',
      payload: {'dados_escola': dadosEscola, 'dados_justificativa': dadosJustificativa},
      nomeArquivo: 'Justificativa de Faltas - ${_aluno.text.trim()}.docx',
    );
    if (mounted) setState(() => _gerando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Justificativa de Faltas'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _aluno, decoration: const InputDecoration(labelText: 'Nome do aluno')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _turma, decoration: const InputDecoration(labelText: 'Turma'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _turno, decoration: const InputDecoration(labelText: 'Turno'))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _responsavel, decoration: const InputDecoration(labelText: 'Nome do responsável')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _etapaEnsino,
            decoration: const InputDecoration(labelText: 'Etapa de ensino'),
            items: const [
              DropdownMenuItem(value: 'infantil', child: Text('Educação Infantil (mínimo 60%)')),
              DropdownMenuItem(value: 'fundamental', child: Text('Ensino Fundamental em diante (mínimo 75%)')),
            ],
            onChanged: (v) => setState(() => _etapaEnsino = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: _periodo, decoration: const InputDecoration(labelText: 'Período (ex: Agosto/2026)')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _diasLetivos, decoration: const InputDecoration(labelText: 'Dias letivos'), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _faltas, decoration: const InputDecoration(labelText: 'Faltas'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _motivo,
            decoration: const InputDecoration(labelText: 'Motivo apresentado'),
            items: const [
              DropdownMenuItem(value: 'doenca_aluno', child: Text('Doença do(a) aluno(a)')),
              DropdownMenuItem(value: 'doenca_familia', child: Text('Doença/problema de saúde na família')),
              DropdownMenuItem(value: 'mudanca_endereco', child: Text('Mudança de endereço/dificuldade de acesso')),
              DropdownMenuItem(value: 'transporte', child: Text('Dificuldade de transporte')),
              DropdownMenuItem(value: 'trabalho_renda', child: Text('Motivo de trabalho/renda familiar')),
              DropdownMenuItem(value: 'outro', child: Text('Outro')),
            ],
            onChanged: (v) => setState(() => _motivo = v!),
          ),
          if (_motivo == 'outro') ...[
            const SizedBox(height: 12),
            TextField(controller: _motivoOutro, decoration: const InputDecoration(labelText: 'Descrição do motivo')),
          ],
          const SizedBox(height: 12),
          TextField(controller: _observacoes, decoration: const InputDecoration(labelText: 'Observações (opcional)')),
          const SizedBox(height: 12),
          TextField(controller: _recebidoPor, decoration: const InputDecoration(labelText: 'Recebido por (quem atendeu)')),
          const SizedBox(height: 12),
          TextField(controller: _cargoRecebidoPor, decoration: const InputDecoration(labelText: 'Cargo')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Justificativa'),
          ),
        ],
      ),
    );
  }
}
