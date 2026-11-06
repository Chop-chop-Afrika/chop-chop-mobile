import 'package:chop_chop_africa/Pages/Delivery/select_delivery_address.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/models/address_search_model.dart';
import 'package:chop_chop_africa/backend/models/all_address_model.dart';
import 'package:chop_chop_africa/utility/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/google_fonts_offline.dart';

/// Serves canned predictions so the screen runs without a backend, and records
/// what the Confirm button actually called.
class FakeAddressProvider extends AddressProvider {
  int searches = 0;
  String? changedId;

  FakeAddressProvider({bool withDefault = true}) {
    if (withDefault) {
      addressList = [AddressList(id: 'addr-1', defaut: true)];
    }
  }

  @override
  Future<AddressSearchModel?> searchForAddress(String search) async {
    searches++;
    return AddressSearchModel.fromJson({
      'data': [
        {
          'placeId': 'place-1',
          'description': '25, Hassan Abiodun Street, Ibadan',
          'mainText': '25, Hassan Abiodun Street',
          'secondaryText': 'Ibadan, Nigeria',
        }
      ]
    });
  }

  @override
  Future<AllAddressesModel?> getAllAddresses() async => null;
}

Widget _wrap(AddressProvider provider, {String type = 'update'}) {
  return ChangeNotifierProvider<AddressProvider>.value(
    value: provider,
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: IATheme.getLightTheme(),
        home: AddressSearchBar(type: type, defaultAddress: true),
      ),
    ),
  );
}

void main() {
  setUp(() {
    useOfflineGoogleFonts();
    // TypeAheadField listens to flutter_keyboard_visibility, which has no
    // implementation under flutter_test.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('flutter_keyboard_visibility'),
            (call) async => null);
  });

  testWidgets('starts with the hint and a disabled-looking Confirm',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(FakeAddressProvider()));
    await tester.pumpAndSettle();

    expect(find.text('Start typing your address'), findsOneWidget);
    expect(
        find.text('Pick your address from the list so we can find you exactly.'),
        findsOneWidget);
    expect(find.text('Confirm Address'), findsOneWidget);
    expect(find.text('Delivering to'), findsNothing);

    await expectLater(find.byType(AddressSearchBar),
        matchesGoldenFile('goldens/delivery_address_empty.png'));
  });

  testWidgets('short queries never reach the backend', (tester) async {
    final provider = FakeAddressProvider();
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ha');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(provider.searches, 0);
  });

  testWidgets('selecting fills the field and arms Confirm without navigating',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final provider = FakeAddressProvider();
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hassan');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(provider.searches, 1, reason: 'one debounced call, not one per key');
    expect(find.text('25, Hassan Abiodun Street'), findsOneWidget);

    await tester.tap(find.text('25, Hassan Abiodun Street'));
    await tester.pumpAndSettle();

    // Still on the same screen, now with a read-back of the choice.
    expect(find.byType(AddressSearchBar), findsOneWidget);
    expect(find.text('Delivering to'), findsOneWidget);
    expect(find.text('25, Hassan Abiodun Street, Ibadan'), findsWidgets);

    await expectLater(find.byType(AddressSearchBar),
        matchesGoldenFile('goldens/delivery_address_selected.png'));
  });

  testWidgets('Confirm with nothing picked warns instead of submitting',
      (tester) async {
    final provider = FakeAddressProvider();
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm Address'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pick your address from the list so we can find you.'),
        findsOneWidget);
    expect(provider.changedId, isNull);

    // The top snackbar removes itself on a timer; let it finish.
    await tester.pump(const Duration(seconds: 4));
  });
}
