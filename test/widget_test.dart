// This is a basic Flutter widget test for the Expense Tracker App.

import 'package:flutter_test/flutter_test.dart';
import 'package:expensetrackerapp/main.dart';

void main() {
  testWidgets('Expense Tracker App smoke test', (WidgetTester tester) async {
    // Build our ExpenseTrackerApp and trigger a frame.
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Verify that the Expense Tracker dashboard loads.
    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}
