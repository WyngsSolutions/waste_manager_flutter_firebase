// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, curly_braces_in_flow_control_structures, unnecessary_null_comparison
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/app_controller.dart';
import '../../models/appuser.dart';
import '../../models/products.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../chat_screen/chat_screen.dart';
import '../item_detail_screen/item_detail_screen.dart';
import '../user_reviews/user_reviews.dart';
import '../welcome_screen/welcome_screen.dart';

class VendorProfile extends StatefulWidget {

  final AppUser user;
  const VendorProfile({super.key, required this.user});

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  
  String userImageUrl = "";
  List myListingProducts = [];

  @override
  void initState() {
    super.initState();
    userImageUrl = widget.user.userPicture;
    getMyListingProducts();
  }

  void getMyListingProducts() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getUserListedProducts(widget.user.userId);
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

  void markProductFavorite(Product product, int index) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().addProductFavorite(product);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        myListingProducts[index].favoriteCount = myListingProducts[index].favoriteCount +1;
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
        myListingProducts[index].favoriteCount = myListingProducts[index].favoriteCount -1;
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
        titleSpacing: 10,
        title: Row(
          children: [
            Text(
              'User Profile',
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
      body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            print('close');
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus)
              currentFocus.unfocus();
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*7, vertical: SizeConfig.blockSizeVertical*2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
               Center(
                 child: Container(
                    height: SizeConfig.blockSizeVertical*15,
                    width: SizeConfig.blockSizeVertical*15,
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Constants.appThemeColor
                      ),
                      image: DecorationImage(
                        image: (userImageUrl.isEmpty) ? AssetImage('assets/placeholder.png') : CachedNetworkImageProvider(userImageUrl) as ImageProvider,
                        fit: BoxFit.cover
                      )
                    ),
                  ),
               ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
                  child: Text(
                    '${widget.user.userName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.3,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                (widget.user.totalReviewsCount>0) ?
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: RatingBar.builder(
                          initialRating: (widget.user.totalRating/ widget.user.totalReviewsCount),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          ignoreGestures: true,
                          itemSize: SizeConfig.blockSizeVertical*2,
                          itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (ratingVal) {
                            print(ratingVal);
                          },
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text(
                        '(${(widget.user.totalRating/ widget.user.totalReviewsCount).toStringAsFixed(1)})',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.fontSize * 1.5,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  )
                ) : Text(
                  'No rating yet',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: SizeConfig.fontSize * 1.5,
                    fontWeight: FontWeight.w500
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if(AppUser.isGuestUser())
                            Get.to(const WelcomeScreen());
                          else
                            Get.to(ChatScreen(chatUser: widget.user,));
                        },
                        child: Container(
                          height: SizeConfig.blockSizeVertical *5,
                          width: SizeConfig.blockSizeHorizontal*35,
                          decoration: BoxDecoration(
                            color: Constants.appThemeColor,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(
                            child: Text(
                              'Chat',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.fontSize * 1.8,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          Get.to(MyReviews(selectedUser: widget.user,));
                        },
                        child: Container(
                          height: SizeConfig.blockSizeVertical *5,
                          width: SizeConfig.blockSizeHorizontal*35,
                          decoration: BoxDecoration(
                            color: Constants.appThemeColor,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(
                            child: Text(
                              'Reviews',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.fontSize * 1.8,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
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
          ),
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
        margin: EdgeInsets.only(left : SizeConfig.blockSizeHorizontal*0, right: SizeConfig.blockSizeHorizontal*0),
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