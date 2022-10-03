import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:uuid/uuid.dart';
import '../authentication/createpage.dart';
import '../widgets/constant_widgets.dart';
import 'package:http/http.dart' as http;



class ChatDetail extends StatefulWidget {
  final friendUid;
  final friendName;
  final friendurl;
   String? chatDocId;

  ChatDetail({Key? key, this.friendUid, this.friendName,this.chatDocId,this.friendurl}) : super(key: key);

  @override
  _ChatDetailState createState() => _ChatDetailState(friendUid,friendName);
}

class _ChatDetailState extends State<ChatDetail> {

  final friendUid;
  final friendName;
  var friendmediaUrl;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  var currentUserfName;
  var currentUserlName;
  var currentUsn;
  var currentUserUrl;
  String messageId= Uuid().v4();
  final CollectionReference chatsRef = FirebaseFirestore.instance.collection(
      'chats');
  final CollectionReference chatsListRef = FirebaseFirestore.instance.collection(
      'chats_list');
  var mtoken;
  var ftoken;
  var loc;
  var _textController = new TextEditingController();
  _ChatDetailState(this.friendUid,this.friendName);
  @override
  void initState() {
    super.initState();
    getUsername();
    getFriendUrl();
    getToken();
    disable();
  }
  getUsername()async{
    if (currentUserId!=null)
      await usersRef
          .doc(currentUserId)
          .get()
          .then((ds){
        currentUserfName=ds.data()!['First Name'];
        currentUserlName=ds.data()!['Last Name'];
        loc=ds.data()!['City'];
        currentUsn=currentUserlName+" "+currentUserfName;
        currentUserUrl=ds.data()!['ProfilePhotoUrl'];
        //print(currentUserName);
      }).catchError((e){
        print(e);
      });
  }
  getFriendUrl()async{
    if (friendUid!=null)
      await usersRef
          .doc(friendUid)
          .get()
          .then((ds){
        friendmediaUrl=ds.data()!['ProfilePhotoUrl'];
        ftoken=ds.data()!['Token'];
        print(friendmediaUrl);
        print(ftoken);
      }).catchError((e){
        print(e);
      });
  }

disable()async{
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  );
}
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token) {
          setState(() {
            mtoken = token;
          });
          saveToken(token!);
        }
    );
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("users").doc(currentUserId).update({
      'Token' : token,
    });
  }



  void sendPushMessage(String token, String body, String title) async {
    getToken();
    disable();
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type':  'application/json',
          'Authorization': 'key=AAAAhKJQqG8:APA91bHbA9I4hZdzUGsQsR720btbjFIEL4rR-Y2EbPCZ3MObI9JdqQ8Ys4UK7pqk1_iGOSbGTrnSpuzLXrpRkDGJaD3I4j9QVzYcDWinbioAsRxA-FXO4KYFiObK4YOZXipzmhXPL0Qw',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to":token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }


  sendMessage(String msg) async{
    await getFriendUrl();
    final DateTime timestamp=DateTime.now();
    if (msg == '') {
      return null;
    }else{
      await chatsRef.doc(widget.chatDocId).collection('messages').doc(messageId).set({
        'createdOn': timestamp,
        'Sender_id': currentUserId,
        'Sender_Username': currentUserlName+currentUserfName,
        'Receiver_id':friendUid,
        'Receiver_Username':friendName,
        'msg': msg
      }).then((value) {
        _textController.text = '';
      });
      messageId= Uuid().v4();
      await chatsListRef.doc(currentUserId).collection('chats_with').doc(friendUid).set({
        'LastMessageTime': timestamp,
        'LastMessageSender':currentUserId,
        'LastMessage': msg,
        'Id': friendUid,
        'Username':friendName,
      });
      await chatsListRef.doc(friendUid).collection('chats_with').doc(currentUserId).set({
        'LastMessageTime': timestamp,
        'LastMessageSender':currentUserId,
        'LastMessage': msg,
        'Id': currentUserId,
        'Username':currentUserlName+currentUserfName,
      });
      sendPushMessage(mtoken,msg,currentUsn);
    }

  }

  bool isSender(String friend) {
    return friend == currentUserId;
  }

  Alignment getAlignment(friend) {
    if (friend == currentUserId) {
      return Alignment.topRight;
    }
    return Alignment.topLeft;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        title:Column(
          children: [
            CachedNetworkImage(
              imageUrl:widget.friendurl,
              imageBuilder: (context, imageProvider) => Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              placeholder: (context, url) => Icon(Icons.person_outline_rounded),
              errorWidget: (context, url, error) => Icon(Icons.person_outline_rounded),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomText7(friendName!.toString()),
            ),
          ],
        ),
        toolbarHeight:90,
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(Icons.info_outline_rounded),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatsRef
            .doc(widget.chatDocId)
            .collection('messages')
            .orderBy('createdOn', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong"),
            );
          }
          if (snapshot.connectionState==ConnectionState.waiting) {
            return Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text("Loading"),
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            var data;
            return  SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        reverse: true,
                        children: snapshot.data!.docs.map(
                          (DocumentSnapshot document) {
                            data = document.data()!;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ChatBubble(
                                clipper: ChatBubbleClipper6(
                                  nipSize: 10,
                                  radius: 9,
                                  type: isSender(data['Sender_id'].toString())
                                      ? BubbleType.sendBubble
                                      : BubbleType.receiverBubble,
                                ),
                                alignment: getAlignment(data['Sender_id'].toString()),
                                margin: EdgeInsets.only(top: 20),
                                backGroundColor: isSender(data['Sender_id'].toString())
                                    ? Color(0xFF08C187)
                                    : Color(0xffE7E7ED),
                                child: Container(
                                  child: FittedBox(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(data['msg'],
                                                style: TextStyle(
                                                    color: isSender(
                                                            data['Sender_id'].toString())
                                                        ? Colors.white
                                                        : Colors.black),
                                                maxLines: 100,
                                                overflow: TextOverflow.ellipsis)
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            CustomText6(
                                              data['createdOn']
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: CupertinoTextField(
                              controller: _textController,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        CupertinoButton(
                            child: Icon(Icons.send_sharp,color: Colors.green,),
                            onPressed: () => sendMessage(_textController.text))
                      ],
                    ),
                  ],
                ),
              );

          } else {
            return Container();
          }
        },
      ),
    );
  }
}




///Pre-chat loading
class Chatset extends StatefulWidget {
  final friendUid;
  final friendName;
  final friendurl;
  bool? isLoading;


  Chatset({Key? key, this.friendUid, this.friendName,this.friendurl,this.isLoading}) : super(key: key);

  @override
  _ChatsetState createState() => _ChatsetState(friendUid, friendName);
}

class _ChatsetState extends State<Chatset> {
  final DateTime timestamp=DateTime.now();
  final friendUid;
  final friendName;

  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  var chatDocId;
  var currentUserfName;
  var currentUserlName;
  var currentUserUrl;

  final CollectionReference chatsRef = FirebaseFirestore.instance.collection(
      'chats');
  final CollectionReference chatsListRef = FirebaseFirestore.instance.collection(
      'chats_list');


  _ChatsetState(this.friendUid,this.friendName);
  @override
  void initState() {
    super.initState();
    handling_chatset();
  }

   checkUser() async {
    await chatsRef
        .where('users', isEqualTo: {friendUid: null, currentUserId: null})
        .limit(1)
        .get()
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                chatDocId = querySnapshot.docs.single.id;
              });

            } else {
              setState((){
                getUsername();
                chatsRef.add({
                  'users': {currentUserId: null, friendUid: null},
                  'names':{currentUserId:currentUserlName+" "+currentUserfName,friendUid:friendName }
                }).then((value) => {chatDocId=value});
              });
              await checkUser();
            }
          },
        )
        .catchError((error) {});
  }
  getUsername()async{
    if (currentUserId!=null)
      await usersRef
          .doc(currentUserId)
          .get()
          .then((ds){
        currentUserfName=ds.data()!['First Name'];
        currentUserlName=ds.data()!['Last Name'];
        currentUserUrl=ds.data()!['ProfilePhotoUrl'];
        //print(currentUserName);
      }).catchError((e){
        print(e);
      });
  }


  handling_chatset()async{
    await getUsername();
    await checkUser();
    await chatDocId;
    widget.isLoading=false;
  }


  @override
  Widget build(BuildContext context) {
    return widget.isLoading==true?
    Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        title:Column(
          children: [
            CachedNetworkImage(
              imageUrl:widget.friendurl,
              imageBuilder: (context, imageProvider) => Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              placeholder: (context, url) => Icon(Icons.person_outline_rounded),
              errorWidget: (context, url, error) => Icon(Icons.person_outline_rounded),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomText8(friendName!.toString()),
            ),
          ],
        ),
        toolbarHeight:90,
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(Icons.info_outline_rounded),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text('Loading'),
        ],
      )):
    ChatDetail(chatDocId:chatDocId,
      friendUid:friendUid,
      friendName:friendName,
      friendurl:widget.friendurl,);
  }
}

