// google_fonts downloads Plus Jakarta Sans at runtime, which flutter_test
// blocks, leaving goldens full of Ahem boxes. Instead, hand the package a
// stub asset manifest listing the faces it wants and serve a real font off
// this machine for those keys. `assetManifest` is the one injection seam the
// package offers, so reaching into `src/` is deliberate.
//
// ignore_for_file: implementation_imports
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/src/google_fonts_base.dart' as google_fonts_base;

const _fontDir = 'testfonts/';

/// Every Plus Jakarta Sans weight `IATheme` asks for.
const _variants = <String>[
  'PlusJakartaSans-Regular',
  'PlusJakartaSans-Medium',
  'PlusJakartaSans-SemiBold',
  'PlusJakartaSans-Bold',
  'PlusJakartaSans-ExtraBold',
];

class _StubManifest implements AssetManifest {
  @override
  List<String> listAssets() => [for (final v in _variants) '$_fontDir$v.ttf'];

  @override
  List<AssetMetadata> getAssetVariants(String key) => const <AssetMetadata>[];
}

/// Call before `pumpWidget` in any test that renders a themed screen.
void useOfflineGoogleFonts() {
  final bytes = File(r'/System/Library/Fonts/Supplemental/Arial.ttf')
      .readAsBytesSync()
      .buffer
      .asByteData();

  google_fonts_base.assetManifest = _StubManifest();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final raw = utf8.decode(message!.buffer.asUint8List());
    if (raw.startsWith(_fontDir)) return bytes;
    // Everything else is a genuine asset. `flutter test` stages them (and the
    // manifests Image.asset needs) under build/unit_test_assets, where names
    // keep their percent-encoding; the project tree has them decoded.
    final decoded = Uri.decodeFull(raw);
    for (final candidate in [
      File('build/unit_test_assets/$raw'),
      File('build/unit_test_assets/$decoded'),
      File(decoded),
      File(raw),
    ]) {
      if (candidate.existsSync()) {
        return candidate.readAsBytesSync().buffer.asByteData();
      }
    }
    return null;
  });
}
