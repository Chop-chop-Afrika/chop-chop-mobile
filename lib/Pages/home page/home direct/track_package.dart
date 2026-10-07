import 'dart:async';

import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/order_status.dart';
import '../../../backend/models/package_model.dart';
import '../../../backend/package_provider.dart';
import '../../../backend/socket_service.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

/// Live tracking for one package delivery.
///
/// Reached straight after booking, so it has to cope with the package still
/// being status 0 — Stripe confirms payment to the backend by webhook, which
/// can land seconds after the checkout webview closes. While that is pending
/// it polls; once paid it relies on `package-status-update` from the socket.
class TrackPackage extends StatefulWidget {
  final String packageId;

  /// True when arriving straight from checkout, which shows the confirmation
  /// banner rather than dropping the user into a bare tracking screen.
  final bool justBooked;

  const TrackPackage({
    super.key,
    required this.packageId,
    this.justBooked = false,
  });

  @override
  State<TrackPackage> createState() => _TrackPackageState();
}

class _TrackPackageState extends State<TrackPackage> {
  String? _phase;
  Timer? _paymentPoll;

  /// Payment confirmation arrives from Stripe's webhook, server side — the app
  /// can only re-read the package until it changes. Give up after a couple of
  /// minutes rather than polling forever: past that it is not a timing issue,
  /// and a dead timer draining the battery helps nobody.
  static const int _maxPaymentPolls = 30;
  int _paymentPolls = 0;
  bool _paymentPollGaveUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    SocketService.instance.addPackageStatusListener(_onPackageStatus);
    SocketService.instance.addReconnectListener(_onReconnect);
    SocketService.instance.connect();
  }

  @override
  void dispose() {
    _paymentPoll?.cancel();
    SocketService.instance.removePackageStatusListener(_onPackageStatus);
    SocketService.instance.removeReconnectListener(_onReconnect);
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    final data = await Provider.of<PackageProvider>(context, listen: false)
        .getPackageDetails(widget.packageId, silent: silent);
    if (!mounted) return;
    // Keep checking until the payment webhook lands, then stop.
    if (PackagePhase.isAwaitingPayment(data?.status)) {
      _startPaymentPoll();
    } else {
      _stopPaymentPoll();
      if (_paymentPollGaveUp) setState(() => _paymentPollGaveUp = false);
    }
  }

  void _startPaymentPoll() {
    if (_paymentPollGaveUp) return;
    _paymentPoll ??= Timer.periodic(const Duration(seconds: 4), (_) {
      if (++_paymentPolls >= _maxPaymentPolls) {
        _stopPaymentPoll();
        if (mounted) setState(() => _paymentPollGaveUp = true);
        return;
      }
      _load(silent: true);
    });
  }

  void _stopPaymentPoll() {
    _paymentPoll?.cancel();
    _paymentPoll = null;
  }

  /// Manual retry after giving up.
  void _retryPaymentCheck() {
    setState(() {
      _paymentPollGaveUp = false;
      _paymentPolls = 0;
    });
    _load(silent: true);
  }

  void _onPackageStatus(PackageStatusEvent event) {
    if (event.packageId != widget.packageId || !mounted) return;
    setState(() => _phase = event.phase);
    _load(silent: true);
  }

  void _onReconnect() {
    if (mounted) _load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Delivery Details', style: TextStyle(fontSize: 16)),
        leading: UiUtils.backButton(context),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(7),
          child: Divider(color: IAColors.veryLightGrey),
        ),
      ),
      body: Consumer<PackageProvider>(
        builder: (context, provider, _) {
          final PackageData? pkg = provider.packageDetail;
          if (pkg == null || pkg.id != widget.packageId) {
            return Center(
              child: provider.loadingDetail
                  ? const CircularProgressIndicator()
                  : TextButton(onPressed: _load, child: const Text('Try again')),
            );
          }

          final bool awaiting = PackagePhase.isAwaitingPayment(pkg.status);
          final bool failed = PackagePhase.isFailed(pkg.status);
          final int currentStep = _phase != null
              ? PackagePhase.stepFromPhase(_phase)
              : PackagePhase.stepFromStatus(pkg.status);

          return RefreshIndicator(
            onRefresh: () => _load(silent: true),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                1.gap,
                if (widget.justBooked && !failed) _bookedBanner(awaiting),
                if (widget.justBooked && !failed) 1.5.gap,
                _summary(pkg),
                2.gap,
                if (pkg.deliveryConfirmationCode != null && !failed) ...[
                  _confirmationCode(pkg.deliveryConfirmationCode!),
                  2.gap,
                ],
                if (pkg.hasRider) ...[
                  UiUtils.subTitles('Contact Dispatch', 15),
                  1.gap,
                  _riderRow(pkg),
                  2.gap,
                ],
                if (failed)
                  _failedCard(pkg)
                else if (awaiting)
                  (_paymentPollGaveUp ? _stalledCard() : _awaitingCard())
                else
                  _stepper(currentStep),
                3.gap,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bookedBanner(bool awaiting) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xffE8F5E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UiUtils.subTitles('Delivery booked', 15),
                  Text(
                    awaiting
                        ? 'We are confirming your payment now.'
                        : 'We are finding a rider for you.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _summary(PackageData pkg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffFBFBFB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pkg.code != null) ...[
              UiUtils.subTitles('Delivery #${pkg.code}', 15),
              0.5.gap,
            ],
            _addressRow(Icons.trip_origin, 'From', pkg.pickupAddress),
            0.8.gap,
            _addressRow(Icons.place_outlined, 'To', pkg.dropOffAddress),
            0.8.gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(PackagePhase.labelFor(pkg.status),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: IAColors.primary)),
                Text('£${(pkg.total ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );

  Widget _addressRow(IconData icon, String label, String? value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                Text(value ?? '', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      );

  Widget _awaitingCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffFDF2DF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirming your payment with the bank. This page updates on '
                'its own — you can leave and come back.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
      );

  /// Shown when confirmation has not arrived after a couple of minutes. At
  /// that point it is no longer a timing problem, so say so plainly instead of
  /// spinning indefinitely.
  Widget _stalledCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffFDF2DF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, size: 20, color: Colors.orange.shade700),
                const SizedBox(width: 10),
                Expanded(child: UiUtils.subTitles('Still confirming', 15)),
              ],
            ),
            0.8.gap,
            Text(
              'Your payment has not been confirmed yet. If you were charged, '
              'it will appear here once it clears — no need to pay again. '
              'Contact support if it stays like this.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            0.5.gap,
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _retryPaymentCheck,
                child: const Text('Check again'),
              ),
            ),
          ],
        ),
      );

  Widget _failedCard(PackageData pkg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(PackagePhase.labelFor(pkg.status),
                  style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      );

  Widget _confirmationCode(String code) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffFDF2DF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery confirmation code',
                style: TextStyle(fontSize: 14)),
            UiUtils.subTitles('Show this code to your rider', 15),
            1.5.gap,
            Row(
              children: code.split('').map((char) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(char,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ],
        ),
      );

  Widget _riderRow(PackageData pkg) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: pkg.rider?.avatar != null
                    ? NetworkImage(pkg.rider!.avatar!)
                    : null,
                child: pkg.rider?.avatar == null
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rider', style: TextStyle(fontSize: 13)),
                    UiUtils.subTitles(pkg.riderName, 16),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => UiUtils.launchUrl('tel:${pkg.rider!.phone}'),
            style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
            child: const Text('Call Rider'),
          ),
        ],
      );

  Widget _stepper(int currentStep) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: PackagePhase.steps.length,
        itemBuilder: (context, index) {
          final step = PackagePhase.steps[index];
          final bool reached = index <= currentStep;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Checkbox(
                  side: BorderSide(width: 1, color: Colors.grey.shade400),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  value: reached,
                  onChanged: null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UiUtils.subTitles(step.title, 14),
                    Text(step.subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Divider(color: Colors.grey.shade200),
        ),
      );
}
