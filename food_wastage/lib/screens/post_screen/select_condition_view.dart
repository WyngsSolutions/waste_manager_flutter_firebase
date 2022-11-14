// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class SelectConditionView extends StatefulWidget {
  
  final String selectedCondition;
  const SelectConditionView({ Key? key, required this.selectedCondition }) : super(key: key);

  @override
  State<SelectConditionView> createState() => _SelectConditionViewState();
}

class _SelectConditionViewState extends State<SelectConditionView> {
  
  List conditions = ["New", "Like new", "Good", "Fair", "Well-used"];
  String selectedCondition = '';

  @override
  void initState() {
    super.initState();
    selectedCondition = widget.selectedCondition;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical * 3),
      height: SizeConfig.blockSizeVertical * 40,
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
              'Condition',
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
              itemCount: conditions.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                return conditionCell(index);
              }
            ),
          ),

          Spacer(),
          GestureDetector(
            onTap: (){
              Get.back(result: selectedCondition);
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

  Widget conditionCell(int index){
    return GestureDetector(
      onTap: (){
        setState(() {
          selectedCondition = conditions[index];          
        });
      },
      child: Container(
        child: Row(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 4,
              width: SizeConfig.blockSizeVertical * 5,
              child: Icon(
                (selectedCondition == conditions[index])? Icons.check_circle_rounded : Icons.circle_outlined, 
                color: (selectedCondition == conditions[index]) ? Constants.appThemeColor : Colors.grey.withOpacity(0.4),
                size: SizeConfig.blockSizeVertical*2.5,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*1),
              child: Text(
                '${conditions[index]}',
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