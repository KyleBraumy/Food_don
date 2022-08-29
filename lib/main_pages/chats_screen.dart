import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../authentication/createpage.dart'as w;
import '../secondary_pages/chat_detail.dart';


final chatsListRef = FirebaseFirestore.instance.collection('chats_list');
final usersRef = FirebaseFirestore.instance.collection('users');
class Chats_screen extends StatefulWidget {


  @override
  State<Chats_screen> createState() => _Chats_screenState();
}



class _Chats_screenState extends State<Chats_screen> {
  var myProfileUrl;

//  final currentUser= auth.currentUser;
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
    super.initState();
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




  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot?>(
      stream: _chats_withStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
        if (snapshot.hasError){
          return Scaffold(
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
            body: Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Something went wrong'),
                  ],
                )
            ),
          );
        }
        if(snapshot.connectionState==ConnectionState.waiting){
          return Scaffold(
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
            body: Center(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Loading'),
                ],
              )
            ),
          );
        }
        if(snapshot.hasData &&  snapshot.data!.size==0){
          return Scaffold(
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
            body: Center(
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
            ),
          );
        }
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
          ///List of chats with other users
          body: ListView(
            children:snapshot.data!.docs
                .map((DocumentSnapshot document){
                  Map<String, dynamic> data=
                      document.data()! as Map<String,dynamic>;
                  var num=snapshot.data!.docs.length;
                    DateTime dt =(data['LastMessageTime']as Timestamp).toDate();
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: ()=>Navigator.push(context, MaterialPageRoute(
                              builder: (context)=> ChatDetail(
                                friendName:(data['Username']).toString(),
                                friendUid: (data['Id']).toString(),))),
                          child: ListTile(
                           dense: true,
                            title: Text((data['Username']).toString(),
                              style: TextStyle(
                                  color: Colors.green
                              ),
                            ),
                            subtitle: Text((data['LastMessage']).toString()),
                            trailing: Text(dt.toString(),
                              style: TextStyle(
                                fontSize: 11
                              ),
                            ),
                            leading: CircleAvatar(
                              radius: 25,
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl:(data['ProfilePhotoUrl']).toString(),
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
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  );


            })
                .toList()

                .cast(),

          ),
        );
        }
    );
  }
}
