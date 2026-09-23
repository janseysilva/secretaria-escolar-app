import 'package:flutter/material.dart';

import '../theme.dart';
import 'dados_escola_screen.dart';
import 'memorando_screen.dart';

class _Documento {
  final String titulo;
  final IconData icone;
  final bool disponivel;
  final WidgetBuilder? construirTela;

  const _Documento(this.titulo, this.icone, this.disponivel, [this.construirTela]);
}

final _documentos = <_Documento>[
  _Documento('Memorando', Icons.description, true, (_) => const MemorandoScreen()),
  const _Documento('Ofício', Icons.mail, false),
  const _Documento('Declaração Escolar', Icons.article, false),
  const _Documento('Capa de Abertura de Livro', Icons.menu_book, false),
  const _Documento('Ficha de Matrícula', Icons.badge, false),
  const _Documento('Lista de Reunião', Icons.groups, false),
  const _Documento('Lista de Frequência', Icons.calendar_month, false),
  const _Documento('Justificativa de Faltas', Icons.edit_note, false),
  const _Documento('Certificado de Conclusão', Icons.workspace_premium, false),
  const _Documento('Histórico Escolar', Icons.school, false),
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
