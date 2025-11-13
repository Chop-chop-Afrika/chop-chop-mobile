import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class CartDetails extends StatefulWidget {
  const CartDetails({super.key});

  @override
  State<CartDetails> createState() => _CartDetailsState();
}

class _CartDetailsState extends State<CartDetails> {
  int _amount = 0;
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          children: [
            Card(
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
                        image: DecorationImage(image: NetworkImage('https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?cs=srgb&dl=pexels-pixabay-262978.jpg&fm=jpg'),
                            fit: BoxFit.cover
                        ),
                    ),
                  ),
                  title: UiUtils.subTitles('Chicken Republic', 14),
                  subtitle: Text('4 items ● \$25',
                  style: TextStyle(
                    fontSize: 13
                  ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _level(Icons.remove,
                              (){
                        setState(() {
                          _amount --;
                          _selected = 1;
                        });
                              },
                        isSelected: _selected == 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(_amount.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14
                        ),
                        ),
                      ),
                      _level(Icons.add, (){
                        setState(() {
                          _amount ++;
                          _selected = 2;
                        });
                      },
                        isSelected: _selected == 2,
                      ),

                    ],
                  )
                ),
              ),
            ),
            Expanded(child: SizedBox()),
            SizedBox(
              height: 6.5.pH,
              width: 100.pW,
              child: ElevatedButton(
                  onPressed: (){},
                  child: Text('Checkut')
              ),
            ),
            TextButton(
                onPressed: (){},
                child: Text('Clear Selections')
            ),
            4.gap,
          ],
        ),
      ),
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
