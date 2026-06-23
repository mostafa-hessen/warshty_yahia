import 'package:flutter_test/flutter_test.dart';

import 'package:warshty_app/app.dart';
import 'package:warshty_app/core/di/injection_container.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await init();
    await tester.pumpWidget(const WarshtyApp());
    await tester.pump();

    expect(find.text('ورشتي'), findsNothing);
  });
}
