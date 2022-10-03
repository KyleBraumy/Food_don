import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sates/main_pages/timeline.dart';
import 'package:sates/main_pages/profile.dart';

import 'package:uuid/uuid.dart';

import '../secondary_pages/makePostForm.dart';
import '../widgets/constant_widgets.dart';
import 'requests_screen.dart';
import '../sidebar.dart';
import 'chats_screen.dart';
import '../secondary_pages/edit_profile.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');


class home extends StatefulWidget {
int pgindex;
home({required this.pgindex});
  @override
  State<home> createState() => _homeState(

  );
}

class _homeState extends State<home> {
  final currentUser= auth.currentUser!;
  String postId=Uuid().v4();
  final PageController _pageController= PageController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
int pageIndex=0;
  final requestsTimelineRef = FirebaseFirestore.instance.collection('requestsTimeline');
  bool? NoUrl;
    //int pageIndex=0;
    @override
    void initstate(){
      //checkUser();
     // getPhotoUrl();
     //getUsername();
   /*  getProfilePosts();
     getUsername();*/
      //checkpostnum();
     super.initState();
    }


  String? Url;
  String? Username;
  Future<String> url() async {
    DocumentSnapshot docS = await usersRef.doc(auth.currentUser!.uid).get();
    String urL = (docS.data() as Map)["ProfilePhotoUrl"];
    return urL;
  }
bool isLoading=false;
  Future<String> username() async {
    DocumentSnapshot docS = await usersRef.doc(auth.currentUser!.uid).get();
    String userName = (docS.data() as Map)["Username"];
    return userName;
  }
  bool isValid=false;
  checkpostnum() async {
    setState((){
     isLoading=true;
    });
    final currentUserId= FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snapshot = await requestsTimelineRef
        .where('OwnerID',isEqualTo:currentUserId)
        .orderBy('Timestamp',descending: true)
        .limit(3)
        .get();
    setState((){
      isLoading=false;
      postnum=snapshot.docs.length;
      isValid=true;
      print(postnum);
    });

  }

var postnum;

  @override
      void dispose(){
      _pageController.dispose();
      super.dispose();
      }

    onPageChanged(int pageIndex){
      setState((){
        this.pageIndex = pageIndex;
      });
    }
    onTap(int pageIndex){
    _pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 250),
      curve: Curves.bounceInOut
    );
    }
  ///edit profile options
  select(){
    return showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            title: Text('Youve had enough'),
            children: [
              SimpleDialogOption(
                child:Text('Exit'),
                onPressed: ()=>Navigator.pop(context),
              ),
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
   return Scaffold(
      body: PageView(
        controller:  _pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Timeline(),
          Requests_screen(),
          Chats_screen(),
          Profile(profileId:currentUser.uid),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 50,
        index: widget.pgindex,
        onTap: onTap,
        animationDuration: Duration(milliseconds: 100),
        buttonBackgroundColor: Colors.green.shade100,
        animationCurve: Curves.bounceInOut,
        backgroundColor: Colors.white,
        color: Colors.white,
        items: [
          Icon(Icons.feed,
            color: Colors.orange,
            semanticLabel: 'Home',
          ),
          Icon(Icons.add,
            color: Colors.orange,
            semanticLabel: 'Requests',
          ),
          Icon(Icons.mail_outline,
            color: Colors.orange,
            semanticLabel: 'Messages',
          ),
          Icon(Icons.account_box,
            color: Colors.orange,
            semanticLabel: 'Profile',
          ),
        ],
      ),
     floatingActionButton: ExpandableFab(
       distance: 50,
       children: [
         ///Share Icon and text
         GestureDetector(
           onTap: ()=>showModalBottomSheet(
               isScrollControlled: true,
               //barrierDismissible: true,
               //semanticsDismissible: true,
               barrierColor: Colors.black.withOpacity(0.2),
               context: context,
               builder: (BuildContext context){
                 return DraggableScrollableSheet(
                   initialChildSize: 0.9,
                   minChildSize: 0.5,
                   maxChildSize: 0.9,
                   expand: false,
                   builder:
                       (BuildContext context, ScrollController scrollController) {
                     return ShareForm(isOrgInd:false,);
                   },

                 );}),
           child: Row(
             children: [
               Container(
                 height:55,
                 width: 70,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: Colors.green.shade200,
                 ),
               ),
               Text('Share',
                 style: TextStyle(
                   fontFamily: 'Gotham',
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ],
           ),
         ),
         ///Request Icon and text
         GestureDetector(
           onTap:()async{
            isLoading==true?
                CircularProgressIndicator():
             postnum!=3?
               showModalBottomSheet(
                   isScrollControlled: true,
                   //barrierDismissible: true,
                   //semanticsDismissible: true,
                   barrierColor: Colors.black.withOpacity(0.2),
                   context: context,
                   builder: (BuildContext context){
                     return DraggableScrollableSheet(
                       initialChildSize: 0.9,
                       minChildSize: 0.5,
                       maxChildSize: 0.9,
                       expand: false,
                       builder:
                           (BuildContext context, ScrollController scrollController) {
                         return RequestForm(isOrgInd:false,);
                       },

                     );
                   }
               ):
             select();
            },
           child: Row(
             children: [
               Text('Request',
                 style: TextStyle(
                   fontFamily: 'Gotham',
                   fontWeight: FontWeight.bold,
                 ),
               ),
               Container(
                 height:55,
                 width: 70,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: Colors.orange,
                 ),
               ),
             ],
           ),
         ),

       ],
     ),


     /* ConvexAppBar(
        height: 50,
        initialActiveIndex: pageIndex,
        onTap: onTap,
        backgroundColor: Colors.orange,
        color: Colors.green,
        activeColor: Colors.green,
        curveSize: 100,
        top: -20,
        items: [
          TabItem(icon:Icon(Icons.feed,
            color: Colors.white,
            semanticLabel: 'Home',
          ),
          ),
          TabItem(icon:Icon(Icons.mail_outline,
            color: Colors.white,
            semanticLabel: 'Messages',
          ),
          ),
          TabItem(icon:Icon(Icons.account_box,
            color: Colors.white,
            semanticLabel: 'Profile',
          ),
          ),

        ],
      ),*/
    );


  }
}


