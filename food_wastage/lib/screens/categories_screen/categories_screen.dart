import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../category_items/category_items.dart';
import '../search_screen/search_screen.dart';

class CategoriesScreen extends StatefulWidget {

  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  
  List categoryLists = [
    //'Hot items',
    'Electronics & appliances',
    'Furniture',
    'Home & garden',
    'Baby & kids',
    'Women\'s fashion',
    'Mens\'s fashion',
    'Health & beauty',
    'Sports & leisure',
    'Games, hobbies & crafts',
    'Books & music',
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.fontSize * 2.1,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: categoryLists.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return categoriesCell(index);
          }
        ),
      ),
    );
  }

  Widget categoriesCell(int index){
    return GestureDetector(
      onTap: (){
        Get.to(ItemListScreen(categoryName: categoryLists[index],));
      },
      child: Container(
        margin: EdgeInsets.only(left : SizeConfig.blockSizeHorizontal*3, right: SizeConfig.blockSizeHorizontal*3),
        height: SizeConfig.blockSizeVertical * 8,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 0.5
            )
          )
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*0, SizeConfig.blockSizeVertical*2, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*2,),
              height: SizeConfig.blockSizeVertical * 5,
              width: SizeConfig.blockSizeVertical * 5,
              child: Icon(Icons.desktop_mac_outlined, color: Constants.appThemeColor, size: SizeConfig.blockSizeVertical * 3),
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${categoryLists[index]}',
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.fontSize * 1.8,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}