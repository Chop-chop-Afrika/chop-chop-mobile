import 'package:chop_chop_africa/custom%20widgets/pressable.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:flutter/material.dart';

/// One row in the cart or the orders list.
///
/// The three screens that list orders each built their own `ListTile` inside
/// a `Card`, and each ran out of room differently: a ListTile gives its
/// title whatever is left after the leading and trailing widgets, so a long
/// dish name either overflowed or had to be chopped at a fixed character
/// count. Here the title is the one thing that flexes, and it ellipsises
/// rather than being cut mid-word.
///
/// [details] are the lines under the title, [trailing] sits to the right of
/// them, and [footer] spans the full width below a divider — which is where
/// controls with any real width, like a quantity stepper, belong.
class OrderTile extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final List<Widget> details;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;

  /// A small action in the top-right, such as removing the line.
  final Widget? cornerAction;

  const OrderTile({
    super.key,
    required this.title,
    this.imageUrl,
    this.details = const [],
    this.trailing,
    this.footer,
    this.onTap,
    this.cornerAction,
  });

  @override
  Widget build(BuildContext context) {
    final Widget body = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // A hairline instead of the old drop shadow: the cards sit on a
        // near-white page, where elevation read as a grey smudge.
        border: Border.all(color: IAColors.appBarLightGrey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworkThumb(
                  url: imageUrl,
                  height: 52,
                  width: 52,
                  radius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: IAText.subtitle(),
                            ),
                          ),
                          if (cornerAction != null) cornerAction!,
                        ],
                      ),
                      if (details.isNotEmpty) const SizedBox(height: 6),
                      for (final line in details) ...[
                        line,
                        const SizedBox(height: 3),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 10),
                  trailing!,
                ],
              ],
            ),
            if (footer != null) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: IAColors.veryLightGrey),
              const SizedBox(height: 6),
              footer!,
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return body;
    return Pressable(onTap: onTap, scale: 0.99, child: body);
  }
}

/// A short muted line under an order's title, e.g. "3 items · ₦12,550".
class OrderTileLine extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? weight;

  const OrderTileLine(this.text, {super.key, this.color, this.weight});

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: IAText.caption(
            color: color ?? IAColors.darkGrey, weight: weight),
      );
}
