import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/gerar_helper.dart';
import '../theme.dart';

class FichaMatriculaScreen extends StatefulWidget {
  const FichaMatriculaScreen({super.key});

  @override
  State<FichaMatriculaScreen> createState() => _FichaMatriculaScreenState();
}

class _FichaMatriculaScreenState extends State<FichaMatriculaScreen> {
  final _configService = ConfigService();

  String _tipoFicha = 'Educação Infantil';
  final _nomeSocial = TextEditingController();
  final _nomeCrianca = TextEditingController();
  final _dataNascimento = TextEditingController();
  String _sexo = 'masculino';
  bool _gemeo = false;
  final _tipoSanguineo = TextEditingController();
  final _nacionalidade = TextEditingController(text: 'Brasileira');
  final _dataEntradaPais = TextEditingController();
  final _naturalidade = TextEditingController();
  final _ufNaturalidade = TextEditingController();
  final _nomeMae = TextEditingController();
  final _nomePai = TextEditingController();
  final _endereco = TextEditingController();
  final _numero = TextEditingController();
  final _complemento = TextEditingController();
  final _tipoLogradouro = TextEditingController();
  final _bairro = TextEditingController();
  final _cep = TextEditingController();
  final _numeroTermo = TextEditingController();
  final _folha = TextEditingController();
  final _livro = TextEditingController();
  final _dataEmissaoCertidao = TextEditingController();
  final _ufCartorio = TextEditingController();
  final _nomeCartorio = TextEditingController();
  final _numeroIdentidade = TextEditingController();
  final _complementoIdentidade = TextEditingController();
  final _dataExpedicaoIdentidade = TextEditingController();
  final _ufRg = TextEditingController();
  final _orgaoEmissorIdentidade = TextEditingController();
  final _cpf = TextEditingController();
  String _corRaca = 'parda';
  final _telefone = TextEditingController();
  final _matriculaRegistroCivil = TextEditingController();
  final _codigoAluno = TextEditingController();
  final _nis = TextEditingController();
  final _dataIngresso = TextEditingController();
  String _deficiencia = 'nao';
  String _bolsaFamilia = 'nao';
  final _tipoDeficiencia = TextEditingController();
  String _necessidadesEspeciais = 'nao';
  String _apoioPedagogico = '';
  String _transporteEscolar = 'nao';
  String _tipoTransporte = '';
  String _zonaResidencia = 'urbana';
  String _movimento = 'nenhum';
  final _etapa = TextEditingController();

  bool _gerando = false;

  Widget _campo(TextEditingController c, String label, {TextInputType? tipo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(controller: c, decoration: InputDecoration(labelText: label), keyboardType: tipo),
    );
  }

  Widget _dropdown(String valor, String label, List<MapEntry<String, String>> opcoes, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: valor,
        decoration: InputDecoration(labelText: label),
        items: opcoes.map((o) => DropdownMenuItem(value: o.key, child: Text(o.value))).toList(),
        onChanged: (v) => setState(() => onChanged(v!)),
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro, fontSize: 15)),
      );

  Future<void> _gerar() async {
    final dadosEscola = await _configService.carregarDadosEscola();
    if ((dadosEscola['nome_escola'] ?? '').toString().trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha os Dados da Escola antes de gerar.');
      return;
    }
    if (_nomeCrianca.text.trim().isEmpty) {
      if (!mounted) return;
      avisar(context, 'Preencha o nome da criança.');
      return;
    }

    setState(() => _gerando = true);
    final dadosFicha = {
      'tipo_ficha': _tipoFicha,
      'nome_social': _nomeSocial.text.trim(),
      'nome_crianca': _nomeCrianca.text.trim(),
      'data_nascimento': _dataNascimento.text.trim(),
      'sexo': _sexo,
      'gemeo': _gemeo,
      'tipo_sanguineo': _tipoSanguineo.text.trim(),
      'nacionalidade': _nacionalidade.text.trim(),
      'data_entrada_pais': _dataEntradaPais.text.trim(),
      'naturalidade': _naturalidade.text.trim(),
      'uf_naturalidade': _ufNaturalidade.text.trim(),
      'nome_mae': _nomeMae.text.trim(),
      'nome_pai': _nomePai.text.trim(),
      'endereco': _endereco.text.trim(),
      'numero': _numero.text.trim(),
      'complemento': _complemento.text.trim(),
      'tipo_logradouro': _tipoLogradouro.text.trim(),
      'bairro': _bairro.text.trim(),
      'cep': _cep.text.trim(),
      'numero_termo': _numeroTermo.text.trim(),
      'folha': _folha.text.trim(),
      'livro': _livro.text.trim(),
      'data_emissao_certidao': _dataEmissaoCertidao.text.trim(),
      'uf_cartorio': _ufCartorio.text.trim(),
      'nome_cartorio': _nomeCartorio.text.trim(),
      'numero_identidade': _numeroIdentidade.text.trim(),
      'complemento_identidade': _complementoIdentidade.text.trim(),
      'data_expedicao_identidade': _dataExpedicaoIdentidade.text.trim(),
      'uf_rg': _ufRg.text.trim(),
      'orgao_emissor_identidade': _orgaoEmissorIdentidade.text.trim(),
      'cpf': _cpf.text.trim(),
      'cor_raca': _corRaca,
      'telefone': _telefone.text.trim(),
      'matricula_registro_civil': _matriculaRegistroCivil.text.trim(),
      'codigo_aluno': _codigoAluno.text.trim(),
      'nis': _nis.text.trim(),
      'data_ingresso': _dataIngresso.text.trim(),
      'deficiencia': _deficiencia,
      'bolsa_familia': _bolsaFamilia,
      'tipo_deficiencia': _tipoDeficiencia.text.trim(),
      'necessidades_especiais': _necessidadesEspeciais,
      'apoio_pedagogico': _apoioPedagogico,
      'transporte_escolar': _transporteEscolar,
      'tipo_transporte': _tipoTransporte,
      'zona_residencia': _zonaResidencia,
      'movimento': _movimento,
      'etapa': _etapa.text.trim(),
    };
    if (!mounted) return;
    await gerarEAbrirDocumento(
      context: context,
      endpoint: '/gerar/ficha-matricula',
      payload: {'dados_escola': dadosEscola, 'dados_ficha': dadosFicha},
      nomeArquivo: 'Ficha de Matricula - ${_nomeCrianca.text.trim()}.docx',
    );
    if (mounted) setState(() => _gerando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Ficha de Matrícula'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dropdown(_tipoFicha, 'Tipo de ficha', const [
            MapEntry('Educação Infantil', 'Educação Infantil'),
            MapEntry('Maternal', 'Maternal'),
            MapEntry('Ensino Fundamental I', 'Ensino Fundamental I'),
            MapEntry('Ensino Fundamental II', 'Ensino Fundamental II'),
          ], (v) => _tipoFicha = v),
          _campo(_codigoAluno, 'Código do aluno'),
          _campo(_nis, 'N.I.S.'),

          _titulo('DADOS PESSOAIS DA CRIANÇA'),
          _campo(_nomeSocial, 'Nome social (opcional)'),
          _campo(_nomeCrianca, 'Nome completo da criança'),
          _campo(_dataNascimento, 'Data de nascimento'),
          _dropdown(_sexo, 'Sexo', const [MapEntry('masculino', 'Masculino'), MapEntry('feminino', 'Feminino')], (v) => _sexo = v),
          CheckboxListTile(
            title: const Text('Gêmeo(a)'),
            value: _gemeo,
            onChanged: (v) => setState(() => _gemeo = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          _campo(_tipoSanguineo, 'Tipo sanguíneo'),
          _campo(_nacionalidade, 'Nacionalidade'),
          _campo(_dataEntradaPais, 'Data de entrada no país (se estrangeiro)'),
          _campo(_naturalidade, 'Naturalidade'),
          _campo(_ufNaturalidade, 'UF da naturalidade'),
          _campo(_nomeMae, 'Nome da mãe'),
          _campo(_nomePai, 'Nome do pai'),
          _campo(_endereco, 'Endereço'),
          _campo(_numero, 'Número'),
          _campo(_complemento, 'Complemento'),
          _campo(_tipoLogradouro, 'Tipo de logradouro'),
          _campo(_bairro, 'Bairro'),
          _campo(_cep, 'CEP'),
          _campo(_numeroTermo, 'Nº do termo (certidão)'),
          _campo(_folha, 'Folha (certidão)'),
          _campo(_livro, 'Livro (certidão)'),
          _campo(_dataEmissaoCertidao, 'Data de emissão da certidão'),
          _campo(_ufCartorio, 'UF do cartório'),
          _campo(_nomeCartorio, 'Nome do cartório'),
          _campo(_numeroIdentidade, 'Número de identidade (RG)'),
          _campo(_complementoIdentidade, 'Complemento da identidade'),
          _campo(_dataExpedicaoIdentidade, 'Data de expedição do RG'),
          _campo(_ufRg, 'UF do RG'),
          _campo(_orgaoEmissorIdentidade, 'Órgão emissor'),
          _campo(_cpf, 'CPF'),
          _dropdown(_corRaca, 'Cor/raça', const [
            MapEntry('branca', 'Branca'),
            MapEntry('preta', 'Preta'),
            MapEntry('parda', 'Parda'),
            MapEntry('amarela', 'Amarela'),
            MapEntry('indigena', 'Indígena'),
            MapEntry('nao_declarada', 'Não declarada'),
          ], (v) => _corRaca = v),
          _campo(_telefone, 'Telefone'),
          _campo(_matriculaRegistroCivil, 'Matrícula do registro civil'),

          _titulo('DADOS ESCOLARES'),
          _campo(_dataIngresso, 'Data de ingresso'),
          _dropdown(_deficiencia, 'Possui deficiência?', const [MapEntry('nao', 'Não'), MapEntry('sim', 'Sim')], (v) => _deficiencia = v),
          if (_deficiencia == 'sim') _campo(_tipoDeficiencia, 'Tipo de deficiência'),
          _dropdown(_necessidadesEspeciais, 'Necessidades especiais?', const [MapEntry('nao', 'Não'), MapEntry('sim', 'Sim')], (v) => _necessidadesEspeciais = v),
          _dropdown(_apoioPedagogico, 'Apoio pedagógico', const [
            MapEntry('', 'Nenhum'),
            MapEntry('na_escola', 'Na escola'),
            MapEntry('outra_escola', 'Em outra escola'),
          ], (v) => _apoioPedagogico = v),
          _dropdown(_bolsaFamilia, 'Bolsa Família?', const [MapEntry('nao', 'Não'), MapEntry('sim', 'Sim')], (v) => _bolsaFamilia = v),
          _dropdown(_transporteEscolar, 'Transporte escolar?', const [MapEntry('nao', 'Não'), MapEntry('sim', 'Sim')], (v) => _transporteEscolar = v),
          if (_transporteEscolar == 'sim')
            _dropdown(_tipoTransporte, 'Tipo de transporte', const [
              MapEntry('', 'Não informado'),
              MapEntry('fluvial', 'Fluvial'),
              MapEntry('rodoviario', 'Rodoviário'),
            ], (v) => _tipoTransporte = v),
          _dropdown(_zonaResidencia, 'Zona de residência', const [MapEntry('urbana', 'Urbana'), MapEntry('rural', 'Rural')], (v) => _zonaResidencia = v),
          _dropdown(_movimento, 'Movimento', const [
            MapEntry('nenhum', 'Nenhum'),
            MapEntry('abandono', 'Abandono'),
            MapEntry('transferencia', 'Transferência'),
            MapEntry('matricula_final', 'Matrícula final'),
          ], (v) => _movimento = v),
          _campo(_etapa, 'Série/Turma (ex: Maternal II, 5º Ano B)'),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _gerando ? null : _gerar,
            style: ElevatedButton.styleFrom(backgroundColor: corAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _gerando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gerar Ficha de Matrícula'),
          ),
        ],
      ),
    );
  }
}
