import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';


import '../authentication/createpage.dart';


final CollectionReference chatsRef = FirebaseFirestore.instance.collection(
    'chats');
final CollectionReference chatsListRef = FirebaseFirestore.instance.collection(
    'chats_list');

class ChatDetail extends StatefulWidget {
  final friendUid;
  final friendName;


  ChatDetail({Key? key, this.friendUid, this.friendName}) : super(key: key);

  @override
  _ChatDetailState createState() => _ChatDetailState(friendUid, friendName);
}

class _ChatDetailState extends State<ChatDetail> {
  final DateTime timestamp=DateTime.now();
  final friendUid;
  final friendName;
  var friendmediaUrl;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  var chatDocId;
  var currentUserfName;
  var currentUserlName;
  var currentUserUrl;


  var _textController = new TextEditingController();
  _ChatDetailState(this.friendUid,this.friendName);
  @override
  void initState() {
    super.initState();
    getUsername();
    getFriendUrl();
    checkUser();
  }

  void checkUser() async {
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

              print(chatDocId);
            } else {
              await getUsername();
              await chatsRef.add({
                'users': {currentUserId: null, friendUid: null},
                'names':{currentUserId:currentUserlName+" "+currentUserfName,friendUid:friendName }
              }).then((value) => {chatDocId = value});
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
  getFriendUrl()async{
    if (friendUid!=null)
      await usersRef
          .doc(friendUid)
          .get()
          .then((ds){
        friendmediaUrl=ds.data()!['ProfilePhotoUrl'];
        print(friendmediaUrl);
      }).catchError((e){
        print(e);
      });
  }

  void sendMessage(String msg) async{
    if (msg == '') return;
   await chatsRef.doc(chatDocId).collection('messages').add({
      'createdOn': timestamp,
      'Sender_id': currentUserId,
      'Sender_Username': currentUserlName+currentUserfName,
      'Receiver_id':friendUid,
      'Receiver_Username':friendName,
      'msg': msg
    }).then((value) {
      _textController.text = '';
    });
    await chatsListRef.doc(currentUserId).collection('chats_with').doc(friendUid).set({
      'LastMessageTime': timestamp,
      'LastMessage': msg,
      'Id': friendUid,
      'Username':friendName,
      'ProfilePhotoUrl': friendmediaUrl,
    });
    await chatsListRef.doc(friendUid).collection('chats_with').doc(currentUserId).set({
      'LastMessageTime': timestamp,
      'LastMessage': msg,
      'Id': currentUserId,
      'Username':currentUserlName+currentUserfName,
      'ProfilePhotoUrl': currentUserUrl,
    });


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
    return StreamBuilder<QuerySnapshot>(
      stream: chatsRef
          .doc(chatDocId)
          .collection('messages')
          .orderBy('createdOn', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something went wrong"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text("Loading"),
          );
        }

        if (snapshot.hasData) {
          var data;
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              iconTheme: IconThemeData(
                  color: Colors.orange
              ),
              title:Column(
                children: [
                  CircleAvatar(
                    radius: 17,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl:friendmediaUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  Text(friendName,
                    style: TextStyle(color: Colors.orange,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,),
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
           body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      reverse: true,
                      children: snapshot.data!.docs.map(
                        (DocumentSnapshot document) {
                          data = document.data()!;
                          print(document.toString());
                          print(data['msg']);
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ChatBubble(
                              clipper: ChatBubbleClipper6(
                                nipSize: 0,
                                radius: 0,
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
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
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
                                        Text(
                                          data['createdOn'] == null
                                              ? DateTime.now().toString()
                                              : data['createdOn']
                                                  .toDate()
                                                  .toString(),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: isSender(
                                                      data['Sender_id'].toString())
                                                  ? Colors.white
                                                  : Colors.black),
                                        )
                                      ],
                                    )
                                  ],
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
                  )
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
