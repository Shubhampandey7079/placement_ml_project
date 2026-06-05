import 'package:flutter_test/flutter_test.dart';
import 'package:placement_predictor_app/app.dart';

void main() {
  testWidgets('App smoke test - renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CareerFitApp());
    // Verify the app renders successfully
    expect(find.byType(CareerFitApp), findsOneWidget);
  });
}
