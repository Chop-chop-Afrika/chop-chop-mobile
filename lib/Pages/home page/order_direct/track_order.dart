import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/order_detail_model.dart';
import '../../../backend/models/order_status.dart';
import '../../../backend/order_provider.dart';
import '../../../backend/profile_provider.dart';
import '../../../backend/socket_service.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

/// Live order tracking. The stepper is driven by `order-status-update` from the
/// socket and the ETA by `rider-location-update`; the REST call fills in the
/// details the events do not carry (rider contact, delivery PIN, address).
class TrackOrder extends StatefulWidget {
  final String orderId;

  const TrackOrder({super.key, required this.orderId});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  /// Latest phase from the socket. Null until the first event, in which case
  /// the step is derived from the coarse `status` the REST call returns.
  String? _phase;
  int? _etaMinutes;
  bool _etaIsEstimate = false;

  @override
  void initState() {
    super.initState();
    _load();

    SocketService.instance.addOrderStatusListener(_onOrderStatus);
    SocketService.instance.addRiderLocationListener(_onRiderLocation);
    SocketService.instance.addReconnectListener(_onReconnect);
    SocketService.instance.connect();
  }

  @override
  void dispose() {
    SocketService.instance.removeOrderStatusListener(_onOrderStatus);
    SocketService.instance.removeRiderLocationListener(_onRiderLocation);
    SocketService.instance.removeReconnectListener(_onReconnect);
    super.dispose();
  }

  void _load() {
    Provider.of<OrderProvider>(context, listen: false)
        .getOrderDetails(widget.orderId);
  }

  void _onOrderStatus(OrderStatusEvent event) {
    if (event.orderId != widget.orderId || !mounted) return;
    setState(() => _phase = event.phase);
    // The event says what changed but not the new details — a rider's name and
    // phone only appear once they are assigned, so refetch quietly.
    Provider.of<OrderProvider>(context, listen: false)
        .getOrderDetails(widget.orderId, silent: true);
  }

  void _onRiderLocation(RiderLocationEvent event) {
    if (event.orderId != widget.orderId || !mounted) return;
    setState(() {
      _etaMinutes = event.etaMinutes;
      _etaIsEstimate = event.isEstimate;
    });
  }

  /// Events are never replayed, so reload whatever happened while offline.
  void _onReconnect() {
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Orders Details', style: TextStyle(fontSize: 16)),
        leading: UiUtils.backButton(context),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(7),
          child: Divider(color: IAColors.veryLightGrey),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          final OrderDetailData? order = orderProvider.orderDetail;

          if (order == null) {
            return Center(
              child: orderProvider.loadingDetail
                  ? const CircularProgressIndicator()
                  : _retry(),
            );
          }

          final int currentStep = _phase != null
              ? OrderPhase.stepFromPhase(_phase)
              : OrderPhase.stepFromStatus(order.status);
          final bool failed = OrderPhase.isFailed(_phase) ||
              OrderPhase.isFailedStatus(order.status);

          return RefreshIndicator(
            onRefresh: () async => await orderProvider
                .getOrderDetails(widget.orderId, silent: true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: [
                  1.gap,
                  UiUtils.subTitles('Hi ${_firstName(context)}', 17),
                  0.5.gap,
                  Text(_headline(order, failed), style: TextStyle(fontSize: 14)),
                  2.gap,
                  if (order.deliveryConfirmationCode != null && !failed)
                    _confirmationCode(order.deliveryConfirmationCode!),
                  if (order.deliveryConfirmationCode != null && !failed) 2.gap,
                  if (order.hasRider) ...[
                    UiUtils.subTitles('Contact Dispatch', 15),
                    2.gap,
                    _riderRow(order),
                    3.gap,
                  ],
                  _stepper(currentStep, failed, order),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _retry() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Could not load this order', style: TextStyle(fontSize: 14)),
          1.gap,
          TextButton(onPressed: _load, child: const Text('Try again')),
        ],
      );

  String _firstName(BuildContext context) =>
      Provider.of<ProfileProvider>(context, listen: false)
          .getAllProfileInfo
          ?.data
          ?.firstName ??
      'there';

  String _headline(OrderDetailData order, bool failed) {
    if (failed) return OrderPhase.labelFor(_phase, order.status);
    if (_etaMinutes != null) {
      return _etaIsEstimate
          ? 'Your order arrives in about $_etaMinutes mins'
          : 'Your order arrives in $_etaMinutes mins';
    }
    return order.statusText ?? OrderPhase.labelFor(_phase, order.status);
  }

  Widget _confirmationCode(String code) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xffFDF2DF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery confirmation codes', style: TextStyle(fontSize: 14)),
          UiUtils.subTitles('Show this code to your rider', 15),
          1.5.gap,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: code.split("").map((char) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  char,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _riderRow(OrderDetailData order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: order.rider?.avatar != null
                  ? NetworkImage(order.rider!.avatar!)
                  : null,
              child: order.rider?.avatar == null
                  ? const Icon(Icons.person_outline)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name', style: TextStyle(fontSize: 13)),
                  UiUtils.subTitles(order.riderName, 16),
                ],
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () => UiUtils.launchUrl('tel:${order.rider!.phone}'),
          style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
          child: Text('Call Rider'),
        ),
      ],
    );
  }

  Widget _stepper(int currentStep, bool failed, OrderDetailData order) {
    if (failed) {
      return Container(
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
              child: Text(
                OrderPhase.labelFor(_phase, order.status),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: OrderPhase.steps.length,
      itemBuilder: (context, index) {
        final OrderStep step = OrderPhase.steps[index];
        final bool reached = index <= currentStep;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Checkbox(
                    side: BorderSide(width: 1, color: Colors.grey.shade400),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    value: reached,
                    // The stepper reflects the order's progress; it is not an
                    // input, so taps do nothing.
                    onChanged: null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      UiUtils.subTitles(step.title, 14),
                      Text(
                        step.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
}
