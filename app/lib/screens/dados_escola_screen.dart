import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../theme.dart';

class DadosEscolaScreen extends StatefulWidget {
  const DadosEscolaScreen({super.key});

  @override
  State<DadosEscolaScreen> createState() => _DadosEscolaScreenState();
}

class _DadosEscolaScreenState extends State<DadosEscolaScreen> {
  final _configService = ConfigService();
  final _nomeEscola = TextEditingController();
  final _secretaria = TextEditingController();
  final _diretorNome = TextEditingController();
  final _diretorCargo = TextEditingController();
  final _cidade = TextEditingController();
  bool _carregando = true;

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
    setState(() => _carregando = false);
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
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados da escola salvos.')),
    );
    Navigator.of(context).pop();
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
