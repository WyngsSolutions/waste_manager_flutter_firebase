// ignore_for_file: unnecessary_string_interpolations, sized_box_for_whitespace, curly_braces_in_flow_control_structures
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_wastage/models/appuser.dart';
import 'package:food_wastage/screens/settings_screen/settings_screen.dart';
import 'package:food_wastage/screens/sign_up/sign_up.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/app_controller.dart';
import '../../models/products.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../item_detail_screen/item_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyProfile extends StatefulWidget {
  const MyProfile({ Key? key }) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  
  int selectedIndex = 0;
  List<Product> myListingProducts = [];

  @override
  void initState() {
    super.initState();
    getMyListingProducts();
  }

  void getMyListingProducts() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getUserListedProducts(Constants.appUser.userId);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        myListingProducts = result['MyProducts'];        
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void getMyFavoriteProducts() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getMyFavoriteProducts();
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        myListingProducts = result['MyProducts'];        
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
        myListingProducts.removeAt(index);
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void deleteProduct(Product product, int index) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().deleteProduct(product);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        myListingProducts.removeAt(index);
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'My Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.fontSize * 2.1,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Get.to(const SettingsScreen());
              setState(() {});
            },
            icon: Icon(Icons.settings, color: Colors.white, size: SizeConfig.blockSizeVertical *3,)
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topView(),
          if(selectedIndex == 0)
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: myListingProducts.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return itemCell(myListingProducts[index], index);
                }
              ),
            ),
          ),
          if(selectedIndex == 2)
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: myListingProducts.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return itemCell(myListingProducts[index], index);
                }
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget topView(){
    return Container(
      height: SizeConfig.blockSizeVertical * 18,
      color: Constants.appThemeColor,
      child: Column(
        children: [
          Container(
            height: SizeConfig.blockSizeVertical * 12,
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*0, SizeConfig.blockSizeVertical*2, SizeConfig.blockSizeHorizontal*3, SizeConfig.blockSizeVertical*2,),
                  height: SizeConfig.blockSizeVertical * 10,
                  width: SizeConfig.blockSizeVertical * 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: (Constants.appUser.userPicture.isNotEmpty) ? CachedNetworkImageProvider(Constants.appUser.userPicture) : AssetImage('assets/placeholder.png') as ImageProvider,
                      fit: BoxFit.cover
                    )
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Constants.appUser.userName,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.fontSize * 1.8,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 0.5),
                          child: Text(
                            Constants.appUser.userEmail,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.fontSize * 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1),
              //color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        selectedIndex = 0;
                        getMyListingProducts();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 10, vertical: SizeConfig.blockSizeVertical * 1),
                      decoration: BoxDecoration(
                        color: (selectedIndex==0) ? Colors.white : Constants.appThemeColor,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(
                        'Listings',
                        maxLines: 1,
                        style: TextStyle(
                          color: (selectedIndex==0) ? Constants.appThemeColor : Colors.white,
                          fontSize: SizeConfig.fontSize * 1.8,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: (){
                  //     setState(() {
                  //       selectedIndex = 1;
                  //     });
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 6, vertical: SizeConfig.blockSizeVertical * 1),
                  //     decoration: BoxDecoration(
                  //       color: (selectedIndex==1) ? Colors.white : Constants.appThemeColor,
                  //       borderRadius: BorderRadius.circular(10)
                  //     ),
                  //     child: Text(
                  //       'Purchases',
                  //       maxLines: 1,
                  //       style: TextStyle(
                  //         color: (selectedIndex==1) ? Constants.appThemeColor : Colors.white,
                  //         fontSize: SizeConfig.fontSize * 1.8,
                  //         fontWeight: FontWeight.w500
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        selectedIndex = 2;
                        getMyFavoriteProducts();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 10, vertical: SizeConfig.blockSizeVertical * 1),
                      decoration: BoxDecoration(
                        color: (selectedIndex==2) ? Colors.white : Constants.appThemeColor,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(
                        'Favorites',
                        maxLines: 1,
                        style: TextStyle(
                          color: (selectedIndex==2) ? Constants.appThemeColor : Colors.white,
                          fontSize: SizeConfig.fontSize * 1.8,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemCell(Product product, int index){
    DateTime productDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(product.productAddedDate);
    String formattedDate = timeago.format(productDate);

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        if(selectedIndex == 0)
                        GestureDetector(
                          onTap: (){
                            deleteProduct(product, index);
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*2),
                            child: Icon(Icons.delete, color: Colors.green, size: SizeConfig.blockSizeVertical*3,),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top : SizeConfig.blockSizeVertical*0.5),
                      child: Text(
                        //'${product.productAreaLocality}  ($formattedDate)',
                        (selectedIndex == 0) ? 'posted $formattedDate' : '${product.distanceInKm} km  posted $formattedDate',
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
                              if(selectedIndex == 2)
                                removeProductFavorite(product, index);
                            },
                            child: Icon(Icons.favorite, size: SizeConfig.blockSizeVertical * 2.5, color: Colors.grey,)
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