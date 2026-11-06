import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/custom%20widgets/order_tile.dart';
import 'package:chop_chop_africa/utility/money.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'checkout.dart';


class CartDetails extends StatefulWidget {
  final String orderId;
  const CartDetails({super.key, required this.orderId});

  @override
  State<CartDetails> createState() => _CartDetailsState();
}

class _CartDetailsState extends State<CartDetails> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context,store,child) {
        // find the cart by its id
        final cart = store.getCartItems?.data?.carts
            ?.firstWhere((c) => c.orderId == widget.orderId);

        // the updated list of items
        final cartItems = cart?.items ?? [];
        return Theme(
          data: Theme.of(context).copyWith(
            dividerTheme: const DividerThemeData(
              color: Colors.transparent,
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Detail',
                style: TextStyle(
                    fontSize: 16
                ),
              ),
              leading: UiUtils.backButton(context),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(7),
                child: Divider(
                  color: IAColors.veryLightGrey,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context,index) {
                  var allCartItems = cartItems[index];
                  return OrderTile(
                    imageUrl: allCartItems.product?.banner,
                    title: allCartItems.product?.name ?? '',
                    details: [
                      OrderTileLine(naira(allCartItems.totalPrice),
                          weight: FontWeight.w600),
                    ],
                    // Was absolutely positioned over the card's top-right
                    // corner, overlapping the name it sat on top of.
                    cornerAction: InkWell(
                      onTap: () async {
                        EasyLoading.show();
                        await store.deleteProductFromCart(
                          widget.orderId,
                          allCartItems.product!.id!,
                        );
                        EasyLoading.dismiss();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.close,
                            size: 16, color: IAColors.darkGrey),
                      ),
                    ),
                    // The stepper used to be crammed into the ListTile's
                    // trailing slot, where it competed with the name for
                    // width. Across the foot of the card it has room.
                    footer: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quantity', style: IAText.caption()),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _level(Icons.remove, () async {
                              setState(() {
                                if (allCartItems.quantity! > 1) {
                                  allCartItems.quantity =
                                      allCartItems.quantity! - 1;
                                  allCartItems.isSelected = 1;
                                }
                              });
                              await store.manipulateProductQuantity(
                                  allCartItems.quantity!, allCartItems.id!);
                            }, isSelected: allCartItems.isSelected == 1),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14.0),
                              child: Text(allCartItems.quantity.toString(),
                                  style: IAText.body(
                                      weight: FontWeight.w700)),
                            ),
                            _level(Icons.add, () async {
                              setState(() {
                                allCartItems.quantity =
                                    allCartItems.quantity! + 1;
                                allCartItems.isSelected = 2;
                              });
                              await store.manipulateProductQuantity(
                                  allCartItems.quantity!, allCartItems.id!);
                            }, isSelected: allCartItems.isSelected == 2),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
            persistentFooterButtons: [
              Column(
                children: [
                  SizedBox(
                    height: 6.5.pH,
                    width: 100.pW,
                    child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return Checkout(orderId: cart!.orderId!,subTotal: cart.subtotal!, productNumber: cartItems.length,storeId: cart.store!.id!,);
                          }));
                        },
                        child: Text('Check Out')
                    ),
                  ),
                  Center(
                    child: TextButton(
                        onPressed: ()async{
                          setState(() {
                            _isLoading = true;
                          });
                          await store.clearCart(widget.orderId);
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child:  _isLoading?
                        SizedBox(
                            height: 20,
                            width: 20,
                            child: LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                colors: const [Colors.black],
                                strokeWidth: 2,
                                backgroundColor: Colors.transparent,
                                pathBackgroundColor: Colors.black)):
                        Text('Clear Selections',
                          style: TextStyle(
                              fontSize: 14
                          ),
                        )
                    ),
                  ),
                ],
              ),
        
            ],
          ),
        );
      }
    );
  }
  Widget _level(IconData icon, GestureTapCallback callBack, {required bool isSelected}) {
    return GestureDetector(
      onTap: callBack,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? IAColors.primary : Colors.transparent, // highlight
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: IAColors.lightGrey,
          ),
        ),
        child: Icon(icon,size: 20,color: isSelected?IAColors.white:IAColors.dialogDark,),
      ),
    );
  }
}
