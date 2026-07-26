import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nucleus/main.dart';

void main() {
  testWidgets('Harmonized view shows empty state with no providers connected',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NucleusApp());

    expect(find.text('No cloud accounts connected yet'), findsOneWidget);
    expect(find.text('Connect provider'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
  });
}
