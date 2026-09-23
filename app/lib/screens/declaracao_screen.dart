import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/data_utils.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class DeclaracaoScreen extends StatefulWidget {
  const DeclaracaoScreen({super.key});

  @override
  State<DeclaracaoScreen> createState() => _DeclaracaoScreenState();
}

class _DeclaracaoScreenState extends State<DeclaracaoScreen> {
  final _configService = ConfigService();
  final _aluno = TextEditingController();
  final _codigoSigeam = TextEditingController();
  final _codigoOutroRotulo = TextEditingController();
  final _anoLetivo = TextEditingController();
  final _serie = TextEditingController();
  final _turma = TextEditingController();
  final _finalidadeFrequencia = TextEditingController();
  final _finalidadeOutros = TextEditingController();
  final _statusDesistenteData = TextEditingController();
  final _obs = TextEditingController();

  String _codigoTipo = 'SIGEAM';
  String _situacaoMatricula = 'esta';
  String _situacaoCurso = 'cursa';
  String _turno = 'matutino';
  String _finalidade = 'trabalho';
  String _statusAluno = 'promovido';
  bool _gerando = false;

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
    final codigoTipo = _codigoTipo == 'Outros' ? _codigoOutroRotulo.text.trim() : _codigoTipo;
    final dadosDecl = {
      'aluno': _aluno.text.trim(),
      'codigo_sigeam': _codigoSigeam.text.trim(),
      'codigo_tipo': codigoTipo,
      'situacao_matricula': _situacaoMatricula,
      'ano_letivo': _anoLetivo.text.trim(),
      'situacao_curso': _situacaoCurso,
      'serie': _serie.text.trim(),
      'turma': _turma.text.trim(),
      'turno': _turno,
      'finalidade': _finalidade,
      'finalidade_frequencia': _finalidadeFrequencia.text.trim(),
      'finalidade_outros': _finalidadeOutros.text.trim(),
      'status_aluno': _statusAluno,
      'status_desistente_data': _statusDesistenteData.text.trim(),
      'obs': _obs.text.trim(),
      'data': dataPorExtenso(dadosEscola['cidade'] ?? ''),
    };
    if (!mounted) return;
    await gerarEAbrirDocumento(
      context: context,
      endpoint: '/gerar/declaracao',
      payload: {'dados_escola': dadosEscola, 'dados_decl': dadosDecl},
      nomeArquivo: 'Declaracao - ${_aluno.text.trim()}.docx',
    );
    if (mounted) setState(() => _gerando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Declaração Escolar'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _aluno, decoration: const InputDecoration(labelText: 'Nome completo do(a) aluno(a)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _codigoTipo,
            decoration: const InputDecoration(labelText: 'Tipo de código'),
            items: const [
              DropdownMenuItem(value: 'SIGEAM', child: Text('SIGEAM')),
              DropdownMenuItem(value: 'Matrícula', child: Text('Matrícula')),
              DropdownMenuItem(value: 'Outros', child: Text('Outros')),
            ],
            onChanged: (v) => setState(() => _codigoTipo = v!),
          ),
          if (_codigoTipo == 'Outros') ...[
            const SizedBox(height: 12),
            TextField(controller: _codigoOutroRotulo, decoration: const InputDecoration(labelText: 'Rótulo do código')),
          ],
          const SizedBox(height: 12),
          TextField(controller: _codigoSigeam, decoration: const InputDecoration(labelText: 'Número/código (opcional)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _situacaoMatricula,
            decoration: const InputDecoration(labelText: 'Situação da matrícula'),
            items: const [
              DropdownMenuItem(value: 'esta', child: Text('Está matriculado(a)')),
              DropdownMenuItem(value: 'foi', child: Text('Foi matriculado(a)')),
            ],
            onChanged: (v) => setState(() => _situacaoMatricula = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: _anoLetivo, decoration: const InputDecoration(labelText: 'Ano letivo')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _situacaoCurso,
            decoration: const InputDecoration(labelText: 'Situação do curso'),
            items: const [
              DropdownMenuItem(value: 'cursa', child: Text('Cursa')),
              DropdownMenuItem(value: 'cursou', child: Text('Cursou')),
            ],
            onChanged: (v) => setState(() => _situacaoCurso = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: _serie, decoration: const InputDecoration(labelText: 'Série')),
          const SizedBox(height: 12),
          TextField(controller: _turma, decoration: const InputDecoration(labelText: 'Turma')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _turno,
            decoration: const InputDecoration(labelText: 'Turno'),
            items: const [
              DropdownMenuItem(value: 'matutino', child: Text('Matutino')),
              DropdownMenuItem(value: 'vespertino', child: Text('Vespertino')),
              DropdownMenuItem(value: 'noturno', child: Text('Noturno')),
              DropdownMenuItem(value: 'intermediario', child: Text('Intermediário')),
            ],
            onChanged: (v) => setState(() => _turno = v!),
          ),
          const SizedBox(height: 20),
          Text('Declarações para fins de', style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _finalidade,
            decoration: const InputDecoration(labelText: 'Finalidade'),
            items: const [
              DropdownMenuItem(value: 'trabalho', child: Text('Trabalho')),
              DropdownMenuItem(value: 'transferencia', child: Text('Transferência')),
              DropdownMenuItem(value: 'sinetram', child: Text('Sinetram')),
              DropdownMenuItem(value: 'bolsa_familia', child: Text('Bolsa Família / Frequência')),
              DropdownMenuItem(value: 'outros', child: Text('Outros')),
            ],
            onChanged: (v) => setState(() => _finalidade = v!),
          ),
          if (_finalidade == 'bolsa_familia') ...[
            const SizedBox(height: 12),
            TextField(controller: _finalidadeFrequencia, decoration: const InputDecoration(labelText: 'Frequência (%)'), keyboardType: TextInputType.number),
          ],
          if (_finalidade == 'outros') ...[
            const SizedBox(height: 12),
            TextField(controller: _finalidadeOutros, decoration: const InputDecoration(labelText: 'Descrição')),
          ],
          const SizedBox(height: 20),
          Text('Status do aluno', style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _statusAluno,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'promovido', child: Text('Promovido(a)')),
              DropdownMenuItem(value: 'retido', child: Text('Retido(a)')),
              DropdownMenuItem(value: 'desistente', child: Text('Desistente')),
              DropdownMenuItem(value: 'progressao_parcial', child: Text('Progressão Parcial')),
              DropdownMenuItem(value: 'cursando', child: Text('Cursando')),
            ],
            onChanged: (v) => setState(() => _statusAluno = v!),
          ),
          if (_statusAluno == 'desistente') ...[
            const SizedBox(height: 12),
            TextField(controller: _statusDesistenteData, decoration: const InputDecoration(labelText: 'Data da desistência (DD/MM/AAAA)')),
          ],
          const SizedBox(height: 12),
          TextField(controller: _obs, decoration: const InputDecoration(labelText: 'OBS (opcional)')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Declaração'),
          ),
        ],
      ),
    );
  }
}
