import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loaded automatically by `flutter test` for everything under `test/`.
///
/// Golden tests compare rendered pixels, and the same widget tree does not
/// rasterise identically on two different machines - text anti-aliasing and
/// shadow dithering differ with the GPU and the OS build. Our references
/// were rendered on a developer laptop, so on Codemagic's build machine
/// eleven of them failed by between 2 and 378 pixels, which is at most
/// 0.08% of the image. Nothing was actually wrong with any of them.
///
/// An exact-match comparator therefore cannot be used in CI at all: it
/// either fails every run or has to be ignored, and a test that is always
/// ignored is not a test. Allowing a small percentage through keeps the
/// check meaningful, because the failures worth catching - a widget that
/// moved, a colour that changed, text that now overflows - shift whole
/// regions of the image and land one to two orders of magnitude above this.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  goldenFileComparator = _TolerantGoldenComparator(
    (goldenFileComparator as LocalFileComparator).basedir,
  );
  await testMain();
}

class _TolerantGoldenComparator extends LocalFileComparator {
  /// Six times the largest difference observed between a laptop and a
  /// Codemagic Mac mini M2, and still far below any real regression.
  static const double _tolerance = 0.005; // 0.5%

  // LocalFileComparator takes the path of a test file and keeps its
  // directory, so this hands back the directory it was given.
  _TolerantGoldenComparator(Uri basedir)
      : super(Uri.parse('$basedir/flutter_test_config.dart'));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (result.passed) return true;

    if (result.diffPercent <= _tolerance) {
      debugPrint('Golden "$golden" differs by '
          '${(result.diffPercent * 100).toStringAsFixed(3)}%, '
          'within the ${(_tolerance * 100).toStringAsFixed(1)}% tolerance.');
      return true;
    }

    // Over the line: write the diff images out and fail as usual.
    throw FlutterError(await generateFailureOutput(result, golden, basedir));
  }
}
