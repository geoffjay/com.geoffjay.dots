import 'package:flutter_test/flutter_test.dart';

import 'package:dots/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const DotsApp());
    await tester.pump();

    // Verify the app loads (will show login screen initially)
    expect(find.byType(DotsApp), findsOneWidget);
  });
}
