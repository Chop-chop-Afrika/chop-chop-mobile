import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendors.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/models/all_address_model.dart';
import 'package:chop_chop_africa/backend/models/profile_model.dart';
import 'package:chop_chop_africa/backend/models/user_stores_model.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/custom%20widgets/refreshable.dart';
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
  int refetches = 0;
  _Stores({bool withItems = true}) {
    if (withItems) {
      allStoresList = [
        Record(id: 's1', name: 'Mama Put', deliveryTime: '20 mins',
            openTime: '08:00', closeTime: '22:00', averageRating: 4.2,
            totalRatings: 40),
      ];
    }
  }
  @override
  Future<void> fetchStores(String type, String lat, String long,
      {bool loadMore = false}) async {
    refetches++;
  }
  @override
  void clearAllDetail() {}
}

Widget _wrap(StoreProvider stores) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>(create: (_) => _Profile()),
        ChangeNotifierProvider<AddressProvider>(create: (_) => _Address()),
        ChangeNotifierProvider<StoreProvider>.value(value: stores),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp(
          theme: IATheme.getLightTheme(),
          home: const Vendors(type: 'RESTAURANT'),
        ),
      ),
    );

Future<void> _pullDown(WidgetTester tester) async {
  await tester.fling(find.byType(Refreshable), const Offset(0, 320), 1200);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  setUp(useOfflineGoogleFonts);

  testWidgets('pulling a populated list refetches it', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final stores = _Stores();
    await tester.pumpWidget(_wrap(stores));
    await tester.pumpAndSettle();

    final before = stores.refetches;
    await _pullDown(tester);
    expect(stores.refetches, greaterThan(before));
  });

  testWidgets('pulling an EMPTY list refetches it too', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // The empty state is where the user most wants to retry, and it is the
    // one that silently did not overscroll before.
    final stores = _Stores(withItems: false);
    await tester.pumpWidget(_wrap(stores));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pull down to try again'), findsOneWidget);

    final before = stores.refetches;
    await _pullDown(tester);
    expect(stores.refetches, greaterThan(before),
        reason: 'the empty state must be pullable');
  });
}
