import 'package:chop_chop_africa/Pages/home%20page/order_direct/raise_dispute.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/order_detail_model.dart';
import '../../../backend/order_provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

/// Details of a completed order, and where the customer rates the store.
///
/// GET /user/orders already returns the full order — store, cart and totals —
/// so the list hands its object straight over and the page renders with no
/// spinner. It still refreshes quietly in the background to pick up anything
/// that changed since the list was fetched.
class ViewOrder extends StatefulWidget {
  final OrderDetailData order;

  const ViewOrder({super.key, required this.order});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  double _pendingRating = 0;
  bool _submittingRating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .getOrderDetails(widget.order.id!, silent: true);
    });
  }

  String _money(num? amount) =>
      '£${NumberFormat("#,##0.00", "en_GB").format(amount ?? 0)}';

  String _date(String? raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '';
    return DateFormat('EEE d MMM, yyyy @ HH:mm').format(parsed.toLocal());
  }

  Future<void> _submitRating(OrderDetailData order) async {
    if (_pendingRating <= 0 || _submittingRating) return;
    setState(() => _submittingRating = true);
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final bool ok = await provider.rateOrder(order.id!, _pendingRating);
    if (!mounted) return;
    setState(() => _submittingRating = false);
    if (ok) {
      UiUtils.showSnackBarFromTop(context, 'Thanks for rating this store');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Order Details', style: TextStyle(fontSize: 16)),
          leading: UiUtils.backButton(context),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(7),
            child: Divider(color: IAColors.veryLightGrey),
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, provider, _) {
            // Prefer the freshly fetched copy once it arrives, otherwise show
            // what the list already gave us.
            final OrderDetailData order =
                provider.orderDetail?.id == widget.order.id
                    ? provider.orderDetail!
                    : widget.order;

            final items = order.cart ?? [];
            final int itemCount =
                items.fold<int>(0, (sum, i) => sum + (i.quantity ?? 0));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    1.5.gap,
                    _ratingCard(order),
                    2.gap,
                    _deliveryCard(order),
                    2.gap,
                    _storeTile(order, itemCount),
                    if (items.isNotEmpty) ...[
                      1.gap,
                      ...items.map(_itemRow),
                    ],
                    2.gap,
                    _totals(order, itemCount),
                    2.gap,
                    _disputeLink(order),
                    5.gap,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Disputes are only accepted on completed orders (status 6), so this is
  /// hidden otherwise rather than offered and rejected by the API.
  Widget _disputeLink(OrderDetailData order) {
    if (order.status != 6) return const SizedBox.shrink();
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RaiseDispute(order: order)),
        ),
        icon: Icon(Icons.flag_outlined, size: 17, color: Colors.grey.shade700),
        label: Text(
          'Report a problem with this order',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _ratingCard(OrderDetailData order) {
    final bool alreadyRated = order.storeRating != null;
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
          UiUtils.subTitles(
            alreadyRated ? 'You rated this Business' : 'Rate this Business',
            17,
          ),
          0.5.gap,
          RatingBar.builder(
            initialRating:
                (order.storeRating ?? _pendingRating).toDouble(),
            minRating: 1,
            itemSize: 7.pW,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            ignoreGestures: alreadyRated || _submittingRating,
            itemPadding: EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() => _pendingRating = rating);
            },
          ),
          if (!alreadyRated) ...[
            1.gap,
            SizedBox(
              height: 5.pH,
              child: ElevatedButton(
                onPressed:
                    _pendingRating > 0 && !_submittingRating
                        ? () => _submitRating(order)
                        : null,
                child: _submittingRating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit rating'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _deliveryCard(OrderDetailData order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xffFBFBFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/Frame 1171277941.png', height: 22.pH),
          2.gap,
          SizedBox(
            width: 70.pW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  order.stores?.name ?? 'Store',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  order.stores?.location ?? '',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                4.gap,
                Text(
                  order.deliveryAddress ?? '',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  _date(order.createdAt),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeTile(OrderDetailData order, int itemCount) {
    final String? logo = order.stores?.logo;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 15.pW,
        width: 15.pW,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.grey.shade200,
          image: logo != null && logo.isNotEmpty
              ? DecorationImage(image: NetworkImage(logo), fit: BoxFit.cover)
              : null,
        ),
        child: logo == null || logo.isEmpty
            ? Icon(Icons.storefront_outlined,
                size: 20, color: Colors.grey.shade500)
            : null,
      ),
      title: UiUtils.subTitles(order.stores?.name ?? 'Store', 14),
      subtitle: Text(
        '$itemCount item${itemCount == 1 ? '' : 's'} ● ${_money(order.total)}',
        style: TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _itemRow(OrderCartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.quantity ?? 1}× ${item.name ?? 'Item'}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          Text(_money(item.lineTotal), style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _totals(OrderDetailData order, int itemCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xffEEEEEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _totalDetail('Sub-total ($itemCount items)', _money(order.subtotal), null),
          1.gap,
          _totalDetail('Delivery Fee', _money(order.deliveryFee), null),
          1.gap,
          _totalDetail('Service Fees', _money(order.serviceFee), null),
          1.gap,
          _totalDetail('Total', _money(order.total), FontWeight.w700),
        ],
      ),
    );
  }

  Widget _totalDetail(String detail, String value, FontWeight? fontWeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(detail, style: TextStyle(fontSize: 14, fontWeight: fontWeight)),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
