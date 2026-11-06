import 'package:chop_chop_africa/Pages/home%20page/profile%20direct/profile_details.dart';
import 'package:chop_chop_africa/backend/models/profile_model.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/utility/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/google_fonts_offline.dart';

/// Stands in for the real provider so the screen renders without a network.
class FakeProfileProvider extends ProfileProvider {
  @override
  Future<ProfileModel?> getProfile() async {
    getAllProfileInfo = ProfileModel.fromJson({
      'data': {
        'id': '1',
        'email': 'Oluwatosinalo8@gmail.com',
        'firstName': 'Tosin',
        'lastName': 'Alo',
        'phone': '+2348168049388',
        'dob': '1995-06-08T00:00:00.000Z',
      }
    });
    notifyListeners();
    return getAllProfileInfo;
  }
}

void main() {
  testWidgets('Profile Details renders with only the phone editable',
      (tester) async {
    useOfflineGoogleFonts();

    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileProvider>(
        create: (_) => FakeProfileProvider(),
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            theme: IATheme.getLightTheme(),
            home: const ProfileDetails(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tosin'), findsOneWidget);
    expect(find.text('Alo'), findsOneWidget);
    expect(find.text('Oluwatosinalo8@gmail.com'), findsOneWidget);
    expect(find.text('1995-06-08'), findsOneWidget);
    expect(
        find.text(
            'Contact support to change your name, email or date of birth.'),
        findsOneWidget);

    // Every field but the phone number refuses input.
    for (final value in ['Tosin', 'Alo', 'Oluwatosinalo8@gmail.com', '1995-06-08']) {
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.ancestor(
              of: find.text(value), matching: find.byType(TextFormField)).first,
          matching: find.byType(TextField),
        ),
      );
      expect(field.readOnly, isTrue, reason: '$value should not be editable');
    }

    await expectLater(
      find.byType(ProfileDetails),
      matchesGoldenFile('goldens/profile_details.png'),
    );
  });
}
