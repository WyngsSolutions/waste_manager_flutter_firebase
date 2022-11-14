// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_wastage/models/appuser.dart';
import 'package:food_wastage/screens/add_review/add_review.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import '../../controllers/app_controller.dart';
import '../../helpers/item_image_view.dart';
import '../../helpers/product_map_view.dart';
import '../../models/products.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../chat_screen/chat_screen.dart';
import '../user_reviews/user_reviews.dart';
import '../vendor_profile/vendor_profile.dart';

class ItemDetailScreen extends StatefulWidget {
  
  final Product product;
  const ItemDetailScreen({ Key? key, required this.product }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {

  String formattedTime = "";
  late AppUser user;

  @override
  void initState() {
    super.initState();
    user = AppUser(userName: widget.product.productOwnerName);
    DateTime productDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.product.productAddedDate);
    formattedTime = timeago.format(productDate);
    getUserDetail();
  }

  void getUserDetail() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    user = await AppUser.getUserDetailByUserId(widget.product.productOwnerId);
    EasyLoading.dismiss();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Row(
          children: [
            Text(
              widget.product.productName,
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
              Share.share('Checkout item ${widget.product.productName} on Waste Manager app\n${(Platform.isAndroid) ? Constants.androidAppLink : Constants.iosAppLink}');
            },
            icon: Icon(Icons.share, color: Colors.white, size: SizeConfig.blockSizeVertical *3,)
          ),
        ],
      ),
      body: (user.userName.isEmpty) ? Container() : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ItemImageView(adsList: [widget.product.productImage]),
            GestureDetector(
              onTap: (){
                Get.to(VendorProfile(user: user,));
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0, SizeConfig.blockSizeHorizontal*5, SizeConfig.blockSizeVertical*0,),
                height: SizeConfig.blockSizeVertical * 9,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[400]!,
                      width: 0.5
                    )
                  )
                ),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0, SizeConfig.blockSizeHorizontal*3, SizeConfig.blockSizeVertical*0,),
                      height: SizeConfig.blockSizeVertical * 6,
                      width: SizeConfig.blockSizeVertical * 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: (user.userPicture.isEmpty) ? AssetImage('assets/placeholder.png') : CachedNetworkImageProvider(user.userPicture) as ImageProvider,
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
                                  widget.product.productOwnerName,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: SizeConfig.fontSize * 1.8,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              ],
                            ),
                            (user.totalReviewsCount>0) ?
                            Container(
                              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 0.5),
                              child: Row(
                                children: [
                                  Container(
                                    child: RatingBar.builder(
                                      initialRating: (user.totalRating/ user.totalReviewsCount),
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
                                    '(${(user.totalRating/ user.totalReviewsCount).toStringAsFixed(1)})',
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
                          ],
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[500], size: SizeConfig.blockSizeVertical*2,),
                  ],
                ),
              ),
            ),

            //TITLE
            Container(
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*2, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
              child: Text(
                widget.product.productName,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.fontSize * 2.2,
                  fontWeight: FontWeight.w700
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
              child: Text(
                '${widget.product.productCategory} - $formattedTime',
                maxLines: 1,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: SizeConfig.fontSize * 1.4,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            
            extraView(),
            Container(
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0.5, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
              child: Row(
                children: [
                  Text(
                    'Condition : ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.fontSize * 1.6,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    widget.product.productCondition,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.fontSize * 1.6,
                    ),
                  ),
                ],
              )
            ),
            
            Container(
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0.5, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
              child: Row(
                children: [
                  Text(
                    'Delivery : ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.fontSize * 1.6,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    widget.product.productDelivery.replaceAll(',', ' / '),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.fontSize * 1.6,
                    ),
                  ),
                ],
              )
            ),

            Container(
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*2,),
              child: Text(
                widget.product.productDescription,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: SizeConfig.fontSize * 1.7,
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
              child: ProductMapView(product: widget.product,)
            ),

            GestureDetector(
              onTap: showReportView,
              child: Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical *4),
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*2, vertical: SizeConfig.blockSizeVertical * 3),
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
                      'Report this Post',
                      style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.black, size: SizeConfig.blockSizeVertical * 2,)
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 7),
        height: SizeConfig.blockSizeVertical * 9,
        color: Constants.appThemeColor,
        child: Row(
          children: [
            //Icon(Icons.favorite_border, size : SizeConfig.blockSizeVertical *3.5, color: Colors.white,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal *2),
              child: VerticalDivider(
                color: Colors.transparent,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    child: Text(
                      'Price',
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.fontSize * 1.5,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${widget.product.productPrice}',
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.fontSize * 2.8,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () async {
                AppUser user = await AppUser.getUserDetailByUserId(widget.product.productOwnerId);
                Get.to(ChatScreen(chatUser: user,));
              },
              child: Container(
                height: SizeConfig.blockSizeVertical * 6,
                width: SizeConfig.blockSizeHorizontal * 25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Chat',
                    maxLines: 1,
                    style: TextStyle(
                      color: Constants.appThemeColor,
                      fontSize: SizeConfig.fontSize * 2.3,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget extraView(){
    if(widget.product.productCategory == "Electronics & appliances")
    return Container(
      margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
      child: Row(
        children: [
          Text(
            'Brand : ',
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.fontSize * 1.6,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            widget.product.productExtra,
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.fontSize * 1.6,
            ),
          ),
        ],
      )
    );

    else if(widget.product.productCategory == "Furniture")
    return Container(
      margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
      child: Row(
        children: [
          Text(
            'Dimensions : ',
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.fontSize * 1.6,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            widget.product.productExtra,
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.fontSize * 1.6,
            ),
          ),
        ],
      )
    );

    else if(widget.product.productCategory.contains('fashion'))
    return Container(
      margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
      child: Row(
        children: [
          Text(
            'Size : ',
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.fontSize * 1.6,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            widget.product.productExtra,
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.fontSize * 1.6,
            ),
          ),
        ],
      )
    );

    else if(widget.product.productCategory == "Baby & kids")
    return Container(
      margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*0,),
      child: Row(
        children: [
          Text(
            'Age : ',
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.fontSize * 1.6,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            widget.product.productExtra,
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.fontSize * 1.6,
            ),
          ),
        ],
      )
    );
    else
    return Container();
  }

  ///******* UTIL METHOD ****************///
  void showReportView()async
  {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc){
        return Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*7, vertical: SizeConfig.blockSizeVertical*3),
          height: SizeConfig.blockSizeVertical*52,
          decoration: BoxDecoration(
            color: Constants.appThemeColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40)
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Report Comment To Admin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.fontSize * 2.3,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
                child: Text(
                  'Let the admin know what\'s wrong with this post. Your details will be kept anonymous for this report',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 1.8,
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  Get.back();
                  AppController().reportProduct(widget.product, 'Spam');
                  Constants.showDialog('You have reported the product to admin');
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5),
                  height: SizeConfig.blockSizeVertical*5.5,
                  width: SizeConfig.blockSizeHorizontal*80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Spam',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Get.back();
                  AppController().reportProduct(widget.product, 'Harassment');
                  Constants.showDialog('You have reported the product to admin');
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5),
                  height: SizeConfig.blockSizeVertical*5.5,
                  width: SizeConfig.blockSizeHorizontal*80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Harassment',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Get.back();
                  AppController().reportProduct(widget.product, 'Hate Speech');
                  Constants.showDialog('You have reported the product to admin');
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5),
                  height: SizeConfig.blockSizeVertical*5.5,
                  width: SizeConfig.blockSizeHorizontal*80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Hate Speech',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Get.back();
                  AppController().reportProduct(widget.product, 'Other');
                  Constants.showDialog('You have reported the product to admin');
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5),
                  height: SizeConfig.blockSizeVertical*5.5,
                  width: SizeConfig.blockSizeHorizontal*80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Other',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}