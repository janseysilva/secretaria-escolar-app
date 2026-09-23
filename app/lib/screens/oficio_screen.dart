import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/data_utils.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class OficioScreen extends StatefulWidget {
  const OficioScreen({super.key});

  @override
  State<OficioScreen> createState() => _OficioScreenState();
}

class _OficioScreenState extends State<OficioScreen> {
  final _configService = ConfigService();
  final _numero = TextEditingController();
  final _ano = TextEditingController(text: DateTime.now().year.toString());
  final _protocolo = TextEditingController();
  final _para = TextEditingController();
  final _cargoDestinatario = TextEditingController();
  final _assunto = TextEditingController();
  final _saudacao = TextEditingController(text: 'Prezado(a) Senhor(a),');
  final _corpo = TextEditingController(text: 'Venho, por meio deste, ');
  final _fecho = TextEditingController(text: 'Atenciosamente,');
  final _assinadoPor = TextEditingController();
  final _cargoAssinadoPor = TextEditingController();

  bool _gerando = false;

  @override
  void initState() {
    super.initState();
    _configService.carregarDadosEscola().then((dados) {
      _assinadoPor.text = dados['diretor_nome'] ?? '';
      _cargoAssinadoPor.text = dados['diretor_cargo'] ?? '';
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
    if (_para.text.trim().isEmpty || _assunto.text.trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha ao menos "Para" e "Assunto".');
      return;
    }

    setState(() => _gerando = true);
    final dadosOficio = {
      'numero': _numero.text.trim(),
      'ano': _ano.text.trim(),
      'protocolo': _protocolo.text.trim(),
      'data': dataPorExtenso(dadosEscola['cidade'] ?? ''),
      'para': _para.text.trim(),
      'cargo_destinatario': _cargoDestinatario.text.trim(),
      'assunto': _assunto.text.trim(),
      'saudacao': _saudacao.text.trim(),
      'corpo': _corpo.text.trim(),
      'fecho': _fecho.text.trim(),
      'assinado_por': _assinadoPor.text.trim(),
      'cargo_assinado_por': _cargoAssinadoPor.text.trim(),
    };
    if (!mounted) return;
    await gerarEAbrirDocumento(
      context: context,
      endpoint: '/gerar/oficio',
      payload: {'dados_escola': dadosEscola, 'dados_oficio': dadosOficio},
      nomeArquivo: 'Oficio ${_numero.text.trim()}-${_ano.text.trim()}.docx',
    );
    if (mounted) setState(() => _gerando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Ofício'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: TextField(controller: _numero, decoration: const InputDecoration(labelText: 'Número'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _ano, decoration: const InputDecoration(labelText: 'Ano'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _protocolo, decoration: const InputDecoration(labelText: 'Protocolo (opcional)')),
          const SizedBox(height: 12),
          TextField(controller: _para, decoration: const InputDecoration(labelText: 'Destinatário (Para)')),
          const SizedBox(height: 12),
          TextField(controller: _cargoDestinatario, decoration: const InputDecoration(labelText: 'Cargo/instituição do destinatário (opcional)')),
          const SizedBox(height: 12),
          TextField(controller: _assunto, decoration: const InputDecoration(labelText: 'Assunto')),
          const SizedBox(height: 12),
          TextField(controller: _saudacao, decoration: const InputDecoration(labelText: 'Saudação')),
          const SizedBox(height: 12),
          TextField(controller: _corpo, decoration: const InputDecoration(labelText: 'Corpo'), maxLines: 6),
          const SizedBox(height: 12),
          TextField(controller: _fecho, decoration: const InputDecoration(labelText: 'Fecho')),
          const SizedBox(height: 12),
          TextField(controller: _assinadoPor, decoration: const InputDecoration(labelText: 'Assinado por')),
          const SizedBox(height: 12),
          TextField(controller: _cargoAssinadoPor, decoration: const InputDecoration(labelText: 'Cargo de quem assina')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Ofício'),
          ),
        ],
      ),
    );
  }
}
