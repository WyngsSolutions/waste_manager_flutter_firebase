// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, unnecessary_string_interpolations
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_helper.dart';
import '../../models/appuser.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../chat_screen/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({ Key? key }) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  
  Stream<QuerySnapshot>? chatRoomsStream;
  
  @override
  void initState() {
    super.initState();
    ChatDatabaseModel().getUserChatRooms(Constants.appUser.userId).then((value){
      setState(() {
        chatRoomsStream = value;        
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Chats',
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
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*5),
        child: chatMessageList(),
      ),
    );
  }

  Widget chatMessageList(){
    return StreamBuilder<QuerySnapshot>(
      stream: chatRoomsStream,
      builder: (context, snapshot){
        return snapshot.hasData ? (snapshot.data!.docs.length > 0) ? MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index){
              dynamic cellData = snapshot.data!.docs[index].data();
              String chatUserID = cellData['chatRoomId'];
              chatUserID = chatUserID.replaceFirst("_", "");
              chatUserID = chatUserID.replaceFirst("${Constants.appUser.userId}", "");
              String userName = cellData['${chatUserID}_name'];
              return MessageCell(messageData: snapshot.data!.docs[index].data() as Map<dynamic, dynamic>);
            }
          ),
        ) : Container(
          margin: EdgeInsets.only(bottom: 50),
          child: Center(
            child: Text(
              'No Messages',
              style: TextStyle(
                color : Colors.grey[500],
                fontSize : SizeConfig.fontSize * 2.0,
              ),
            ),
          ),
        )
        : Container();
      }
    );
  }
}

class MessageCell extends StatefulWidget {

  final Map messageData;
  const MessageCell({required this.messageData});

  @override
  _MessageCellState createState() => _MessageCellState();
}

class _MessageCellState extends State<MessageCell> {

  AppUser chatUser = AppUser();
  String chatUserID = "";
  String chatRoomId = "";
  
  @override
  void initState() {
    super.initState();
    chatRoomId = widget.messageData['chatRoomId'];
    chatUserID = widget.messageData['chatRoomId'];
    chatUserID = chatUserID.replaceFirst("_", "");
    chatUserID = chatUserID.replaceFirst("${Constants.appUser.userId}", "");
    chatUser.userName = widget.messageData['${chatUserID}_name'];
    chatUser.oneSignalUserID = widget.messageData['${chatUserID}_token'];
    chatUser.userPicture = widget.messageData['${chatUserID}_picture'];
    chatUser.userId = chatUserID;
    //getUserDetail();
  }

  // void deleteChatCell(BuildContext context) async {
  //   EasyLoading.show(status: '${AppLanguage.getLanguageWord('please_wait')}', maskType: EasyLoadingMaskType.black,);
  //   await ChatDatabaseModel().deleteChatRoom(chatRoomId);
  //   EasyLoading.dismiss();
  // }

  @override
  Widget build(BuildContext context) {
    final lastMsgTime = widget.messageData['lastMessageTimeStamp'].toDate();
    String dateText = timeago.format(lastMsgTime, locale: 'en'); 
    return GestureDetector(
      onTap: (){
        Get.to(ChatScreen(chatUser: chatUser));
      },
      child: Container(
        margin: EdgeInsets.only(top: 15),
        height: SizeConfig.blockSizeVertical * 8,
        child: Row(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 7,
              width: SizeConfig.blockSizeVertical * 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                  image: (chatUser.userPicture .isEmpty) ?  AssetImage('assets/placeholder.png') as ImageProvider : CachedNetworkImageProvider(chatUser.userPicture),
                  fit: BoxFit.cover
                )
              ),
            ),
          
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*4, right: 5, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${chatUser.userName}',
                              style: TextStyle(
                                color: Constants.appThemeColor,
                                fontSize:  SizeConfig.fontSize * 1.8,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                           Text(
                            '$dateText',
                            style: TextStyle(
                              color: Colors.grey[500], fontSize:  SizeConfig.fontSize * 1.5, fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0.3),
                      child: Text(
                        '${widget.messageData['last_msg']}',
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey[500], fontSize:  SizeConfig.fontSize * 1.6, fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
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