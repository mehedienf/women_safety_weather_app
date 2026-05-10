import 'package:flutter_test/flutter_test.dart';

import 'package:safe_bd/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WomenSafetyDisasterApp());
  });
}
