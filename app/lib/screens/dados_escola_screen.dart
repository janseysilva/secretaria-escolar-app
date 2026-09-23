import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/config_service.dart';
import '../theme.dart';

class DadosEscolaScreen extends StatefulWidget {
  const DadosEscolaScreen({super.key});

  @override
  State<DadosEscolaScreen> createState() => _DadosEscolaScreenState();
}

class _DadosEscolaScreenState extends State<DadosEscolaScreen> {
  final _configService = ConfigService();
  final _picker = ImagePicker();
  final _nomeEscola = TextEditingController();
  final _secretaria = TextEditingController();
  final _diretorNome = TextEditingController();
  final _diretorCargo = TextEditingController();
  final _cidade = TextEditingController();
  bool _carregando = true;

  String? _logoBase64;
  String? _assinaturaBase64;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final dados = await _configService.carregarDadosEscola();
    _nomeEscola.text = dados['nome_escola'] ?? '';
    _secretaria.text = dados['secretaria'] ?? '';
    _diretorNome.text = dados['diretor_nome'] ?? '';
    _diretorCargo.text = dados['diretor_cargo'] ?? '';
    _cidade.text = dados['cidade'] ?? '';
    _logoBase64 = dados['logo_base64'];
    _assinaturaBase64 = dados['assinatura_base64'];
    setState(() => _carregando = false);
  }

  Future<void> _escolherImagem(void Function(String? novoBase64) definir) async {
    final imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 85,
    );
    if (imagem == null) return;
    final bytes = await imagem.readAsBytes();
    setState(() => definir(base64Encode(bytes)));
  }

  Future<void> _salvar() async {
    if (_nomeEscola.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome da escola.')),
      );
      return;
    }
    await _configService.salvarDadosEscola({
      'nome_escola': _nomeEscola.text.trim(),
      'secretaria': _secretaria.text.trim(),
      'diretor_nome': _diretorNome.text.trim(),
      'diretor_cargo': _diretorCargo.text.trim(),
      'cidade': _cidade.text.trim(),
      'logo_base64': _logoBase64,
      'assinatura_base64': _assinaturaBase64,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados da escola salvos.')),
    );
    Navigator.of(context).pop();
  }

  Widget _campoImagem({
    required String rotulo,
    required String? base64Atual,
    required void Function(String? novoBase64) definir,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: const TextStyle(fontWeight: FontWeight.bold, color: corTexto)),
        const SizedBox(height: 6),
        Row(
          children: [
            if (base64Atual != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  base64Decode(base64Atual),
                  width: 56, height: 56, fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: corFundo,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: corTextoFraco),
                ),
                child: Icon(Icons.image_outlined, color: corTextoFraco),
              ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => _escolherImagem(definir),
              child: Text(base64Atual == null ? 'Escolher imagem' : 'Trocar'),
            ),
            if (base64Atual != null)
              TextButton(
                onPressed: () => setState(() => definir(null)),
                child: const Text('Remover', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Dados da escola'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nomeEscola,
            decoration: const InputDecoration(labelText: 'Nome da escola'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secretaria,
            decoration: const InputDecoration(
              labelText: 'Secretaria/órgão superior (opcional)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _diretorNome,
            decoration: const InputDecoration(
              labelText: 'Nome do(a) diretor(a)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _diretorCargo,
            decoration: const InputDecoration(labelText: 'Cargo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cidade,
            decoration: const InputDecoration(labelText: 'Cidade'),
          ),
          const SizedBox(height: 20),
          _campoImagem(
            rotulo: 'Logo/Brasão (opcional)',
            base64Atual: _logoBase64,
            definir: (v) => _logoBase64 = v,
          ),
          const SizedBox(height: 16),
          _campoImagem(
            rotulo: 'Assinatura digitalizada (opcional)',
            base64Atual: _assinaturaBase64,
            definir: (v) => _assinaturaBase64 = v,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _salvar,
            style: ElevatedButton.styleFrom(
              backgroundColor: corAzul,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
