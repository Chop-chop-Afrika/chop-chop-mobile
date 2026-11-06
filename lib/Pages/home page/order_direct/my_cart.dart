import 'package:chop_chop_africa/Pages/home%20page/order_direct/cart_details.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:chop_chop_africa/custom%20widgets/order_tile.dart';
import 'package:chop_chop_africa/custom%20widgets/refreshable.dart';
import 'package:chop_chop_africa/utility/money.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  @override
  void initState() {
    super.initState();
    // The cart changes behind this screen's back — paying for one empties it.
    // Refetch on open so it never shows an order that has already been paid.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoreProvider>(context, listen: false).fetchAllCartItems();
    });
  }

  /// Emptying the cart loses everything the customer picked, so confirm first.
  Future<void> _confirmClearCart(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear your cart?', style: TextStyle(fontSize: 17)),
        content: const Text(
          'This removes every item from every store in your cart.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep items')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Clear cart',
                style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final store = Provider.of<StoreProvider>(context, listen: false);
    final bool ok = await UiUtils.runBlocking(
      context,
      'Clearing your cart',
      () => store.clearEntireCart(),
    );
    if (!context.mounted) return;
    UiUtils.showSnackBarFromTop(
        context, ok ? 'Cart cleared' : 'Could not clear your cart');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context,store,child) {
        var cartStores = store.getCartItems?.data?.carts;
        return Refreshable(
          onRefresh: _refresh,
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: cartStores != null && cartStores.isNotEmpty
              ? Column(children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _confirmClearCart(context),
                      icon: Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade400),
                      label: Text('Clear cart',
                          style: TextStyle(
                              fontSize: 13, color: Colors.red.shade400)),
                    ),
                  ),
                  Expanded(child: ListView.builder(
            physics: Refreshable.physics,
            itemCount: cartStores.length,
              itemBuilder: (context, index){
              final cart = cartStores[index];
              final int items = cart.items?.length ?? 0;
              return OrderTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CartDetails(orderId: cart.orderId!);
                  }));
                },
                imageUrl: cart.store?.logo,
                title: cart.store?.name ?? '',
                details: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/svg/bicycle 1.svg', height: 14),
                      const SizedBox(width: 6),
                      Flexible(
                        child: OrderTileLine(cart.store?.deliveryTime ?? ''),
                      ),
                    ],
                  ),
                  OrderTileLine('$items item${items == 1 ? '' : 's'}'),
                ],
                trailing: Text(naira(cart.subtotal),
                    style: IAText.subtitle()),
              );
              }
          )),
                ])
              // Scrollable so an empty cart can still be pulled to refresh.
              : LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: Refreshable.physics,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Text('No Items',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 23)),
                      ),
                    ),
                  ),
                ),
        ),
        );
      }
    );
  }

  Future<void> _refresh() =>
      Provider.of<StoreProvider>(context, listen: false).fetchAllCartItems();
}
