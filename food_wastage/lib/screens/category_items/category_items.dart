import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/app_controller.dart';
import '../../models/products.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../item_detail_screen/item_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemListScreen extends StatefulWidget {

  final String categoryName;
  const ItemListScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  
  List<Product> categoryProducts = [];

  @override
  void initState() {
    super.initState();
    getAllProducts();
  }

  void getAllProducts() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getAllCategoryProducts(widget.categoryName);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        categoryProducts = result['CategoryProducts'];        
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
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              widget.categoryName,
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
      body: (categoryProducts.isEmpty) ? Container(
        child: Center(
          child: Text(
            'No Products Found',
            maxLines: 1,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: SizeConfig.fontSize * 2,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ) :Container(
        child: ListView.builder(
          itemCount: categoryProducts.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return itemCell(categoryProducts[index],index);
          }
        ),
      ),
    );
  }

  Widget itemCell(Product product, int index){

    DateTime productDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(product.productAddedDate);
    String formattedDate = timeago.format(productDate);

    return GestureDetector(
      onTap: (){
        Get.to(ItemDetailScreen(product: product,));
      },
      child: Container(
        margin: EdgeInsets.only(left : SizeConfig.blockSizeHorizontal*3, right: SizeConfig.blockSizeHorizontal*3),
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
                        //'${product.productAreaLocality}  ($formattedDate)',
                        '${product.distanceInKm} km  posted $formattedDate',
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
                        '\$${product.productPrice}',
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
                          Icon(Icons.favorite_border, size: SizeConfig.blockSizeVertical * 2.5, color: Colors.grey,),
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