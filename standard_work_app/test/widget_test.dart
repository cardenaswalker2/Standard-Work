import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standard_work/core/widgets/darnel_logo.dart';

void main() {
  testWidgets('DarnelLogoWidget renderiza DARNEL GROUP con estilo correcto', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DarnelLogoWidget(),
        ),
      ),
    );

    expect(find.text('DARNEL'), findsOneWidget);
    expect(find.text('GROUP'), findsOneWidget);
  });
}
