// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, unnecessary_string_interpolations, curly_braces_in_flow_control_structures
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_wastage/models/appuser.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/app_controller.dart';
import '../../models/products.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../item_detail_screen/item_detail_screen.dart';
import '../search_screen/search_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../set_my_radius/set_my_radius.dart';
import '../welcome_screen/welcome_screen.dart';

class ListingScreen extends StatefulWidget {
  
  const ListingScreen({super.key});
  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    getAllProducts();
  }

  void getAllProducts() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    await AppController().getAllMyFavoriteProducts();
    dynamic result = await AppController().getAllProducts();
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        products = result['AllProducts'];        
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void markProductFavorite(Product product, int index) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().addProductFavorite(product);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        products[index].favoriteCount = products[index].favoriteCount +1;
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
        products[index].favoriteCount = products[index].favoriteCount -1;
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
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            await Get.to(const SetMyRadius());
            setState(() {});
          },
          child: Row(
            children: [
              Text(
                'Nearby',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.fontSize * 2.1,
                  fontWeight: FontWeight.bold
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 2, top: 2),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                '${Constants.appUser.searchRadius.toString()} Km',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Constants.appThemeColor,
                  fontSize: SizeConfig.fontSize * 1.4,
                  fontWeight: FontWeight.bold
                ),
              ),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Get.to(SearchScreen(allItems: products,));
              getAllProducts();
            },
            icon: Icon(Icons.search, color: Colors.white, size: SizeConfig.blockSizeVertical *3,)
          ),
        ],
      ),
      body: (products.isEmpty) ? Container(
        child: Center(
          child: Text(
            'No Products Found',
            maxLines: 1,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: SizeConfig.fontSize * 2,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ) :Container(
        child: ListView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return itemCell(products[index],index);
          }
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
                        //'${product.productAreaLocality}  ($formattedDate)',
                        '${product.distanceInKm} km  posted $formattedDate',
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
                              if(AppUser.isGuestUser())
                                Get.to(const WelcomeScreen());
                              else
                              {
                                if(!isAlreadyFav)
                                  markProductFavorite(product, index);
                                else
                                  removeProductFavorite(product, index);
                              }
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