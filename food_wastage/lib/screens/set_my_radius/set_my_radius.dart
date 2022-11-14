// ignore_for_file: curly_braces_in_flow_control_structures, avoid_unnecessary_containers, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/appuser.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class SetMyRadius extends StatefulWidget {
  const SetMyRadius({ Key? key }) : super(key: key);

  @override
  State<SetMyRadius> createState() => _SetMyRadiusState();
}

class _SetMyRadiusState extends State<SetMyRadius> {

  double radiusInKm = 0; 
  double radiusOnly = 20;

  @override
  void initState() {
    super.initState();
    radiusOnly = Constants.appUser.searchRadius.toDouble();
    radiusInKm = radiusOnly * 1000;
  }

  Future<void> donePressed() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppUser().updateSearchRadius(radiusOnly.toInt());
    EasyLoading.dismiss();
    if (result) 
      Get.back();
    else
      Constants.showDialog(result['ErrorMessage']);
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
              'Manage Neighbourhood',
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
        child: Stack(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 65,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(
                  width: 1,
                  color: Colors.grey[300]!,
                )
              ),
              child: GoogleMap(
                  mapType: MapType.normal,
                  //enable zoom gestures
                  zoomGesturesEnabled: true,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  initialCameraPosition: CameraPosition(
                  target: LatLng(Constants.appUser.latitude, Constants.appUser.longitude),
                  zoom: 10.0,           
                ),
                circles: {Circle(
                  circleId: CircleId('1'),
                  center: LatLng(Constants.appUser.latitude, Constants.appUser.longitude),
                  radius: radiusInKm,
                  fillColor: Constants.appThemeColor.withOpacity(0.3),
                  strokeColor: Constants.appThemeColor.withOpacity(0.05),
                )},
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 60),
              padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 4, SizeConfig.blockSizeVertical * 3, SizeConfig.blockSizeHorizontal * 3,  SizeConfig.blockSizeVertical * 2),
              height: SizeConfig.blockSizeVertical * 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20)
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Viewing listing within ${radiusOnly.toInt()}km',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.fontSize * 2.1,
                      fontWeight: FontWeight.w500
                    ),
                  ),

                  Expanded(
                    child: Container(
                      child: Slider(
                        max: 20,
                        min: 1,
                        activeColor: Constants.appThemeColor,
                        inactiveColor: Colors.grey,
                        value: radiusOnly,
                        onChanged: (val){
                          setState(() {
                            radiusOnly = val;     
                            radiusInKm = radiusOnly * 1000;                     
                          });
                        }
                      ),
                    )
                  ),

                  GestureDetector(
                    onTap: donePressed,
                    child: Container(
                      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical* 2),
                      height: SizeConfig.blockSizeVertical *6,
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
            ),

            
          ],
        ),
      ),
    );
  }
}