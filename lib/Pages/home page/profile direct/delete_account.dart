import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Delete Account',
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
            2.gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/svg/trash.svg',color: Colors.black,),
                SizedBox(
                  width:80.pW,
                  child: Text('This action will erase all your dta from our database, and you will cease to be a ChopChop User.',
                  style: TextStyle(
                    fontSize: 13
                  ),
                  ),
                )
              ],
            ),
            2.gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/svg/undo.svg'),
                SizedBox(
                  width:80.pW,
                  child: Text('You’ll have to create a new account to undo this action after the recovery period and use our services again.',
                    style: TextStyle(
                        fontSize: 13
                    ),
                  ),
                ),
              ],
            ),
            2.gap,
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Color(0xffFDF2DF),
                  borderRadius: BorderRadius.circular(9)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset('assets/svg/heart.svg', color: Color(0xffF7B100),),
                  SizedBox(
                    width: 75.pW,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('We’re sad to see you go',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                        0.5.gap,
                        Text('ChopChop will keep your account information for a recovery period of 30 days,'
                            ' and any login access will activate it. We will permanetely delete your'
                            ' account if you do not log in within the next 30 days.',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
            SizedBox(
              height: 6.5.pH,
              width: 100.pW,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.red)
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return DeleteAccount();
                    }));
                  },
                  child: Text('Delete My Account',)
              ),
            ),
            4.gap,
          ],
        ),
      ),
    );
  }
}
