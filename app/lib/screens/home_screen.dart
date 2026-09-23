import 'package:flutter/material.dart';

import '../theme.dart';
import 'bolsa_familia_screen.dart';
import 'capa_livro_screen.dart';
import 'certificado_screen.dart';
import 'dados_escola_screen.dart';
import 'declaracao_screen.dart';
import 'ficha_matricula_screen.dart';
import 'historico_escolar_screen.dart';
import 'justificativa_faltas_screen.dart';
import 'lista_frequencia_screen.dart';
import 'lista_reuniao_screen.dart';
import 'memorando_screen.dart';
import 'oficio_screen.dart';

class _Documento {
  final String titulo;
  final IconData icone;
  final bool disponivel;
  final WidgetBuilder? construirTela;

  const _Documento(this.titulo, this.icone, this.disponivel, [this.construirTela]);
}

final _documentos = <_Documento>[
  _Documento('Memorando', Icons.description, true, (_) => const MemorandoScreen()),
  _Documento('Ofício', Icons.mail, true, (_) => const OficioScreen()),
  _Documento('Declaração Escolar', Icons.article, true, (_) => const DeclaracaoScreen()),
  _Documento('Capa de Abertura de Livro', Icons.menu_book, true, (_) => const CapaLivroScreen()),
  _Documento('Ficha de Matrícula', Icons.badge, true, (_) => const FichaMatriculaScreen()),
  _Documento('Lista de Reunião', Icons.groups, true, (_) => const ListaReuniaoScreen()),
  _Documento('Lista de Frequência', Icons.calendar_month, true, (_) => const ListaFrequenciaScreen()),
  _Documento('Relatório do Bolsa Família', Icons.school, true, (_) => const BolsaFamiliaScreen()),
  _Documento('Justificativa de Faltas', Icons.edit_note, true, (_) => const JustificativaFaltasScreen()),
  _Documento('Certificado de Conclusão', Icons.workspace_premium, true, (_) => const CertificadoScreen()),
  _Documento('Histórico Escolar', Icons.history_edu, true, (_) => const HistoricoEscolarScreen()),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Secretaria Escolar'),
        backgroundColor: corAzulEscuro,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Dados da escola',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DadosEscolaScreen()),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: _documentos.length,
        itemBuilder: (context, i) {
          final doc = _documentos[i];
          return Card(
            color: corCartao,
            elevation: 1,
            child: InkWell(
              onTap: () {
                if (doc.disponivel && doc.construirTela != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: doc.construirTela!),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Em breve.')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(doc.icone, size: 32,
                        color: doc.disponivel ? corAzul : corTextoFraco),
                    const SizedBox(height: 8),
                    Text(doc.titulo, textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: corTexto)),
                    const SizedBox(height: 4),
                    Text(doc.disponivel ? 'Disponível' : 'Em breve',
                        style: TextStyle(
                          fontSize: 11,
                          color: doc.disponivel ? corAzul : corTextoFraco,
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
