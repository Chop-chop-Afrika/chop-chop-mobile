import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class VendorGrid extends StatefulWidget {
  const VendorGrid({super.key});

  @override
  State<VendorGrid> createState() => _VendorGridState();
}

class _VendorGridState extends State<VendorGrid> {
  List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1682778418768-16081e4470a1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cmVzdGF1cmFudCUyMGJhY2tncm91bmR8ZW58MHx8MHx8fDA%3D&fm=jpg&q=60&w=3000',
    'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?cs=srgb&dl=pexels-pixabay-262978.jpg&fm=jpg'
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 20),
      child: StaggeredGridView.countBuilder(
          itemCount: _carouselImages.length,
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          itemBuilder: (context, index){
            return GestureDetector(
              onTap: (){
                showModalBottomSheet(
                    context: context,
                    builder: (context){
                      return BottomSheet(
                          dragHandleColor: Colors.grey.shade200,
                          backgroundColor: Colors.white,
                          animationController: AnimationController(
                              vsync: Navigator.of(context)),
                          enableDrag: true,
                          onClosing: (){},
                          builder: (context){
                            return Builder(
                              builder: (context) {
                                return Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 33.pH,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        image: DecorationImage(
                                            image: NetworkImage(_carouselImages[index]),
                                          fit: BoxFit.cover
                                        )
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: SizedBox(
                                        height: 6.5.pH,
                                        width: 100.pW,
                                        child: ElevatedButton(
                                            onPressed: (){},
                                            child: Text('data')
                                        ),
                                      ),
                                    ),
                                    4.gap,
                                  ],
                                );
                              }
                            );
                          }
                      );
                    }
                );
              },
              child: Column(
                children: [
                  Container(
                    height: 16.pH,
                    width: 50.pW,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            image: NetworkImage(_carouselImages[index]),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                  1.gap,
                  UiUtils.subTitles('Certain Food', 15),
                  UiUtils.subTitles('\$12:00', 13),
                ],
              ),
            );
          },
          staggeredTileBuilder: (context) => const StaggeredTile.fit(1)
      ),
    );
  }

}
