import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class SelectCategory extends StatefulWidget {
  final String selectedCategory;
  const SelectCategory({ Key? key, required this.selectedCategory }) : super(key: key);

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  
  String selectedCategory = "";
  List categoryLists = [
    'Electronics & appliances',
    'Furniture',
    'Home, garden & DIY',
    'Baby & kids',
    'Women\'s fashion',
    'Mens\'s fashion',
    'Health & beauty',
    'Sports & leisure',
    'Games, hobbies & crafts',
    'Books, music & tickets',
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 10,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: Row(
          children: [
            Text(
              'Select Category',
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
        selectedCategory = categoryLists[index];
        Get.back(result: selectedCategory);
      },
      child: Container(
        margin: EdgeInsets.only(left : SizeConfig.blockSizeHorizontal*3, right: SizeConfig.blockSizeHorizontal*3),
        height: SizeConfig.blockSizeVertical * 6.5,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 0.5
            )
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            if(selectedCategory == categoryLists[index])
            Icon(Icons.check, color: Constants.appThemeColor, size: SizeConfig.blockSizeVertical*3,)
          ],
        )
      ),
    );
  }
}