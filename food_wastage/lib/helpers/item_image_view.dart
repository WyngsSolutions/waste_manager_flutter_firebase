// ignore_for_file: prefer_const_constructors_in_immutables, avoid_unnecessary_containers, prefer_const_constructors, library_private_types_in_public_api, sized_box_for_whitespace
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/size_config.dart';
import 'photo_list_screen.dart';

class ItemImageView extends StatefulWidget {

  final List adsList;
  ItemImageView({super.key, required this.adsList});

  @override
  _ItemImageViewState createState() => _ItemImageViewState();
}

class _ItemImageViewState extends State<ItemImageView> {

  SwiperController swiperController = SwiperController();
  int currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      onTap: (){
        Get.to(PhotoListScreen(galleryItems: widget.adsList));
      },
      child: Container(
        child : Stack(
         // mainAxisAlignment: MainAxisAlignment.center,
          children: [        
            Container(
              //color: Colors.black,
              width: SizeConfig.blockSizeHorizontal * 100,
              height: SizeConfig.blockSizeVertical * 33,
              child: Swiper(
                controller: swiperController,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.adsList[currentIndex]),
                        fit: BoxFit.cover
                      )
                    ),
                  );
                },
                onIndexChanged: (value){
                  setState(() {
                    currentIndex = value;                                        
                  });
                },
                autoplay: true,
                itemCount: widget.adsList.length,
                scrollDirection: Axis.horizontal,
                pagination: SwiperPagination(
                  alignment: Alignment.centerRight,
                  builder: SwiperPagination.rect
                ),
                control: SwiperControl(
                  color: Colors.transparent
                ),
              ),
            ),
    
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 30),
              child: DotsIndicator(
                dotsCount: widget.adsList.length,
                position: currentIndex.toDouble(),
                decorator: DotsDecorator(
                  activeColor: Colors.black,
                  color: Colors.grey[300]!,
                  size: const Size.square(9.0),
                  activeSize: const Size.square(9.0),
                  activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                ),
              ),
            )
          ]
        ),
      ),
    );
  }
}