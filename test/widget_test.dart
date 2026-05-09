import 'package:flutter_test/flutter_test.dart';
import 'package:match_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Builds without crashing
    await tester.pumpWidget(const MatchTrackerApp());
    expect(find.byType(MatchTrackerApp), findsOneWidget);
  });
}
