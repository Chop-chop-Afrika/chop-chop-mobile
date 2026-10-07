import 'package:chop_chop_africa/Pages/home%20page/order_direct/order_card.dart';
import 'package:chop_chop_africa/Pages/home%20page/order_direct/view_order.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/order_detail_model.dart';
import '../../../backend/order_provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class Completed extends StatefulWidget {
  const Completed({super.key});

  @override
  State<Completed> createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  static const String _status = 'completed';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _load({bool refresh = true}) {
    Provider.of<OrderProvider>(context, listen: false)
        .getOrders(_status, refresh: refresh);
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
                actionLabel: 'View Order',
                onAction: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewOrder(order: order),
                    ),
                  );
                  // A rating submitted on the details page changes this row.
                  if (mounted) _load();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _empty() => Column(
        children: [
          Icon(Icons.check_circle_outline, size: 46, color: Colors.grey.shade400),
          1.gap,
          UiUtils.subTitles('No completed orders yet', 15),
          0.5.gap,
          Text(
            'Delivered orders will appear here so you can view or rate them.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          1.gap,
          Text('Pull down to refresh',
              style: TextStyle(fontSize: 12, color: IAColors.primary)),
        ],
      );
}
