import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:control_plane/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FreewayControlPanel(),
      ),
    );

    // Verify the app title is shown
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
