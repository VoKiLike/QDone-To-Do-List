import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/core/widgets/qdone_tap_feedback.dart';

void main() {
  testWidgets('hold does not flash; release flashes for 200 ms', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _TestApp(
        child: QDoneTapFeedback(
          onTap: () => taps++,
          builder: (context, tapped) => Container(
            key: const Key('surface'),
            width: 80,
            height: 48,
            color: tapped ? Colors.cyan : Colors.blue,
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('surface'))),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(taps, 0);
    expect(_surfaceColor(tester), Colors.blue);

    await gesture.up();
    await tester.pump();

    expect(taps, 1);
    expect(_surfaceColor(tester), Colors.cyan);

    await tester.pump(const Duration(milliseconds: 199));
    expect(_surfaceColor(tester), Colors.cyan);

    await tester.pump(const Duration(milliseconds: 2));
    expect(_surfaceColor(tester), Colors.blue);
  });

  testWidgets('rapid taps restart the feedback timer', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _TestApp(
        child: QDoneTapFeedback(
          onTap: () => taps++,
          builder: (context, tapped) => Container(
            key: const Key('surface'),
            width: 80,
            height: 48,
            color: tapped ? Colors.cyan : Colors.blue,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('surface')));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.byKey(const Key('surface')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(taps, 2);
    expect(_surfaceColor(tester), Colors.cyan);

    await tester.pump(const Duration(milliseconds: 101));
    expect(_surfaceColor(tester), Colors.blue);
  });

  testWidgets('disabled feedback ignores taps', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: QDoneTapFeedback(
          onTap: null,
          builder: (context, tapped) => Container(
            key: const Key('surface'),
            width: 80,
            height: 48,
            color: tapped ? Colors.cyan : Colors.blue,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('surface')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(_surfaceColor(tester), Colors.blue);
  });

  testWidgets('material wrapper invokes only the outer callback', (
    tester,
  ) async {
    var outerTaps = 0;
    var innerTaps = 0;
    await tester.pumpWidget(
      _TestApp(
        child: QDoneMaterialTapFeedback(
          onTap: () => outerTaps++,
          semanticLabel: 'Action',
          child: FilledButton(
            onPressed: () => innerTaps++,
            child: const Text('Action'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(QDoneMaterialTapFeedback));
    await tester.pump();

    expect(outerTaps, 1);
    expect(innerTaps, 0);
  });
}

Color? _surfaceColor(WidgetTester tester) {
  return tester.widget<Container>(find.byKey(const Key('surface'))).color;
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }
}
