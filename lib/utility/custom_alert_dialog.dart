import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final double? customWidth;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final ImageProvider? backgroundImage;
  final BoxFit? backgroundImageFit;
  final AlignmentGeometry? backgroundImageAlignment;
  final double? backgroundImageOpacity;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
    this.customWidth,
    this.borderRadius,
    this.backgroundColor,
    this.backgroundImage,
    this.backgroundImageFit,
    this.backgroundImageAlignment,
    this.backgroundImageOpacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the dialog width
    // Default to standard AlertDialog width if customWidth is not provided
    // Ensure dialog doesn't exceed 90% of screen width
    final double dialogWidth = customWidth != null
        ? customWidth!.clamp(0, screenWidth * 0.9)
        : screenWidth * 0.9;

    return Dialog(
      // Remove default padding to have more control
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent, // Make transparent to show background image
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          // Allow height to adjust based on content
          minHeight: 100,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).dialogBackgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(14),
            image: backgroundImage != null
                ? DecorationImage(
              image: backgroundImage!,
              fit: backgroundImageFit ?? BoxFit.cover,
              alignment: backgroundImageAlignment ?? Alignment.center,
              opacity: backgroundImageOpacity ?? 1.0,
            )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                title,
                const SizedBox(height: 16),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    child: content,
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Column(
                    children: actions.map((action) {
                      return Container(
                        constraints: BoxConstraints(
                          maxWidth: dialogWidth - 48.0, // Account for padding
                        ),
                        child: action,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}