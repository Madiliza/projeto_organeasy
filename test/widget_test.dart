import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organeasy_app/main.dart';

void main() {
  testWidgets('App loads with Dashboard title', (WidgetTester tester) async {
    await tester.pumpWidget(const OrganeasyApp());

    // Verifica se o título do AppBar aparece corretamente
    expect(find.text('Organeasy - Dashboard'), findsOneWidget);

    // Verifica se a aba Dashboard está presente
    expect(find.byIcon(Icons.dashboard), findsOneWidget);
  });
}
