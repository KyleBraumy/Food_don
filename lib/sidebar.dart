import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:sates/secondary_pages/records_screen.dart';

import 'secondary_pages/approvals_screen.dart';
import 'secondary_pages/offers_screen.dart';

class Side extends StatefulWidget {

  @override
  State<Side> createState() => _SideState();
}

class _SideState extends State<Side> {
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;


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
              Divider(thickness: 0.3,color: Colors.blue,),
            ],
          ),
        ),
      ),
    );
  }
}
