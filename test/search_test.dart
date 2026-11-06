import 'package:chop_chop_africa/Pages/home%20page/home%20direct/search_page.dart';
import 'package:chop_chop_africa/backend/models/search_product_model.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendors.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/models/all_address_model.dart';
import 'package:chop_chop_africa/backend/models/user_stores_model.dart';
import 'package:chop_chop_africa/backend/models/productCategoryModel.dart';
import 'package:chop_chop_africa/backend/models/profile_model.dart';
import 'package:chop_chop_africa/backend/models/search_store_model.dart';
import 'package:chop_chop_africa/backend/models/store_detail_model.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/google_fonts_offline.dart';

class _Profile extends ProfileProvider {
  _Profile() {
    getAllProfileInfo = ProfileModel.fromJson({
      'data': {'firstName': 'Alex'}
    });
  }
  @override
  Future<ProfileModel?> getProfile() async => getAllProfileInfo;
}

class _Address extends AddressProvider {
  _Address() {
    defaultAddress = AddressList(
        id: 'a1', defaut: true, address: 'Ibadan', latitude: 7.3, longitude: 3.9);
    addressList = [defaultAddress!];
  }
  @override
  Future<AllAddressesModel?> getAllAddresses() async => null;
}

class _Stores extends StoreProvider {
  int wholeMenuLoads = 0;
  int wholeStoreListLoads = 0;
  int moreSearchPages = 0;

  _Stores() {
    allStoresList = [
      Record(id: 's1', name: 'Shoprite Ring Road', logo: null,
          deliveryTime: '30 mins', openTime: '08:00', closeTime: '22:00'),
      Record(id: 's2', name: 'Spar Dugbe', logo: null,
          deliveryTime: '25 mins', openTime: '08:00', closeTime: '21:00'),
      Record(id: 's3', name: 'Justrite Supermarket', logo: null,
          deliveryTime: '40 mins', openTime: '09:00', closeTime: '20:00'),
    ];
    getAllProductCategories = ProductCategoryModel.fromJson({
      'data': [
        {'id': 'c1', 'name': 'Rice'},
      ]
    });
    getStoreDetailList = [
      StoreDetailRecord(
          id: 'p1', name: 'Jollof Rice', price: 3200, banner: null),
      StoreDetailRecord(
          id: 'p2', name: 'Fried Rice', price: 3500, banner: null),
      StoreDetailRecord(
          id: 'p3',
          name: 'Chicken and Chips',
          description: 'Served with jollof on request',
          price: 4500,
          banner: null),
      StoreDetailRecord(id: 'p4', name: 'Milo', price: 950, banner: null),
    ];
  }

  @override
  Future<void> fetchStoreDetail(String id, String? category,
      {bool loadMore = false}) async {}
  @override
  void clearStoreDetail() {}
  @override
  Future<void> fetchStores(String type, String lat, String long,
      {bool loadMore = false}) async {}
  @override
  void clearAllDetail() {}
  @override
  Future<void> loadRestOfStoreDetail(String storeId, String? category) async {
    wholeMenuLoads++;
  }
  @override
  Future<void> loadRestOfStores(String type, String lat, String long) async {
    wholeStoreListLoads++;
  }
  @override
  Future<void> loadMoreSearchResults() async {
    moreSearchPages++;
  }
  @override
  Future<void> searchEverything(String search, {bool loadMore = false}) async {}
}

Widget _wrap(Widget screen, _Stores stores) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>.value(value: _Profile()),
        ChangeNotifierProvider<AddressProvider>.value(value: _Address()),
        ChangeNotifierProvider<StoreProvider>.value(value: stores),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp(
          theme: IATheme.getLightTheme(),
          home: screen,
        ),
      ),
    );

const _vendor = VendorDetail(
  storeId: 's1',
  storeName: 'Chicken Republic',
  deliveryTime: '30-45 mins',
  businessTime: '08:00 - 22:00',
);

/// The colour an icon actually paints with, theme and all - not the colour
/// its widget was given, which is usually null.
Color _iconColour(WidgetTester tester, IconData icon) {
  final RichText text = tester.widget<RichText>(
      find.descendant(of: find.byIcon(icon), matching: find.byType(RichText)));
  return text.text.style!.color!;
}

void main() {
  group('searching inside one vendor', () {
    testWidgets('the search button opens a field and filters the menu',
        (tester) async {
      useOfflineGoogleFonts();
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final stores = _Stores();
      await tester.pumpWidget(_wrap(_vendor, stores));
      await tester.pumpAndSettle();

      // Everything is on the menu to begin with.
      expect(find.text('Jollof Rice'), findsOneWidget);
      expect(find.text('Milo'), findsOneWidget);
      expect(stores.wholeMenuLoads, 0);

      await tester.tap(find.byType(IconButton).last);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Search Chicken Republic'),
          findsOneWidget);
      // The way back out has to be visible. appBarTheme.foregroundColor was
      // transparent, which painted every Material icon in every app bar
      // invisible and left no way to leave the search.
      expect(_iconColour(tester, Icons.close).opacity, greaterThan(0.0));

      await tester.enterText(find.byType(TextField), 'rice');
      await tester.pumpAndSettle();

      // Matches on name, and on description too - "Chicken and Chips" is
      // described as being served with jollof. That mirrors /user/search,
      // which matches products on their description.
      expect(find.text('Jollof Rice'), findsOneWidget);
      expect(find.text('Fried Rice'), findsOneWidget);
      expect(find.text('Milo'), findsNothing);

      // The rest of the menu was fetched once, when the query appeared, so
      // the filter is not running over a half-loaded list.
      expect(stores.wholeMenuLoads, 1);
    });

    testWidgets('a query that matches nothing says so, and clearing restores',
        (tester) async {
      useOfflineGoogleFonts();
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final stores = _Stores();
      await tester.pumpWidget(_wrap(_vendor, stores));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton).last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'sushi');
      await tester.pumpAndSettle();

      expect(find.text('Nothing matches "sushi"'), findsOneWidget);
      expect(find.text('Jollof Rice'), findsNothing);

      // Closing the search puts the whole menu back.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Jollof Rice'), findsOneWidget);
      expect(find.text('Milo'), findsOneWidget);
    });
  });

  group('searching the vendor list', () {
    testWidgets('the search button filters the supermarkets on screen',
        (tester) async {
      useOfflineGoogleFonts();
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final stores = _Stores();
      await tester.pumpWidget(
          _wrap(const Vendors(type: 'SUPER_MARKET'), stores));
      await tester.pumpAndSettle();

      expect(find.text('Shoprite Ring Road'), findsOneWidget);
      expect(find.text('Spar Dugbe'), findsOneWidget);
      expect(stores.wholeStoreListLoads, 0);

      await tester.tap(find.byType(IconButton).last);
      await tester.pumpAndSettle();
      // The title says Supermarkets on this screen, not Vendors.
      expect(find.widgetWithText(TextField, 'Search supermarkets'),
          findsOneWidget);
      // Opening it fetches the rest of the list, so the filter sees all of it.
      expect(stores.wholeStoreListLoads, 1);

      await tester.enterText(find.byType(TextField), 'spar');
      await tester.pumpAndSettle();
      expect(find.text('Spar Dugbe'), findsOneWidget);
      expect(find.text('Shoprite Ring Road'), findsNothing);

      await tester.enterText(find.byType(TextField), 'aldi');
      await tester.pumpAndSettle();
      expect(find.text('Nothing matches "aldi"'), findsOneWidget);

      expect(_iconColour(tester, Icons.close).opacity, greaterThan(0.0));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Shoprite Ring Road'), findsOneWidget);
      expect(find.text('Justrite Supermarket'), findsOneWidget);
    });
  });

  group('one field searches everything', () {
    Future<void> _open(WidgetTester tester, _Stores stores) async {
      useOfflineGoogleFonts();
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(const SearchPage(), stores));
      await tester.pumpAndSettle();
    }

    testWidgets('one query brings back vendors and items together',
        (tester) async {
      final stores = _Stores();
      stores.searchStores = [
        StoreModelData(
            id: 's1', name: 'Jollof Palace', logo: '', deliveryTime: '20 mins')
      ];
      stores.searchProducts = [
        SearchProductData(id: 'p1', name: 'Jollof Rice', price: 3200),
        SearchProductData(id: 'p2', name: 'Jollof Spaghetti', price: 2800),
      ];

      await _open(tester, stores);
      // There are no Stores/Products tabs to choose between any more.
      expect(find.text('Stores'), findsNothing);
      expect(find.text('Products'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'jollof');
      await tester.pumpAndSettle();

      expect(find.text('Vendors'), findsOneWidget);
      expect(find.text('Jollof Palace'), findsOneWidget);
      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Jollof Rice'), findsOneWidget);
      expect(find.text('Jollof Spaghetti'), findsOneWidget);
    });

    testWidgets('a kind that matched nothing is simply absent',
        (tester) async {
      final stores = _Stores();
      stores.searchProducts = [
        SearchProductData(id: 'p1', name: 'Milo', price: 950),
      ];

      await _open(tester, stores);
      await tester.enterText(find.byType(TextFormField), 'milo');
      await tester.pumpAndSettle();

      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Milo'), findsOneWidget);
      // No vendor matched, so there is no empty Vendors heading.
      expect(find.text('Vendors'), findsNothing);
    });

    testWidgets('nothing at all says so, against what was typed',
        (tester) async {
      final stores = _Stores();
      await _open(tester, stores);
      await tester.enterText(find.byType(TextFormField), 'sushi');
      await tester.pumpAndSettle();
      expect(find.text('Nothing found for "sushi"'), findsOneWidget);
    });

    testWidgets('reaching the end of the results asks for the next page',
        (tester) async {
      final stores = _Stores();
      stores.searchProducts = List.generate(
          20, (i) => SearchProductData(id: 'p$i', name: 'Item $i', price: 100));

      await _open(tester, stores);
      await tester.enterText(find.byType(TextFormField), 'item');
      await tester.pumpAndSettle();

      expect(stores.moreSearchPages, 0);
      await tester.drag(find.byType(ListView), const Offset(0, -4000));
      await tester.pump();
      expect(stores.moreSearchPages, greaterThan(0));
    });

    testWidgets('a page on its way shows a spinner under the results',
        (tester) async {
      final stores = _Stores();
      stores.searchProducts = [
        SearchProductData(id: 'p1', name: 'Milo', price: 950),
      ];
      await _open(tester, stores);
      await tester.enterText(find.byType(TextFormField), 'milo');
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Raised only now: pumpAndSettle cannot settle while a spinner is
      // turning.
      stores.isLoadingMoreSearch = true;
      stores.notifyListeners();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('how the search screen looks', () {
    Future<void> _shoot(WidgetTester tester, _Stores stores, String name,
        {String? type, bool settle = true}) async {
      useOfflineGoogleFonts();
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(const SearchPage(), stores));
      // A turning shimmer never settles, so the loading shot pumps frames
      // rather than waiting for quiet.
      settle ? await tester.pumpAndSettle() : await tester.pump();
      if (type != null) {
        await tester.enterText(find.byType(TextFormField), type);
      }
      settle ? await tester.pumpAndSettle() : await tester.pump();
      await expectLater(
          find.byType(SearchPage), matchesGoldenFile('goldens/$name.png'));
    }

    testWidgets('empty', (tester) async {
      await _shoot(tester, _Stores(), 'search_empty');
    });

    testWidgets('loading', (tester) async {
      final stores = _Stores();
      stores.loadingSearch = true;
      await _shoot(tester, stores, 'search_loading', type: 'jollof', settle: false);
    });

    testWidgets('results', (tester) async {
      final stores = _Stores();
      stores.searchStores = [
        StoreModelData(
            id: 's1', name: 'Jollof Palace', logo: '', deliveryTime: '20 mins')
      ];
      stores.searchProducts = [
        SearchProductData(id: 'p1', name: 'Jollof Rice', price: 3200),
        SearchProductData(id: 'p2', name: 'Jollof Spaghetti', price: 2800),
      ];
      await _shoot(tester, stores, 'search_results', type: 'jollof');
    });
  });

  group('search pagination state', () {
    test('clearing a search resets both cursors', () {
      final stores = StoreProvider();
      stores.storeSearchPage = 4;
      stores.productSearchPage = 7;
      stores.hasNextStoreSearchPage = true;
      stores.hasNextProductSearchPage = true;
      stores.isLoadingMoreSearch = true;
      stores.loadingSearch = true;

      stores.clearSearchResults();

      expect(stores.storeSearchPage, 1);
      expect(stores.productSearchPage, 1);
      expect(stores.hasNextSearchPage, false);
      expect(stores.isLoadingMoreSearch, false);
      // Clearing the field used to leave this true, which left the spinner
      // up in place of the prompt.
      expect(stores.loadingSearch, false);
    });

    test('there is more to fetch while either kind has another page', () {
      final stores = StoreProvider();
      expect(stores.hasNextSearchPage, false);
      stores.hasNextProductSearchPage = true;
      // Stores can run out long before products do, and the list must keep
      // paginating until both have.
      expect(stores.hasNextSearchPage, true);
    });
  });
}
