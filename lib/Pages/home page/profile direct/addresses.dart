import 'package:chop_chop_africa/Pages/Delivery/select_delivery_address.dart';
import 'package:chop_chop_africa/Pages/home%20page/profile%20direct/new_address.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class Addresses extends StatefulWidget {
  const Addresses({super.key});

  @override
  State<Addresses> createState() => _AddressesState();
}

class _AddressesState extends State<Addresses> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      child: Consumer<AddressProvider>(
        builder: (context,address,child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Address',
                style: TextStyle(
                    fontSize: 16
                ),
              ),
              leading: UiUtils.backButton(context),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(10.pH),
                child: Column(
                  children: [
                    Divider(
                      color: IAColors.veryLightGrey,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height:11.pH,
                        child: TextFormField(
                          validator: (v){
                            if(v!.isEmpty){
                              return 'Field Must Not be empty';
                            }
                            return null;
                          },
                          onChanged: (v){
                          },
                          style: theme.textTheme.bodySmall,
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset('assets/svg/location (1).svg',),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: EdgeInsets.only(top: 3,left: 10),
                              errorStyle: TextStyle(
                                  fontSize: 14
                              ),
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  height: 2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800
                              ),
                              helperText: ''
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                  itemCount: address.addressList.length,
                  itemBuilder: (context, index){
                    var addressDetail = address.addressList[index];
                    String actualAddress = addressDetail.address!;
                    List<String> parts = actualAddress.split(',').map((e) => e.trim()).toList();
                    String lastTwo = "${parts[parts.length - 2]}, ${parts.last}";
                    String remaining = parts.sublist(0, parts.length - 2).join(', ');
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 80.pW,
                                  child: Text(remaining,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15
                                  ),
                                  ),
                                ),
                                0.5.gap,
                                Text(lastTwo,
                                  style: TextStyle(
                                      fontSize: 13
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: ()async{
                                EasyLoading.show();
                                await address.deleteAddress(addressDetail.id!);
                                EasyLoading.dismiss();
                              },
                                child: SvgPicture.asset('assets/svg/trash.svg', color: Colors.red,)
                            )
                          ],
                        ),
                        1.gap,
                        Divider(color: IAColors.lightGrey,)
                      ],
                    );
                  }
              ),
            ),
            persistentFooterButtons: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: SizedBox(
                  height: 6.5.pH,
                  width: 100.pW,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return AddressSearchBar(type: 'create', defaultAddress: false);
                        }));
                      },
                      child: Text('Add Address',)
                  ),
                ),
              ),

            ],
          );
        }
      ),
    );
  }
}
