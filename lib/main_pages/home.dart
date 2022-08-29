import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sates/main_pages/timeline.dart';
import 'package:sates/main_pages/profile.dart';

import 'package:uuid/uuid.dart';

import 'requests_screen.dart';
import '../sidebar.dart';
import 'chats_screen.dart';
import '../secondary_pages/edit_profile.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');


class home extends StatefulWidget {


  @override
  State<home> createState() => _homeState(

  );
}

class _homeState extends State<home> {
  final currentUser= auth.currentUser!;
  String postId=Uuid().v4();
  final PageController _pageController= PageController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool? NoUrl;
    int pageIndex=0;
    @override
    void initstate(){
      //checkUser();
     // getPhotoUrl();
     //getUsername();
   /*  getProfilePosts();
     getUsername();*/
     super.initState();
    }





  String? Url;
  String? Username;
  Future<String> url() async {
    DocumentSnapshot docS = await usersRef.doc(auth.currentUser!.uid).get();
    String urL = (docS.data() as Map)["ProfilePhotoUrl"];
    return urL;
  }

  Future<String> username() async {
    DocumentSnapshot docS = await usersRef.doc(auth.currentUser!.uid).get();
    String userName = (docS.data() as Map)["Username"];
    return userName;
  }


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
        index: pageIndex,
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

