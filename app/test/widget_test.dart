import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vaidyaai/main.dart';

void main() {
  testWidgets('renders Hindi intake flow and demo analysis', (tester) async {
    await tester.pumpWidget(const VaidyaAIApp());

    expect(find.text('VaidyaAI'), findsOneWidget);
    expect(find.text('ऑफलाइन मोड'), findsOneWidget);

    await tester.tap(find.text('डेमो केस'));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('YELLOW'), findsOneWidget);
    expect(find.text('मुख्य संभावित निदान'), findsOneWidget);
  });
}
