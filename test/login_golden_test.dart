import 'package:chop_chop_africa/Pages/auth_page/login.dart';
import 'package:chop_chop_africa/backend/auth_provider.dart';
import 'package:chop_chop_africa/utility/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/google_fonts_offline.dart';

void main() {
  testWidgets('Login matches the Figma frame', (tester) async {
    useOfflineGoogleFonts();

    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            theme: IATheme.getLightTheme(),
            home: const Login(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Apple and Google are commented out, and the "Or" that separated them
    // from the field went with them.
    expect(find.textContaining('Continue with'), findsNothing);
    expect(find.text('Or'), findsNothing);

    // The field is the height the Figma draws it, and the squashing that
    // came from wrapping it in a fixed 9.5.pH box is gone.
    // The whole decorator, which is the 48 high fill box the Figma draws
    // plus the line held in reserve for a validation error. It used to be
    // wrapped in a fixed 9.5.pH SizedBox that the error line ate into, which
    // is what squashed the field.
    expect(tester.getSize(find.byType(TextFormField)).height, 75);
    expect(tester.getSize(find.byType(TextFormField)).width, 390 - 32);

    final Size cta = tester.getSize(find.byType(ElevatedButton));
    expect(cta.height, 46);
    expect(cta.width, 390 - 32);
    // Sits at the foot of the screen, not floating above it.
    expect(tester.getBottomLeft(find.byType(ElevatedButton)).dy, 844 - 16);

    await expectLater(find.byType(Login),
        matchesGoldenFile('goldens/login.png'));
  });
}
