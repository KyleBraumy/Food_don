
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sates/models/usermods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sates/startup/startpage.dart';

import '../admin_pages/admin_home.dart';
import '../authentication/createpage2.dart';
import '../main_pages/home.dart';
import '../models/userfiles.dart';


class Wrapper extends StatelessWidget {
String? id;
Wrapper({this.id});
handleDeleteonExpiry()async{

  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  final DateTime timestamp= DateTime.now();
  final requestsTimelineRef = FirebaseFirestore.instance.collection('requestsTimeline');

  await StreamBuilder<QuerySnapshot?>(
      stream:FirebaseFirestore.instance
          .collection('requestsTimeline')
          .where('Expire_at',isGreaterThan:timestamp)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
        return ListView(
          children:snapshot.data!.docs
              .map((DocumentSnapshot document){
            Map<String, dynamic> data=
            document.data()! as Map<String,dynamic>;
            var id=data['OwnerID'].toString();
            var request_id=data['RequestId'].toString();
            print(request_id);
            return requestsTimelineRef
                .doc(request_id)
                .delete();

          })
              .toList()

              .cast(),

        );
      }
  );




}


  @override
  Widget build(BuildContext context) {

    final user = Provider.of<USER?>(context);
    //Either select or log in page
    if (user == null){
      return Startpage();
    }else {
      /*if (id!=null){

        return StreamBuilder(
            stream: usersRef.doc(id).snapshots(),
            //Resolve Value Available In Our Builder Function
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text('null'));
              }
              //Deserialize
              //print(widget.profileId);
              var DocData = snapshot.data as DocumentSnapshot;
              Usn usn =Usn.fromDocument(DocData);
              return usn.fname==null?createpage2():home(pgindex: 1,);
            }

        );
      }else{
        final currentUserId= FirebaseAuth.instance.currentUser!.uid;
        return StreamBuilder(
            stream: usersRef.doc(currentUserId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text('null'));
              }
              //Deserialize
              //print(widget.profileId);
              var DocData = snapshot.data as DocumentSnapshot;
              Usn usn =Usn.fromDocument(DocData);

              return usn.fname==null?createpage2():home(pgindex: 1,);
            }

        );
      }*/
      if (id!=null){
        return StreamBuilder(
            stream: usersRef
                .doc(id)
                .snapshots(),
            //Resolve Value Available In Our Builder Function
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  body:Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              //Deserialize
              //print(widget.profileId);
              var DocData = snapshot.data as DocumentSnapshot;
              Usn usn =Usn.fromDocument(DocData);
              return usn.fname==null?createpage2():
              (usn.identify_as=='Admin'&&usn.fname=='Admin')?A_home():
              home(pgindex: 0,);
            }

        );
      }else{
        final currentUserId= FirebaseAuth.instance.currentUser!.uid;
        return StreamBuilder(
            stream: usersRef.doc(currentUserId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  body:Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              //Deserialize
              //print(widget.profileId);
              var DocData = snapshot.data as DocumentSnapshot;
              Usn usn =Usn.fromDocument(DocData);
              return usn.fname==null?createpage2():
              (usn.identify_as=='Admin'&&usn.fname=='Admin')?A_home():
              home(pgindex: 0,);
            }

        );
      }


    }
  }
}
