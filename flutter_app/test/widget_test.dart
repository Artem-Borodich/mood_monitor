import 'package:flutter_test/flutter_test.dart';

import 'package:psycho_emotional_monitor/main.dart';

void main() {
  testWidgets('MoodApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MoodApp());
    await tester.pump();
    expect(find.byType(MoodApp), findsOneWidget);
  });
}
