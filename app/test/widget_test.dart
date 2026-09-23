import 'package:flutter_test/flutter_test.dart';

import 'package:secretaria_escolar/main.dart';

void main() {
  testWidgets('A tela inicial mostra o titulo do app e o Memorando disponível', (tester) async {
    await tester.pumpWidget(const SecretariaEscolarApp());

    expect(find.text('Secretaria Escolar'), findsOneWidget);
    expect(find.text('Memorando'), findsOneWidget);
    // GridView e preguicoso (so constroi o que cabe na tela) - nao da
    // pra checar os 11 cards de uma vez sem rolar, entao so confirma
    // que pelo menos um "Disponível" apareceu (nenhum "Em breve" deve
    // existir mais, ja que todos os documentos foram concluidos).
    expect(find.text('Disponível'), findsWidgets);
    expect(find.text('Em breve'), findsNothing);
  });
}
