import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../authentication/createpage.dart'as w;
import '../models/userfiles.dart';
import '../secondary_pages/chat_detail.dart';
import '../widgets/constant_widgets.dart';



class Chats_screen extends StatefulWidget {


  @override
  State<Chats_screen> createState() => _Chats_screenState();
}



class _Chats_screenState extends State<Chats_screen> {
  var myProfileUrl;
  final chatsListRef = FirebaseFirestore.instance.collection('chats_list');
  final usersRef = FirebaseFirestore.instance.collection('users');
 final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  final Stream<QuerySnapshot?>_chats_withStream=FirebaseFirestore.instance
      .collection('chats_list')
      .doc(w.auth.currentUser!.uid)
      .collection('chats_with')
      .orderBy('LastMessageTime',descending: true)
      .snapshots();
  bool isLoading=false;

  @override
  void initState() {

    getMyURl();
    enable();
    super.initState();
  }

  void enable()async{
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  getMyURl()async{
    if (w.auth.currentUser!.uid==null)
      await usersRef
          .doc(w.auth.currentUser!.uid)
          .get()
          .then((ds){
        myProfileUrl=ds.data()!['ProfilePhotoUrl'];
       // print(currentUserName);
      }).catchError((e){
        print(e);
      });
  }


var friendurl;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.green.shade100.withOpacity(0.1),
      appBar:AppBar(
        //centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        title:Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 30,
            ),
            Text('Chats',
              style: TextStyle(
                  fontFamily: 'Gotham',
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
        toolbarHeight:100,
        backgroundColor: Colors.white,
      ),
     body:StreamBuilder<QuerySnapshot?>(
         stream: _chats_withStream,
         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
           if (snapshot.hasError){
             return  Center(
                 child:Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     CircularProgressIndicator(),
                     Text('Something went wrong'),
                   ],
                 )
             );

           }
           if(snapshot.connectionState==ConnectionState.waiting){
             return Center(
                 child:Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     CircularProgressIndicator(),
                     Text('Loading'),
                   ],
                 )
             );
           }
           if(snapshot.hasData &&  snapshot.data!.size==0){
             return  Center(
                 child:Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [

                     Text('No chats yet...',
                       style: TextStyle(
                           color: Colors.black.withOpacity(0.5)
                       ),
                     ),
                   ],
                 )
             );
           }
           return ListView(
             children:snapshot.data!.docs
                 .map((DocumentSnapshot document){
               Map<String, dynamic> data=
               document.data()! as Map<String,dynamic>;
               return Container(
                 margin: EdgeInsets.only(top:8),
                 color: Colors.white,
                 child: Column(
                   children: [
                     GestureDetector(
                       onTap: ()=>Navigator.push(context, MaterialPageRoute(
                           builder: (context)=> Chatset(
                             friendName:(data['Username']).toString(),
                             friendUid: (data['Id']).toString(),
                             friendurl:friendurl,
                           ))),
                       child: ListTile(
                         dense: true,
                         title: CustomText2((data['Username']).toString(),
                         ),
                         subtitle:Text((data['LastMessage']).toString(),
                           style: TextStyle(
                             fontWeight:data['LastMessageSender'].toString()==currentUserId?null:
                             FontWeight.bold,
                             color: data['LastMessageSender'].toString()==currentUserId?Colors.grey:
                             Colors.blue,
                             fontStyle: data['LastMessageSender'].toString()==currentUserId?FontStyle.italic:
                             null,
                           ),
                         ),

                         trailing: Column(
                           children: [

                             CustomText6(data['LastMessageTime'],
                             ),
                           ],
                         ),
                         leading: FutureBuilder(
                           future: usersRef.doc(data['Id']).get(),
                           //Resolve Value Available In Our Builder Function
                           builder: (context, snapshot) {
                             if (!snapshot.hasData) {
                               return Container(
                                 height: 45,
                                 width: 45,
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(50),
                                 ),
                                 child: Icon(Icons.person_outline_rounded),
                               );
                             }

                             //Deserialize
                             //print(widget.profileId);
                             var DocData = snapshot.data as DocumentSnapshot;
                             GUser gUser = GUser.fromDocument(DocData);
                             friendurl=gUser.profilePhotoUrl.toString();
                             return CachedNetworkImage(
                               imageUrl:gUser.profilePhotoUrl.toString(),
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
                             );
                           },
                         ),


                       ),
                     ),
                   ],
                 ),
               );


             })
                 .toList()

                 .cast(),

           );
         }
     ),
    );
  }
}
