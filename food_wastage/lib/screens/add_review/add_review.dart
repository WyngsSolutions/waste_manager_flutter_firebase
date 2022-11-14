import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_wastage/utils/size_config.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../models/appuser.dart';
import '../../utils/constants.dart';

class AddReviewScreen extends StatefulWidget {

  final AppUser selectedUser;
  const AddReviewScreen({super.key, required this.selectedUser});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {

  TextEditingController comment = TextEditingController();
  double rating = 5;

  void addReviewPressed() async {
    if (comment.text.isEmpty)
      Constants.showDialog("Please enter comment");
    else {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().addUserReview(comment.text, rating, widget.selectedUser);
      EasyLoading.dismiss();     
      if (result['Status'] == "Success") 
      {
        Get.back(result:  true);
      }
      else
      {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 10,
        title: Text(
          'Add Review',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fontSize * 2.1,
            fontWeight: FontWeight.bold
          ),
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
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*6, vertical: SizeConfig.blockSizeVertical*4),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Let us know your experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: SizeConfig.fontSize * 2.1,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
      
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*3),
                child: RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (ratingVal) {
                    print(ratingVal);
                    rating = ratingVal;
                  },
                ),
              ),
              
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey[500]!,
                      width: 0.5
                    )
                  ),
                  child: TextField(
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.multiline,
                    controller: comment,
                    maxLines: null,
                    style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter comments',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: SizeConfig.fontSize * 1.8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)
                    ),
                  ),
                ),
              ),
      
            ],
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: addReviewPressed,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*6, vertical: SizeConfig.blockSizeVertical*3),
          height: SizeConfig.blockSizeVertical *6.5,
          decoration: BoxDecoration(
            color: Constants.appThemeColor,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Center(
            child: Text(
              'Submit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.fontSize * 2.1,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}