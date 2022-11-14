// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, avoid_unnecessary_containers
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/app_controller.dart';
import '../../models/appuser.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';

class SetLocation extends StatefulWidget {
  const SetLocation({ Key? key }) : super(key: key);

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {

  late LatLng center;
  late GoogleMapController controller;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  @override
  void initState() {
    super.initState();
    center = LatLng(Constants.latitude, Constants.longitude);
    // Future.delayed(const Duration(seconds: 1), () {
    //   showInSnackBar('Long Press and hold the marker to set it to your location');
    // });
  }
  
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Constants.appThemeColor,
        content: new Text(value, style: TextStyle(color : Colors.white, fontSize: 1.8 * SizeConfig.fontSize),)
      )
    );
  }

  // void _onMapCreated(GoogleMapController cntlr)
  // {
  //   controller = cntlr;
  //   setState(() {
  //     markers.add(
  //       Marker(
  //         markerId: MarkerId("1"),
  //         position: LatLng(Constants.latitude, Constants.longitude),
  //         infoWindow: InfoWindow(
  //           title: "My Location",
  //           snippet: ''
  //         ),
  //         draggable: true,
  //         onDrag: (val){
  //           Constants.latitude = val.latitude;
  //           Constants.longitude = val.longitude;
  //           CameraPosition cPosition = CameraPosition(zoom: 12, target: LatLng(val.latitude, val.longitude),);
  //           controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  //         }
  //       )
  //     );

  //     CameraPosition cPosition = CameraPosition(zoom: 12, target: LatLng(Constants.latitude, Constants.longitude),);
  //     controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  //   });
  // }

  void _onMapCreated(GoogleMapController cntlr)
  {
    controller = cntlr;
    MarkerId markerId = MarkerId('1');
    Marker marker = Marker(
      markerId: MarkerId("1"),
      position: LatLng(Constants.latitude, Constants.longitude),
      infoWindow: InfoWindow(
        title: "My Location",
        snippet: ''
      ),
      draggable: false,
    );
    _markers[markerId] = marker;
    
    setState(() {
      CameraPosition cPosition = CameraPosition(zoom: 12, target: LatLng(Constants.latitude, Constants.longitude),);
      controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    });
  }

  
  void setLocationPressed() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getAddressDetail(Constants.latitude, Constants.longitude);
    if (result['Status'] == "Success") 
    {
      await AppUser().updateUserLocation(Constants.latitude, Constants.longitude, result['Locality']);
      EasyLoading.dismiss();
      Get.offAll(HomeScreen(defaultPage: 0,));
    }
    else
    {    
      EasyLoading.dismiss();
      Constants.showDialog('Unable to get your district. Try to adjust marker and try again');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [    
            
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1, left: SizeConfig.blockSizeHorizontal * 5, right: SizeConfig.blockSizeHorizontal * 5),
              child: Text(
                'Set your location',
                style: TextStyle(
                  color: Colors.black,
                  fontSize :SizeConfig.fontSize * 2.5,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2.5, left: SizeConfig.blockSizeHorizontal * 5, right: SizeConfig.blockSizeHorizontal * 5),
              child: Text(
                'Your location is not shown to others and is used to find listings nearby.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize : SizeConfig.fontSize * 1.6,
                ),
              ),
            ),  

            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
                    color: Colors.grey[300],
                    child: GoogleMap(
                        mapType: MapType.normal,
                        //enable zoom gestures
                        zoomGesturesEnabled: true,
                        onMapCreated: _onMapCreated,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 14.0,           
                      ),
                      onCameraMove: (val){
                        //selectedOffer = null;
                        if(_markers.length >0)
                        {
                          MarkerId markerId = MarkerId('1');
                          Marker marker = _markers[markerId]!;
                          Marker updatedMarker = marker.copyWith(
                            positionParam: val.target
                          );
                          setState(() {
                            _markers[markerId] = updatedMarker;
                            Constants.latitude = updatedMarker.position.latitude;
                            Constants.longitude = updatedMarker.position.longitude;
                          });
                        }
                      },
                      markers: Set<Marker>.of(_markers.values),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: setLocationPressed,
                      child: Container(
                        margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 5, left: SizeConfig.blockSizeHorizontal * 7, right: SizeConfig.blockSizeHorizontal * 7),
                        height: SizeConfig.blockSizeVertical *6,
                        decoration: BoxDecoration(
                          color: Constants.appThemeColor,
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Center(
                          child: Text(
                            'Set location here',
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
                  )
                ],
              ),
            )
            
          ]
        )
      )
    );
  }
}