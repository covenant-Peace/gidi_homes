import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gidi_homes/app/app.dart';

void main() {
  testWidgets('App boots to the home screen with the hero headline',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GidiHomesApp()));

    // The hero renders synchronously.
    expect(find.textContaining('Lagos'), findsWidgets);

    // Let the repositories' simulated-latency timers fire so none are pending
    // when the widget tree is torn down.
    await tester.pump(const Duration(seconds: 1));
  });
}
