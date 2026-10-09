import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:start_io_ads_demo/main.dart';

void main() {
  testWidgets('Splash then Home screen renders with all ad format buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StartIoAdsDemoApp());

    expect(find.text('Start.io Ads '), findsWidgets);
    expect(find.text('Preparing Start.io...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Preparing Start.io...'), findsNothing);

    expect(find.text('Start.io Ads '), findsWidgets);
    expect(find.text('Banner Ad'), findsOneWidget);
    expect(find.text('Interstitial Ad'), findsOneWidget);
    expect(find.text('Rewarded Ad'), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Native Ad'), 200,
        scrollable: scrollable);
    expect(find.text('Native Ad'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Video Ad'), 200,
        scrollable: scrollable);
    expect(find.text('Video Ad'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('App Open Ad'), 200,
        scrollable: scrollable);
    expect(find.text('App Open Ad'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Show All Ads Test'), 200,
        scrollable: scrollable);
    expect(find.text('Show All Ads Test'), findsOneWidget);
  });
}