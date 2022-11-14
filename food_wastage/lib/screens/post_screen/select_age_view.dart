// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class SelectAgeView extends StatefulWidget {
  const SelectAgeView({ Key? key }) : super(key: key);

  @override
  State<SelectAgeView> createState() => _SelectAgeViewState();
}

class _SelectAgeViewState extends State<SelectAgeView> {
   
  List ages = ["0-6 months", "7-12 months", "1-2 years", "3-5 years", "6-8 years", "9 years and older"];
  String selectedAge = '';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical * 3),
      height: SizeConfig.blockSizeVertical * 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Container(
            margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal* 3),
            child: Text(
              'Age',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.fontSize * 2.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical* 1),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: ages.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                return ageCell(index);
              }
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              Get.back(result: selectedAge);
            },
            child: Container(
              margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal* 2, right: SizeConfig.blockSizeHorizontal* 2, bottom: SizeConfig.blockSizeVertical * 3),
              height: SizeConfig.blockSizeVertical *5,
              decoration: BoxDecoration(
                color: Constants.appThemeColor,
                borderRadius: BorderRadius.circular(5)
              ),
              child: Center(
                child: Text(
                  'Done',
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
    );
  }

  Widget ageCell(int index){
    return GestureDetector(
      onTap: (){
        setState(() {
          selectedAge = ages[index];          
        });
      },
      child: Container(
        child: Row(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 4,
              width: SizeConfig.blockSizeVertical * 5,
              child: Icon(
                (selectedAge == ages[index])? Icons.check_circle_rounded : Icons.circle_outlined, 
                color: (selectedAge == ages[index]) ? Constants.appThemeColor : Colors.grey.withOpacity(0.4),
                size: SizeConfig.blockSizeVertical*2.5,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*1),
              child: Text(
                '${ages[index]}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.fontSize * 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}