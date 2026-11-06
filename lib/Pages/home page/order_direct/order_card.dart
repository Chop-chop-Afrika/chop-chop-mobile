import 'package:chop_chop_africa/custom%20widgets/order_tile.dart';
import 'package:chop_chop_africa/utility/money.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../backend/models/order_detail_model.dart';
import '../../../backend/models/order_status.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/typography.dart';

/// The row shown for one order in the Ongoing and Completed tabs. Keeps the
/// card styling the tabs already used, with the placeholder text replaced by
/// real order data.
class OrderCard extends StatelessWidget {
  final OrderDetailData order;

  /// Label for the action link under the card, e.g. 'Track Order'.
  final String actionLabel;
  final VoidCallback onAction;

  /// Shown as a second, muted link — used for Cancel on ongoing orders.
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const OrderCard({
    super.key,
    required this.order,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  // Was formatted as £ with an en_GB locale, so every order in the list
  // was priced in pounds.
  String get _money => naira(order.total);

  String get _placed {
    final raw = order.createdAt;
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '';
    return DateFormat('d MMM, h:mm a').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = order.cart?.length ?? 0;
    final bool failed = OrderPhase.isFailedStatus(order.status);

    return OrderTile(
      onTap: onAction,
      imageUrl: order.stores?.logo,
      title: order.stores?.name ?? 'Store',
      details: [
        OrderTileLine(
          'Order #${order.code ?? ''}'
          '${itemCount > 0 ? '  ·  $itemCount item${itemCount == 1 ? '' : 's'}' : ''}',
        ),
        OrderTileLine(
          '$_money${_placed.isEmpty ? '' : '  ·  $_placed'}',
        ),
      ],
      // The status used to be a third line of body text. As a chip it reads
      // at a glance, which is the one thing you scan this list for.
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (failed ? Colors.red.shade400 : IAColors.primary)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          order.statusText ?? OrderPhase.labelFor(null, order.status),
          style: IAText.micro(
            color: failed ? Colors.red.shade400 : IAColors.primary,
            weight: FontWeight.w600,
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: secondaryLabel == null
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: IAText.label(
                  color: IAColors.primary, weight: FontWeight.w600),
            ),
          ),
          if (secondaryLabel != null)
            TextButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel!,
                  style: IAText.label(color: IAColors.darkGrey)),
            ),
        ],
      ),
    );
  }
}
