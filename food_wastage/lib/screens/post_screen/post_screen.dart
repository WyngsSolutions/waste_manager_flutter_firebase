// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_wastage/screens/post_screen/select_condition_view.dart';
import 'package:food_wastage/screens/set_location/set_product_location.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';
import 'select_age_view.dart';
import 'select_category.dart';
import 'select_delivery_view.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({ Key? key }) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  TextEditingController productName = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  TextEditingController productDescription = TextEditingController();
  TextEditingController productExtra = TextEditingController();
  String selectedCategory = "";
  String selectedCondition = "";
  String selectedDeliveryMethod = "";
  String selectedAge = "";
  final ImagePicker _picker = ImagePicker();
  File? image;
  final ImagePicker picker = ImagePicker();
  LatLng? productCoordinates;

  @override
  void initState() {
    super.initState();
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery,);
    if(pickedFile != null)
    {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  void showConditionSelectionView()async
  {
    dynamic result = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc){
        return SelectConditionView(selectedCondition: selectedCondition,);
      }
    );
    if(result != null)
      setState(() => selectedCondition = result);
  }

  void showDeliverySelectionView()async
  {
    dynamic result = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc){
        return DeliverySelectionView(selectedDeliveryMethod: selectedDeliveryMethod,);
      }
    );
    if(result != null)
      setState(() => selectedDeliveryMethod = result);
  }

  void showAgeSelectionView()async
  {
    dynamic result = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc){
        return const SelectAgeView();
      }
    );
    if(result != null)
      setState(() => selectedAge = result);
  }

  void postProduct() async {
    if(productName.text.isEmpty)
      Constants.showDialog('Please enter product title');
    else if(selectedCategory.isEmpty)
      Constants.showDialog('Please enter product category');
    else if(productPrice.text.isEmpty)
      Constants.showDialog('Please enter product price');
    else if(productDescription.text.isEmpty)
      Constants.showDialog('Please enter product description');
    else if(selectedCondition.isEmpty)
      Constants.showDialog('Please enter product condition');
    else if(selectedDeliveryMethod.isEmpty)
      Constants.showDialog('Please enter product delivery method');
    else if(!isSelectedCategoryExtraFilled())
      Constants.showDialog('Please enter missing details');
    else if(image==null)
      Constants.showDialog('Please select product image');
    else if(productCoordinates == null)
    {
      dynamic resultCoordinates = await Get.to(SetProductLocation());
      if(resultCoordinates == null)
        return;
      else
      {
        productCoordinates = resultCoordinates;
        EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
        dynamic result = await AppController().addProductPressed(productName.text, selectedCategory, productPrice.text, productDescription.text, selectedCondition, selectedDeliveryMethod, selectedAge, productExtra.text, image!, productCoordinates!);
        EasyLoading.dismiss();
        if (result['Status'] == "Success") 
        {
          Get.offAll(HomeScreen(defaultPage: 0,));
          Constants.showDialog('Your product has been posted successfully');
        }
        else
        {
          Constants.showDialog(result['ErrorMessage']);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Post Item',
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 4, vertical: SizeConfig.blockSizeVertical * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              
            GestureDetector(
              onTap: getImageFromGallery,
              child: Center(
                child: Container(
                  height: SizeConfig.blockSizeVertical *16,
                  width: SizeConfig.blockSizeVertical *16,
                  margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical *1, top : SizeConfig.blockSizeVertical *1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: (image != null) ? FileImage(image!) : const AssetImage('assets/placeholder.png') as ImageProvider,
                      fit: BoxFit.cover
                    )
                  ),
                ),
              ),
            ),

              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 0.5
                    )
                  )
                ),
                child: Center(
                  child: TextField(
                    style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                    controller: productName,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter a post title',
                      hintStyle: TextStyle(color: Colors.grey[400]!, fontSize: SizeConfig.fontSize * 1.8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3)
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () async {
                  dynamic result = await Get.to(SelectCategory(selectedCategory: selectedCategory));
                  if(result != null)
                  {
                    setState((){ 
                      selectedCategory = result;
                      productExtra.text = "";
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3),
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
                        (selectedCategory.isEmpty) ? 'Category' : selectedCategory,
                        style: TextStyle(color: (selectedCategory.isEmpty) ? Colors.grey[400]! : Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[400]!, size: SizeConfig.blockSizeVertical * 2,)
                    ],
                  ),
                ),
              ),

              Container(
                 decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 0.5
                    )
                  )
                ),
                child: Center(
                  child: TextField(
                    controller: productPrice,
                    textAlignVertical: TextAlignVertical.center,
                    //keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Set price i.e Free',
                      hintStyle: TextStyle(color: Colors.grey[400]!, fontSize: SizeConfig.fontSize * 1.8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3),
                      suffix: Text(
                        '',
                        style: TextStyle(color: Colors.grey[400]!, fontSize: SizeConfig.fontSize * 2.2,),
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 0.5
                    )
                  )
                ),
                child: Center(
                  child: TextField(
                    minLines: 8,
                    maxLines: 8,
                    controller: productDescription,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Describe item in detail',
                      hintStyle: TextStyle(color: Colors.grey[400]!, fontSize: SizeConfig.fontSize * 1.8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: showConditionSelectionView,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3),
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
                        'Condition',
                        style: TextStyle(color: (selectedCondition.isEmpty) ? Colors.grey[400]! : Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[400]!, size: SizeConfig.blockSizeVertical * 2,)
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: showDeliverySelectionView,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3),
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
                        'Delivery method',
                        style: TextStyle(color: (selectedDeliveryMethod.isEmpty) ? Colors.grey[400]! : Colors.black, fontSize: SizeConfig.fontSize * 1.8),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[400]!, size: SizeConfig.blockSizeVertical * 2,)
                    ],
                  ),
                ),
              ),

              extraCategoryFieldView(),

              GestureDetector(
                onTap: postProduct,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3),
                  height: SizeConfig.blockSizeVertical *6,
                  decoration: BoxDecoration(
                    color:  Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(
                    child: Text(
                      'Post',
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

            ],
          ),
        ),
      ),
    );
  }

  Widget productImageView(File? productImage, int index){
    return GestureDetector(
      onTap: (){
        getImageFromGallery();
      },
      child: Container(
        margin: EdgeInsets.only(left: (index==1) ? 0 : SizeConfig.blockSizeHorizontal * 4),
        height: SizeConfig.blockSizeVertical * 10,
        width: SizeConfig.blockSizeVertical * 10,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1
          )
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            (productImage == null) ? imageNotSetView(index) : Image.file(productImage, fit: BoxFit.cover,),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    image = null;
                  });
                },
                child: (productImage == null) ? Container() : Container(
                  color: Constants.appThemeColor,
                  height: SizeConfig.blockSizeVertical*2.5,
                  child: Center(child: Icon(Icons.close, color: Colors.white, size: SizeConfig.blockSizeVertical *2.5,))
                ),
              ),
            )
          ],
        )
      ),
    );
  }

  Widget imageNotSetView(int index){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, color: Colors.grey[300], size:  SizeConfig.blockSizeVertical * 3.5,),
      ],
    );
  }

  Widget extraCategoryFieldView(){
    if(selectedCategory == "Electronics & appliances")
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5
          )
        )
      ),
      child: Center(
        child: TextField(
          style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
          controller: productExtra,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Brand',
            hintStyle: TextStyle(color: Colors.grey[400]!, fontSize: SizeConfig.fontSize * 1.8),
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3)
          ),
        ),
      ),
    );

    else if(selectedCategory == "Furniture")
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5
          )
        )
      ),
      child: Center(
        child: TextField(
          style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
          controller: productExtra,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Dimensions W x D x H',
            hintStyle: TextStyle(color: Colors.grey[400]!, fontSize: SizeConfig.fontSize * 1.8),
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3)
          ),
        ),
      ),
    );

    else if(selectedCategory.contains('fashion'))
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5
          )
        )
      ),
      child: Center(
        child: TextField(
          style: TextStyle(color: Colors.black, fontSize: SizeConfig.fontSize * 1.8),
          controller: productExtra,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Size',
            hintStyle: TextStyle(color: Colors.grey[400]!, fontSize: SizeConfig.fontSize * 1.8),
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3)
          ),
        ),
      ),
    );

    else if(selectedCategory == "Baby & kids")
    return GestureDetector(
      onTap: showAgeSelectionView,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: SizeConfig.blockSizeVertical * 3),
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
              'Age',
              style: TextStyle(color: (selectedAge.isEmpty) ? Colors.grey[400]! : Colors.black, fontSize: SizeConfig.fontSize * 1.8),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]!, size: SizeConfig.blockSizeVertical * 2,)
          ],
        ),
      ),
    );
    else
    return Container();
  }

  bool isSelectedCategoryExtraFilled(){
    if(selectedCategory == "Electronics & appliances" && productExtra.text.isEmpty)  
      return false;
    else if(selectedCategory == "Baby & kids" && selectedAge.isEmpty)  
      return false;
    else if(selectedCategory.contains('fashion') && productExtra.text.isEmpty)  
      return false;
    else if(selectedCategory == "Furnitures" && productExtra.text.isEmpty)  
      return false;
    else
      return true;
  }
}