import 'package:chop_chop_africa/Pages/home%20page/home%20direct/home.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendors.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/models/all_address_model.dart';
import 'package:chop_chop_africa/backend/models/productCategoryModel.dart';
import 'package:chop_chop_africa/backend/models/profile_model.dart';
import 'package:chop_chop_africa/backend/models/store_detail_model.dart';
import 'package:chop_chop_africa/backend/models/top_stores_model.dart';
import 'package:chop_chop_africa/backend/models/user_stores_model.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/custom%20widgets/pressable.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/google_fonts_offline.dart';

/// A long name and a five-figure price, which is what actually broke the
/// layouts: short demo strings hid both the overflow and the missing commas.
const _longName = 'Asun Fried Rice with Peppered Turkey and Plantain';

class FakeProfileProvider extends ProfileProvider {
  FakeProfileProvider() {
    getAllProfileInfo = ProfileModel.fromJson({
      'data': {'firstName': 'Alex', 'lastName': 'Osuya'}
    });
  }

  @override
  Future<ProfileModel?> getProfile() async => getAllProfileInfo;
}

class FakeAddressProvider extends AddressProvider {
  FakeAddressProvider() {
    defaultAddress = AddressList(
      id: 'a1',
      defaut: true,
      address: '25, Hassan Abiodun Street, Oluyole Estate, Ibadan, Oyo State',
      latitude: 7.3,
      longitude: 3.9,
    );
    addressList = [defaultAddress!];
  }

  @override
  Future<AllAddressesModel?> getAllAddresses() async => null;
}

class FakeStoreProvider extends StoreProvider {
  FakeStoreProvider() {
    getTopVendors = [
      TopStoresData(id: 's1', name: 'Chicken Republic Ring Road', logo: null,
          deliveryTime: '30-45 mins', openTime: '08:00', closeTime: '22:00',
          averageRating: 4.5, totalRatings: 128),
      TopStoresData(id: 's2', name: 'Kilimanjaro', logo: null,
          deliveryTime: '15 mins', openTime: '8', closeTime: '9 pm'),
    ];
    getTopStores = getTopVendors;
    allStoresList = [
      Record(id: 's1', name: 'Chicken Republic Ring Road', logo: null,
          deliveryTime: '30-45 mins', openTime: '08:00', closeTime: '22:00',
          averageRating: 4.5, totalRatings: 128),
    ];
    getAllProductCategories = ProductCategoryModel.fromJson({
      'data': [
        {'id': 'c1', 'name': 'Top Sellers'},
        {'id': 'c2', 'name': 'Deals'},
      ]
    });
    getStoreDetailList = [
      StoreDetailRecord(id: 'p1', name: _longName, price: 12550, banner: null),
      StoreDetailRecord(id: 'p2', name: 'Jollof Rice', price: 3200, banner: null),
      StoreDetailRecord(
          id: 'p3',
          name: 'Golden Penny Semovita 10kg Refill Pack',
          price: 18750,
          banner: null),
      StoreDetailRecord(id: 'p4', name: 'Milo', price: 950, banner: null),
    ];
  }

  @override
  Future<void> fetchStores(String type, String lat, String long,
      {bool loadMore = false}) async {}
  @override
  Future<void> fetchStoreDetail(String id, String? category,
      {bool loadMore = false}) async {}
  // The real one empties the list the screen is about to render.
  @override
  void clearStoreDetail() {}
  @override
  void clearAllDetail() {}
}

Widget _wrap(Widget screen) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ProfileProvider>(create: (_) => FakeProfileProvider()),
      ChangeNotifierProvider<AddressProvider>(create: (_) => FakeAddressProvider()),
      ChangeNotifierProvider<StoreProvider>(create: (_) => FakeStoreProvider()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: IATheme.getLightTheme(),
        home: screen,
      ),
    ),
  );
}

Future<void> _shoot(WidgetTester tester, Widget screen, String name) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_wrap(screen));
  await tester.pumpAndSettle();
  await expectLater(
      find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
}

void main() {
  setUp(useOfflineGoogleFonts);

  testWidgets('home header gives the address room', (tester) async {
    await _shoot(tester, const Home(), 'home');
    expect(find.text('Hello Alex 👋'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
  });

  testWidgets('the supermarket screen says Supermarkets', (tester) async {
    await _shoot(tester, const Vendors(type: 'SUPER_MARKET'), 'supermarkets');
    expect(find.text('Supermarkets'), findsOneWidget);
    expect(find.text('Vendors'), findsNothing);
  });

  testWidgets('the vendor screen still says Vendors', (tester) async {
    await tester.pumpWidget(_wrap(const Vendors(type: 'RESTAURANT')));
    await tester.pumpAndSettle();
    expect(find.text('Vendors'), findsOneWidget);
  });

  testWidgets('vendor detail shows prices with separators', (tester) async {
    await _shoot(
        tester,
        const VendorDetail(
          storeId: 's1',
          storeName: 'Chicken Republic Ring Road',
          deliveryTime: '30-45 mins',
          businessTime: '08:00 - 22:00',
        ),
        'vendor_detail');
    expect(find.text('₦12,550'), findsOneWidget);
    expect(find.text('₦3,200'), findsOneWidget);
    // The rating comes from the API now, not a hardcoded 4.0 (200).
    expect(find.text('New'), findsOneWidget);
    // Opening hours must read in full, never truncated.
    expect(find.text('08:00 - 22:00'), findsOneWidget);

    // Every tile is the same height, however long its product name.
    final tiles = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => (t.data ?? '').startsWith('Golden Penny'));
    expect(tiles.single.maxLines, 1);
    final tall = tester.getSize(find.ancestor(
        of: find.text('Golden Penny Semovita 10kg Refill Pack'),
        matching: find.byType(Pressable)).first);
    final short = tester.getSize(find.ancestor(
        of: find.text('Milo'), matching: find.byType(Pressable)).first);
    expect(tall.height, short.height,
        reason: 'a long name must not make its grid tile taller');
  });

  testWidgets('the product sheet puts the stepper beside Add', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const VendorDetail(
      storeId: 's1',
      storeName: 'Chicken Republic Ring Road',
      deliveryTime: '5-10 mins',
      businessTime: '9 - 7.20 pm',
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_longName));
    await tester.pumpAndSettle();

    expect(find.text('Add 1 for ₦12,550'), findsOneWidget);

    // The quantity and the Add button share a row: same vertical centre.
    final stepper = tester.getCenter(find.text('1'));
    final button = tester.getCenter(find.text('Add 1 for ₦12,550'));
    expect((stepper.dy - button.dy).abs(), lessThan(4),
        reason: 'the stepper should sit beside the button, not above it');
    expect(stepper.dx, lessThan(button.dx));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Add 2 for ₦25,100'), findsOneWidget);

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/product_sheet.png'));
  });
}
