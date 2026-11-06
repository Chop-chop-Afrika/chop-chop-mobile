import 'package:chop_chop_africa/Pages/home%20page/order_direct/order_card.dart';
import 'package:chop_chop_africa/backend/models/order_detail_model.dart';
import 'package:chop_chop_africa/custom%20widgets/order_tile.dart';
import 'package:chop_chop_africa/utility/money.dart';
import 'package:chop_chop_africa/utility/theme.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/google_fonts_offline.dart';

/// The name that broke the old layout: far wider than the room a ListTile
/// left once a thumbnail, a price and a stepper had taken their share.
const _longDish =
    'Asun Fried Rice with Peppered Turkey, Plantain and Coleslaw';
const _longStore = 'Chicken Republic Ring Road Ibadan Branch Two';

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        theme: IATheme.getLightTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );

void main() {
  Future<void> _shoot(WidgetTester tester, Widget child, String name) async {
    useOfflineGoogleFonts();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(child));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(Scaffold), matchesGoldenFile('goldens/$name.png'));
  }

  testWidgets('an order card fits a long store name', (tester) async {
    await _shoot(
      tester,
      OrderCard(
        order: OrderDetailData(
          code: 'CC-10482',
          total: 12550,
          status: 1,
          statusText: 'Preparing',
          createdAt: '2026-11-02T10:30:00.000Z',
          stores: OrderStore(id: 's1', name: _longStore),
          cart: [OrderCartItem(), OrderCartItem(), OrderCartItem()],
        ),
        actionLabel: 'Track Order',
        onAction: () {},
        secondaryLabel: 'Cancel',
        onSecondary: () {},
      ),
      'order_card',
    );

    // Truncated with an ellipsis rather than chopped at a character count,
    // and never wrapped onto a second line.
    final Text title = tester.widget<Text>(find.text(_longStore));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);

    // Totals are in naira. This read '£12,550.00' before, formatted with an
    // en_GB locale.
    expect(find.textContaining('₦12,550'), findsOneWidget);
    expect(find.textContaining('£'), findsNothing);
  });

  testWidgets('a cart line fits a long dish name beside its stepper',
      (tester) async {
    await _shoot(
      tester,
      OrderTile(
        imageUrl: null,
        title: _longDish,
        details: [OrderTileLine(naira(4500), weight: FontWeight.w600)],
        cornerAction: const Icon(Icons.close, size: 16),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quantity', style: IAText.caption()),
            Text('2', style: IAText.body(weight: FontWeight.w700)),
          ],
        ),
      ),
      'cart_line',
    );

    final Text title = tester.widget<Text>(find.text(_longDish));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
  });
}
