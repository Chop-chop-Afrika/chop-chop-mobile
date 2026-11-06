import 'package:flutter/material.dart';

import '../utility/iacolors.dart';

/// Wraps a scrollable so it can be pulled to reload.
///
/// Every screen that had a refresh before was wired up separately, with its
/// own colours and displacement. This is the one place that decides how a
/// refresh looks, so all of them now match.
///
/// Note for callers: `RefreshIndicator` only fires if its scrollable will
/// overscroll. A `SingleChildScrollView`, or a list shorter than the screen,
/// will not unless it is given [AlwaysScrollableScrollPhysics] — which is why
/// several screens felt like refresh "did not work" rather than "was absent".
class Refreshable extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const Refreshable({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// Use on any scrollable placed inside a [Refreshable].
  static const ScrollPhysics physics =
      AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: IAColors.primary,
      backgroundColor: IAColors.white,
      strokeWidth: 2.5,
      displacement: 28,
      child: child,
    );
  }
}
