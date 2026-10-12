import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';

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

  const AsyncContent({
    super.key,
    required this.loading,
    required this.isEmpty,
    required this.builder,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.loadingPlaceholder,
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

  Widget _empty(BuildContext context) => Center(
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
      );
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
  Widget build(BuildContext context) => ListView(
        padding: padding,
        children: [
          for (int i = 0; i < count; i++) SkeletonBox(height: itemHeight),
        ],
      );
}
