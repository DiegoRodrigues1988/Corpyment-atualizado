// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:pilates_corpyment/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verifica se o título da HomeScreen aparece
    expect(find.text('Pilates Corpyment'), findsOneWidget);
    // Verifica se os botões existem
    expect(find.text('Ver Agenda de Aulas'), findsOneWidget);
    expect(find.text('Gerenciar Alunos'), findsOneWidget);
  });
}