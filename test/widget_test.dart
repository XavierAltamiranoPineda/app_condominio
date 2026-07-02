import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_condominio/main.dart';

void main() {
  testWidgets('CondoAdmin app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CondoAdminApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
