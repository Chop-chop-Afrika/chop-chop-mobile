import 'package:flutter/material.dart';

import '../utility/iacolors.dart';

/// Dips slightly while held, so taps on cards and tiles feel answered.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A network image that fades in rather than popping, and falls back to a
/// plain tinted block instead of a broken-image glyph.
class NetworkThumb extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BorderRadius radius;
  final BoxFit fit;

  const NetworkThumb({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.radius = const BorderRadius.all(Radius.circular(8)),
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: IAColors.veryLightGrey,
        borderRadius: radius,
      ),
      child: Icon(Icons.restaurant_outlined,
          color: IAColors.lightGrey, size: 28),
    );

    if (url == null || url!.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            child: frame == null ? placeholder : child,
          );
        },
      ),
    );
  }
}
