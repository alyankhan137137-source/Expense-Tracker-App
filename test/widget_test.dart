// Basic Flutter widget test verifying that Finance Tracker Pro launches cleanly.

import 'package:flutter_test/flutter_test.dart';
import 'package:expensetrackerapp/main.dart';

void main() {
  testWidgets('Finance Tracker Pro App smoke test', (WidgetTester tester) async {
    // Build our ExpenseTrackerApp and trigger a frame.
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Verify that the application title loads successfully.
    expect(find.text('Finance Tracker Pro'), findsOneWidget);
  });
}
