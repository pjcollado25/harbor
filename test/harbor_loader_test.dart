import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:harbor/shared/widgets/harbor_loader.dart';

void main() {
  testWidgets('loads the crystal water droplet animation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: HarborLoader())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
