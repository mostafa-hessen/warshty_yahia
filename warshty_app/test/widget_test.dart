import 'package:flutter_test/flutter_test.dart';
import 'package:warshty_app/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WarshtyApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('ورشتي'), findsOneWidget);
  });
}
