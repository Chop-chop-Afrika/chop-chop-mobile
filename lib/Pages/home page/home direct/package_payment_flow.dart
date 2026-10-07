import 'package:chop_chop_africa/Pages/home%20page/order_direct/stripe_checkout.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/package_model.dart';
import '../../../backend/order_provider.dart';
import '../../../backend/package_provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

/// Everything needed to book one package delivery. Shared by the send and
/// receive screens, which collect the same fields and differ only in [mode].
class PackageBooking {
  final String pickupAddress;
  final String dropOffAddress;
  final String senderName;
  final String senderPhone;
  final String senderEmail;
  final String receiverName;
  final String receiverPhone;
  final String receiverEmail;
  final String type;
  final String mode; // 'send' or 'receive'
  final num pickupLatitude;
  final num pickupLongitude;
  final num dropOffLatitude;
  final num dropOffLongitude;

  const PackageBooking({
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.senderName,
    required this.senderPhone,
    required this.senderEmail,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverEmail,
    required this.type,
    required this.mode,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropOffLatitude,
    required this.dropOffLongitude,
  });
}

/// Books and pays for a package.
///
/// There is no create endpoint — make-payment creates the package and takes
/// payment in one call. A wallet payment settles in that response; a card
/// payment returns a Stripe Checkout URL. Packages have no payment-status
/// endpoint, so a card payment is confirmed by polling the package itself.
///
/// Returns the package id once paid, or null if the customer backed out or it
/// failed (the reason having been shown already).
Future<String?> runPackagePayment(
  BuildContext context,
  PackageBooking booking,
) async {
  final packageProvider = Provider.of<PackageProvider>(context, listen: false);

  final String? method = await _choosePaymentMethod(context);
  if (method == null || !context.mounted) return null;

  final payment = await UiUtils.runBlocking(
    context,
    'Booking your delivery',
    () => packageProvider.makePackagePayment(
      pickupAddress: booking.pickupAddress,
      dropOffAddress: booking.dropOffAddress,
      senderName: booking.senderName,
      senderPhone: booking.senderPhone,
      senderEmail: booking.senderEmail,
      receiverName: booking.receiverName,
      receiverPhone: booking.receiverPhone,
      receiverEmail: booking.receiverEmail,
      type: booking.type,
      mode: booking.mode,
      pickupLatitude: booking.pickupLatitude,
      pickupLongitude: booking.pickupLongitude,
      dropOffLatitude: booking.dropOffLatitude,
      dropOffLongitude: booking.dropOffLongitude,
      paymentMethod: method,
    ),
  );
  if (payment == null || !context.mounted) return null;

  final String? packageId = payment.packageId;
  if (packageId == null) return null;

  // Remember it until the payment webhook lands — an unpaid package is not in
  // the history list, so this is the only way back to it.
  await packageProvider.rememberPendingPackage(packageId);

  if (payment.needsCardCheckout) {
    final bool returned = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => StripeCheckout(checkoutUrl: payment.checkoutUrl!),
          ),
        ) ??
        false;
    if (!context.mounted) return null;
    if (!returned) {
      UiUtils.showSnackBarFromTop(context, 'Payment was not completed');
      return null;
    }

    // Give the Stripe webhook a short head start, but do not depend on it.
    // The package sits at status 0 until the webhook lands, which can take
    // longer than it is reasonable to block the screen for — so this is a
    // courtesy wait, not a gate. Either way the customer goes to tracking,
    // which keeps polling and shows the payment state honestly.
    await UiUtils.runBlocking(
      context,
      'Confirming your payment',
      () => packageProvider.waitForPackagePayment(packageId),
      subtitle: "This takes a few seconds. Please don't close the app.",
    );
    if (!context.mounted) return null;
  }

  return packageId;
}

/// The API accepts `card` or `wallet` only, same as orders.
Future<String?> _choosePaymentMethod(BuildContext context) {
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);
  // Reuse the wallet balance the order flow already knows how to fetch.
  orderProvider.getWalletBalance();

  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UiUtils.subTitles('How would you like to pay?', 16),
            1.gap,
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.credit_card, size: 20),
              title: const Text('Pay by Card', style: TextStyle(fontSize: 14)),
              subtitle: Text('Visa, Mastercard via Stripe',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              onTap: () => Navigator.of(sheetContext).pop('card'),
            ),
            Divider(color: IAColors.veryLightGrey, height: 1),
            Consumer<OrderProvider>(
              builder: (context, provider, _) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet, size: 20),
                title: Text(
                  provider.walletBalance == null
                      ? 'Wallet Balance'
                      : 'Wallet Balance  £${provider.walletBalance!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text('Debited immediately',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                onTap: () => Navigator.of(sheetContext).pop('wallet'),
              ),
            ),
            1.gap,
          ],
        ),
      ),
    ),
  );
}
