import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';

import 'refreshable.dart';

import '../utility/iacolors.dart';
import '../utility/uiutils.dart';

/// Renders the three states a fetched list can be in, so screens stop showing
/// a blank page while a request is still running.
///
/// The distinction that matters is [loading] versus genuinely empty: before
/// this, a screen mid-fetch and a screen with no results looked identical.
class AsyncContent extends StatelessWidget {
  final bool loading;
  final bool isEmpty;

  /// Built only when there is something to show.
  final WidgetBuilder builder;

  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;

  /// Shown instead of a spinner on first load, when a list skeleton reads
  /// better than a lone circle.
  final Widget? loadingPlaceholder;

  /// Where the empty state sits. Dead centre suits a short screen, but on a
  /// tall one with nothing else on it the message ends up marooned in the
  /// middle of a lot of white.
  final Alignment emptyAlignment;

  const AsyncContent({
    super.key,
    required this.loading,
    required this.isEmpty,
    required this.builder,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.loadingPlaceholder,
    this.emptyAlignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    // Only show the spinner when there is nothing to show underneath it;
    // a background refresh over existing content should not blank the screen.
    if (loading && isEmpty) {
      return loadingPlaceholder ??
          Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: IAColors.primary,
            ),
          );
    }
    if (isEmpty) return _empty(context);
    return builder(context);
  }

  /// Scrollable even though it holds one short column, so a screen wrapped in
  /// a [Refreshable] can still be pulled when it is empty — which is exactly
  /// when the user most wants to try again.
  Widget _empty(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: Refreshable.physics,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: emptyAlignment,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.pW, vertical: 4.pH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 44, color: Colors.grey.shade400),
              1.gap,
              UiUtils.subTitles(emptyTitle, 15),
              if (emptyMessage != null) ...[
                0.5.gap,
                Text(
                  emptyMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
      ),
          ),
        ),
      );
}

/// Sweeps a soft highlight across whatever it wraps.
///
/// The skeletons were flat grey rectangles that never moved, which reads as
/// a broken layout rather than as something on its way. One controller
/// drives the whole group, so a screenful of boxes costs a single animation.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Honours the system "reduce motion" setting, and keeps widget tests
    // that pumpAndSettle from waiting on a loop that never ends.
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          // Travels from just off one edge to just off the other.
          final double t = _controller.value * 2.4 - 1.2;
          return LinearGradient(
            begin: Alignment(t - 0.35, -0.3),
            end: Alignment(t + 0.35, 0.3),
            colors: [
              Colors.grey.shade200,
              Colors.grey.shade100,
              Colors.grey.shade200,
            ],
          ).createShader(bounds);
        },
        child: child,
      ),
    );
  }
}

/// A grey block that stands in for content while it loads. Several lists use
/// cards, and a few of these read better than a single spinner.
class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsets margin;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width ?? double.infinity,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// A column of [SkeletonBox] rows, for list screens.
class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;
  final EdgeInsets padding;

  const SkeletonList({
    super.key,
    this.count = 5,
    this.itemHeight = 72,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) => Shimmer(
        child: ListView(
          padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (int i = 0; i < count; i++) SkeletonBox(height: itemHeight),
          ],
        ),
      );
}
