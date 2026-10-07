import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../backend/models/order_detail_model.dart';
import '../../../backend/models/order_status.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

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

  String get _money =>
      '£${NumberFormat("#,##0.00", "en_GB").format(order.total ?? 0)}';

  String get _placed {
    final raw = order.createdAt;
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '';
    return DateFormat('d MMM, h:mm a').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final String? logo = order.stores?.logo;
    final int itemCount = order.cart?.length ?? 0;

    return Column(
      children: [
        1.gap,
        Card(
          elevation: 1,
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8, bottom: 8),
            child: ListTile(
              onTap: onAction,
              leading: Container(
                height: 15.pW,
                width: 15.pW,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey.shade200,
                  image: logo != null && logo.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(logo), fit: BoxFit.cover)
                      : null,
                ),
                child: logo == null || logo.isEmpty
                    ? Icon(Icons.storefront_outlined,
                        size: 20, color: Colors.grey.shade500)
                    : null,
              ),
              title: UiUtils.subTitles(order.stores?.name ?? 'Store', 14),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.code ?? ''}'
                    '${itemCount > 0 ? '  ·  $itemCount item${itemCount == 1 ? '' : 's'}' : ''}',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    '$_money${_placed.isEmpty ? '' : '  ·  $_placed'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  0.3.gap,
                  Text(
                    order.statusText ??
                        OrderPhase.labelFor(null, order.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: OrderPhase.isFailedStatus(order.status)
                          ? Colors.red.shade400
                          : IAColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: secondaryLabel == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: IAColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: IAColors.primary,
                ),
              ),
            ),
            if (secondaryLabel != null)
              TextButton(
                onPressed: onSecondary,
                child: Text(
                  secondaryLabel!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
