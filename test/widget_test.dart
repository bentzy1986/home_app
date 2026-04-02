import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/main.dart';

void main() {
  testWidgets('Counter increment smoke test', (WidgetTester tester) async {
    // בניית האפליקציה שלנו וחיפוש ה-Widget שלה
    await tester.pumpWidget(const HomeManagerApp());
    expect(find.text('הבית'), findsWidgets);
  });
}
