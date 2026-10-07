import 'package:chop_chop_africa/Pages/home%20page/order_direct/order_card.dart';
import 'package:chop_chop_africa/Pages/home%20page/order_direct/track_order.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/order_detail_model.dart';
import '../../../backend/order_provider.dart';
import '../../../backend/socket_service.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class OnGoing extends StatefulWidget {
  const OnGoing({super.key});

  @override
  State<OnGoing> createState() => _OnGoingState();
}

class _OnGoingState extends State<OnGoing> {
  static const String _status = 'ongoing';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _scrollController.addListener(_onScroll);
    // An order moving to a new step changes what this list should show.
    SocketService.instance.addOrderStatusListener(_onOrderStatus);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    SocketService.instance.removeOrderStatusListener(_onOrderStatus);
    super.dispose();
  }

  void _load({bool refresh = true}) {
    Provider.of<OrderProvider>(context, listen: false)
        .getOrders(_status, refresh: refresh);
  }

  void _onOrderStatus(OrderStatusEvent _) {
    if (mounted) _load();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final bool nearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearBottom &&
        provider.hasMore[_status] == true &&
        provider.loadingOrders[_status] != true) {
      _load(refresh: false);
    }
  }

  Future<void> _confirmCancel(OrderDetailData order) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this order?', style: TextStyle(fontSize: 17)),
        content: Text(
          'Your payment for order #${order.code ?? ''} will be refunded to your wallet.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Cancel order',
                style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final String? message = await UiUtils.runBlocking(
      context,
      'Cancelling your order',
      () => provider.cancelOrder(order.id!),
      subtitle: 'Refunding to your wallet — this takes a moment.',
    );
    if (!mounted || message == null) return;
    UiUtils.showSnackBarFromTop(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final List<OrderDetailData> items = provider.orders[_status] ?? [];
        final bool loading = provider.loadingOrders[_status] == true;

        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => await provider.getOrders(_status, refresh: true),
            child: ListView(
              children: [
                SizedBox(height: 25.pH),
                if (loading && provider.loadedOnce[_status] != true)
                  const Center(child: CircularProgressIndicator())
                else
                  _empty(),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => await provider.getOrders(_status, refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: items.length + (provider.hasMore[_status] == true ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final order = items[index];
              return OrderCard(
                order: order,
                actionLabel: 'Track Order',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackOrder(orderId: order.id!),
                  ),
                ),
                // Once a rider has the order it is on its way, so only offer
                // cancelling while it is still with the vendor.
                secondaryLabel: (order.status ?? 0) <= 2 ? 'Cancel' : null,
                onSecondary: () => _confirmCancel(order),
              );
            },
          ),
        );
      },
    );
  }

  Widget _empty() => Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 46, color: Colors.grey.shade400),
          1.gap,
          UiUtils.subTitles('No ongoing orders', 15),
          0.5.gap,
          Text(
            'Orders you place will show up here while they are on the way.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          1.gap,
          Text('Pull down to refresh',
              style: TextStyle(fontSize: 12, color: IAColors.primary)),
        ],
      );
}
