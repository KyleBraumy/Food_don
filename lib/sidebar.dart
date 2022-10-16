import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:sates/secondary_pages/records_screen.dart';
import 'package:sates/userfeedback.dart';
import 'package:http/http.dart' as http;
import 'secondary_pages/approvals_screen.dart';
import 'secondary_pages/offers_screen.dart';

class Side extends StatefulWidget {

  @override
  State<Side> createState() => _SideState();
}

class _SideState extends State<Side> {
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  var mtoken;
  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token) {
          setState(() {
            mtoken = token;
          });
          saveToken(token!);
          print(token);
        }
    );
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("users").doc(currentUserId).update({
      'Token' : token,
    });
  }



  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
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
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }




  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height/4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit:BoxFit.cover,
                      image: AssetImage('assets/images/foodshare_sideabar_background.jpg')),
                  )
                ),
              Text('FoodShare',style: TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),),
              SizedBox(height:40),
              ///Aprovals
              GestureDetector(
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return  ApprovalsScreen();
                })),
                child: Container(
                  margin: EdgeInsets.only(top:5),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.approval_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Approvals',
                        style: TextStyle(
                          fontFamily: 'Gotham',
                          fontWeight:FontWeight.bold,
                            letterSpacing: 1
                        ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
              ///Offers
              GestureDetector(
                onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return  OffersScreen(
                  );
                })),
                child: Container(
                  margin: EdgeInsets.only(top:15),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.local_offer_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Offers',
                          style: TextStyle(
                              fontFamily: 'Gotham',
                              fontWeight:FontWeight.bold,
                              letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
              ///Records
              GestureDetector(
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return  Records(
                  ); })),
                child: Container(
                  margin: EdgeInsets.only(top:15),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.receipt_long_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Records',
                          style: TextStyle(
                              fontFamily: 'Gotham',
                              fontWeight:FontWeight.bold,
                            letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
              ///Feebacks
              GestureDetector(
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return  UserFeedbacks(
                  );
                })),
                child: Container(
                  margin: EdgeInsets.only(top:15),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.receipt_long_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Feedback',
                          style: TextStyle(
                              fontFamily: 'Gotham',
                              fontWeight:FontWeight.bold,
                            letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
/*
              ///Feebacks
              GestureDetector(
                onTap: (){
                  sendPushMessage(mtoken,'Yeah',"Kyle Braumy");
                },
                child: Container(
                  margin: EdgeInsets.only(top:15),
                  height:70,
                  color: Colors.green.shade100.withOpacity(0.3),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:17.0),
                        child: Icon(Icons.receipt_long_outlined,
                          color: Colors.orange,size: 30,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0),
                        child: Text('Send Test',
                          style: TextStyle(
                              fontFamily: 'Gotham',
                              fontWeight:FontWeight.bold,
                              letterSpacing: 1
                          ),
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),*/

              Divider(thickness: 0.3,color: Colors.blue,),
            ],
          ),
        ),
      ),
    );
  }
}
