// ignore_for_file: avoid_unnecessary_containers
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/app_controller.dart';
import '../../models/products.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../item_detail_screen/item_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchScreen extends StatefulWidget {

  final List<Product> allItems;
  const SearchScreen({ Key? key, required this.allItems}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController searchField = TextEditingController();
  List<Product> searchedProducts = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
  }

  void markProductFavorite(Product product, int index) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().addProductFavorite(product);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        searchedProducts[index].favoriteCount = searchedProducts[index].favoriteCount +1;
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void removeProductFavorite(Product product, int index) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().removeProductFavorite(product);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        searchedProducts[index].favoriteCount = searchedProducts[index].favoriteCount -1;
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void showCategoryFilterView() {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('Select Category'),
        content: Container(
          height: SizeConfig.blockSizeVertical * 6.5,
          width: SizeConfig.blockSizeHorizontal*90,
          margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 1
            )
          ),
          child: Center(
            child: DropdownButton<String>(
              value: selectedCategory,
              style: TextStyle(fontSize: SizeConfig.fontSize*1.8, color: Colors.black),
              isExpanded: true,
              underline: Container(),
              hint: Text(
                'Select category',
                style: TextStyle(fontSize: SizeConfig.fontSize*1.8, color: Colors.grey),
              ),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue;
                  Get.back();
                  showCategoryFilterView();
                });
              },
              items: Constants.categoryLists.map((location) {
                return DropdownMenuItem<String>(
                  child: Text(
                    location,
                    style: TextStyle(fontSize: SizeConfig.fontSize*1.8, color: Colors.black),
                  ),
                  value: location,
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              Get.back();
              searchResults();
            },
            child: Text('Submit')
          )
        ],
      )
    );
  }  

  void searchResults(){
    setState(() {
      searchedProducts = widget.allItems.where((element) => element.productImage.toLowerCase().contains(searchField.text.toLowerCase())).toList();
      if(selectedCategory != null)
        searchedProducts = searchedProducts.where((element) => element.productCategory == selectedCategory).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: Row(
          children: [
            Text(
              'Search',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: SizeConfig.blockSizeHorizontal * 5, right: SizeConfig.blockSizeHorizontal * 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: SizeConfig.blockSizeVertical *6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.grey[400]!,
                          width: 0.5
                        )
                      ),
                      child: Center(
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                          onChanged: (val){
                            searchResults();
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search',
                            hintStyle: TextStyle(color: Colors.grey[400]!, fontSize: SizeConfig.fontSize * 1.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: showCategoryFilterView,
                    child: Container(
                      margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 3),
                      height: SizeConfig.blockSizeVertical *6,
                      width: SizeConfig.blockSizeVertical *6,
                      decoration: BoxDecoration(
                        color: Constants.appThemeColor,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(
                        child: Icon(Icons.filter_list_sharp, color: Colors.white,size: SizeConfig.blockSizeVertical*3,),
                      ),
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: (searchedProducts.isEmpty) ? Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*5),
                child: Center(
                  child: Text(
                    'No Items Found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: SizeConfig.fontSize * 2.1,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ) 
              : Container(
                child: ListView.builder(
                  itemCount: searchedProducts.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return itemCell(searchedProducts[index],index);
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemCell(Product product, int index){
    DateTime productDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(product.productAddedDate);
    String formattedDate = timeago.format(productDate);
    bool isAlreadyFav = Constants.appUser.myFavorites.contains(product.productId);
    return GestureDetector(
      onTap: (){
        Get.to(ItemDetailScreen(product: product,));
      },
      child: Container(
        margin: EdgeInsets.only(left : SizeConfig.blockSizeHorizontal*3, right: SizeConfig.blockSizeHorizontal*3),
        height: SizeConfig.blockSizeVertical * 15,
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
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*0, SizeConfig.blockSizeVertical*2, SizeConfig.blockSizeHorizontal*6, SizeConfig.blockSizeVertical*2,),
              height: SizeConfig.blockSizeVertical * 13,
              width: SizeConfig.blockSizeVertical * 11,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(product.productImage),
                  fit: BoxFit.cover
                )
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top : SizeConfig.blockSizeVertical*2,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.fontSize * 2,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top : SizeConfig.blockSizeVertical*0.7),
                      child: Text(
                        '${product.productAreaLocality}  ($formattedDate)',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: SizeConfig.fontSize * 1.6,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top : SizeConfig.blockSizeVertical*0.7),
                      child: Text(
                        '${product.productPrice}',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.fontSize * 1.8,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
    
                    Container(
                      margin: EdgeInsets.only(top : SizeConfig.blockSizeVertical*0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: (){
                              if(!isAlreadyFav)
                                markProductFavorite(product, index);
                              else
                                removeProductFavorite(product, index);
                            },
                            child: Icon((isAlreadyFav) ? Icons.favorite : Icons.favorite_border, size: SizeConfig.blockSizeVertical * 2.5, color: Colors.grey,)
                          ),
                          Container(
                            margin: EdgeInsets.only(left : SizeConfig.blockSizeHorizontal*1),
                            child: Text(
                              '${product.favoriteCount}',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.fontSize * 1.6,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
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