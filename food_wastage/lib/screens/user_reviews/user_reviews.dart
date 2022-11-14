// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../models/appuser.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../add_review/add_review.dart';

class MyReviews extends StatefulWidget {

  final AppUser selectedUser;
  const MyReviews({Key? key, required this.selectedUser}) : super(key: key);

  @override
  State<MyReviews> createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
 
  List allReviews = [];

  @override
  void initState() {
    super.initState();
    getAllMyReviews();
  }

  void getAllMyReviews()async{
    allReviews.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getAllMyReviews(allReviews, widget.selectedUser.userId);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(allReviews.length);
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
        backgroundColor: Constants.appThemeColor,
        title: Text(
          'Reviews',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fontSize*2.2
          ),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                        
            Expanded(
              child: (allReviews.isEmpty) ? Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: Center(
                  child: Text(
                    'No Reviews',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                      color: Colors.grey[400]!
                    ),
                  ),
                ),
              ): Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1.5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: allReviews.length,
                    itemBuilder: (_, i) {
                      return commentCell(allReviews[i], i);
                    },
                    shrinkWrap: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if(Constants.appUser.userId == widget.selectedUser.userId)
          {
            dynamic result = await Get.to(AddReviewScreen(selectedUser: widget.selectedUser,));
            if(result != null)
              getAllMyReviews();
          }
          else
            Constants.showDialog('You cannot rate yourself');
        },
        backgroundColor: Constants.appThemeColor,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget commentCell(dynamic commentDetail, int index){
    return GestureDetector(
      onTap: (){
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*4, vertical: SizeConfig.blockSizeVertical*1.5),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 0.5
            )
          )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal*2),
              height: SizeConfig.blockSizeVertical*6,
              width: SizeConfig.blockSizeVertical*6,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: (commentDetail['reviewedByPhotoUrl'].isEmpty) ? AssetImage('assets/placeholder.png') : CachedNetworkImageProvider(commentDetail['reviewedByPhotoUrl']) as ImageProvider,
                  fit: BoxFit.cover
                )
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*2, top: SizeConfig.blockSizeVertical*0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RatingBar.builder(
                          initialRating: commentDetail['rating'],
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          ignoreGestures: true,
                          itemSize: SizeConfig.blockSizeHorizontal*5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        ),

                        GestureDetector(
                          onTap: (){
                            showReportView(commentDetail);
                          },
                          child: Container(
                            child: Icon(Icons.report_gmailerrorred, size: SizeConfig.blockSizeVertical*2.5,),
                          ),
                        )
                      ],
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        commentDetail['comment'],
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize*1.7,
                          color: Colors.grey[500]!
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        child: Text(
                          '${commentDetail['reviewedByUserName']}',
                          style: TextStyle(
                            fontSize: SizeConfig.fontSize*1.4,
                            color: Constants.appThemeColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            )
          ]
        ),
      )
    );
  }

  ///******* UTIL METHOD ****************///
  void showReportView(Map reviewDetail)async
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
                'Report Review To Admin',
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
                  'Let the admin know what\'s wrong with this review. Your details will be kept anonymous for this report',
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
                  AppController().reportComment(reviewDetail, 'Spam');
                  Constants.showDialog('You have reported the comment to admin');
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
                      'Spam Comment',
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
                  AppController().reportComment(reviewDetail, 'Harassment');
                  Constants.showDialog('You have reported the comment to admin');
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
                      'Harassment Comment',
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
                  AppController().reportComment(reviewDetail, 'Hate Speech');
                  Constants.showDialog('You have reported the comment to admin');
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
                      'Hate Speech Comment',
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
                  AppController().reportComment(reviewDetail, 'Other');
                  Constants.showDialog('You have reported the comment to admin');
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