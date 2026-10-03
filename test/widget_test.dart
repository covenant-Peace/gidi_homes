import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gidi_homes/app/app.dart';
import 'package:gidi_homes/data/agent_repository.dart';
import 'package:gidi_homes/data/auth_repository.dart';
import 'package:gidi_homes/data/property_repository.dart';
import 'package:gidi_homes/providers/providers.dart';

void main() {
  testWidgets('App boots to the home screen with the hero headline',
      (WidgetTester tester) async {
    // Override the Firebase-backed repos with in-memory ones so the widget
    // test runs without a live Firebase connection.
    final agents = InMemoryAgentRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          agentRepoProvider.overrideWithValue(agents),
          propertyRepoProvider.overrideWithValue(InMemoryPropertyRepository()),
          authRepoProvider.overrideWithValue(InMemoryAuthRepository(agents)),
        ],
        child: const GidiHomesApp(),
      ),
    );

    // The hero renders synchronously.
    expect(find.textContaining('Lagos'), findsWidgets);

    // Drain the in-memory repositories' simulated-latency timers.
    await tester.pump(const Duration(seconds: 1));
  });
}
