import 'package:flutter_test/flutter_test.dart';

import 'package:secretaria_escolar/main.dart';

void main() {
  testWidgets('A tela inicial mostra o titulo do app e o Memorando', (tester) async {
    await tester.pumpWidget(const SecretariaEscolarApp());

    expect(find.text('Secretaria Escolar'), findsOneWidget);
    expect(find.text('Memorando'), findsOneWidget);
    expect(find.text('Disponível'), findsOneWidget);
  });
}
