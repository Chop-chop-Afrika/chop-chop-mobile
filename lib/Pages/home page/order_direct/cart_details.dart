import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class CartDetails extends StatefulWidget {
  final String orderId;
  const CartDetails({super.key, required this.orderId});

  @override
  State<CartDetails> createState() => _CartDetailsState();
}

class _CartDetailsState extends State<CartDetails> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    String cutUnwantedPart(String name) {
      if (name.length > 16) {
        return name.trim().replaceRange(16, null, '...');
      }
      return name;
    }
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
                  return Card(
                    elevation: 1,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,top: 8,bottom: 8),
                      child: ListTile(
                        leading: Container(
                          height: 15.pW,
                          width: 15.pW,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              image: DecorationImage(image: NetworkImage(allCartItems.product!.banner!),
                                  fit: BoxFit.cover
                              ),
                          ),
                        ),
                        title: UiUtils.subTitles(cutUnwantedPart(allCartItems.product!.name!), 14),
                        subtitle: Text('${allCartItems.quantity} items ● \$${formatter.format(allCartItems.totalPrice)}',
                        style: TextStyle(
                          fontSize: 13
                        ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _level(Icons.remove,
                                    ()async{
                              setState(() {
                                if (allCartItems.quantity! > 1) {
                                  allCartItems.quantity = allCartItems.quantity! - 1;
                                  allCartItems.isSelected = 1;
                                }
                              });
                              await store.manipulateProductQuantity(allCartItems.quantity!, allCartItems.id!);
                                    },
                              isSelected: allCartItems.isSelected == 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(allCartItems.quantity.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14
                              ),
                              ),
                            ),
                            _level(Icons.add, ()async{
                              setState(() {
                                allCartItems.quantity = allCartItems.quantity! + 1;
                                allCartItems.isSelected = 2;
                              });
                              await store.manipulateProductQuantity(allCartItems.quantity!, allCartItems.id!);
                            },
                              isSelected: allCartItems.isSelected == 2,
                            ),
        
                          ],
                        )
                      ),
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
                        onPressed: (){},
                        child: Text('Checkut')
                    ),
                  ),
                  Center(
                    child: TextButton(
                        onPressed: (){},
                        child: Text('Clear Selections',
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
