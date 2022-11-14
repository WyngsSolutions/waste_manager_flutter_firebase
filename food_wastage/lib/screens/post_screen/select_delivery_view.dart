// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class DeliverySelectionView extends StatefulWidget {

  final String selectedDeliveryMethod;
  const DeliverySelectionView({ Key? key, required this.selectedDeliveryMethod }) : super(key: key);

  @override
  State<DeliverySelectionView> createState() => _DeliverySelectionViewState();
}

class _DeliverySelectionViewState extends State<DeliverySelectionView> {
    
  List deliveryList = ["Collection", "Delivery"];
  List selectedDeliveries = [];

  @override
  void initState() {
    super.initState();
    if(widget.selectedDeliveryMethod.isNotEmpty)    
      selectedDeliveries = widget.selectedDeliveryMethod.split(',');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical * 3),
      height: SizeConfig.blockSizeVertical * 28,
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
              'Delivery method',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.fontSize * 2.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical* 1.5),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: deliveryList.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                return deliveryCell(index);
              }
            ),
          ),

          Spacer(),
          GestureDetector(
            onTap: (){
              Get.back(result: selectedDeliveries.join(","));
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

  Widget deliveryCell(int index){
    return GestureDetector(
      onTap: (){
        setState(() {
          if(selectedDeliveries.contains(deliveryList[index]))
            selectedDeliveries.remove(deliveryList[index]);
          else
            selectedDeliveries.add(deliveryList[index]);
        });
      },
      child: Container(
        child: Row(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 4,
              width: SizeConfig.blockSizeVertical * 5,
              child: Icon(
                (selectedDeliveries.contains(deliveryList[index]))? Icons.check_circle_rounded : Icons.circle_outlined, 
                color: (selectedDeliveries.contains(deliveryList[index])) ? Constants.appThemeColor : Colors.grey.withOpacity(0.4),
                size: SizeConfig.blockSizeVertical*2.5,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*1),
              child: Text(
                '${deliveryList[index]}',
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