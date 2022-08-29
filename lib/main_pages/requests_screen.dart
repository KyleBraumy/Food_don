import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sates/sidebar.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

import '../models/requests.dart';
import '../models/userfiles.dart';

class Requests_screen extends StatefulWidget {
  const Requests_screen({Key? key}) : super(key: key);

  @override
  State<Requests_screen> createState() => _Requests_screenState();
}



class _Requests_screenState extends State<Requests_screen> {

  final usersRef = FirebaseFirestore.instance.collection('users');
  final requestsTimelineRef = FirebaseFirestore.instance.collection('requestsTimeline');
  final PageController _pageController= PageController();
  final currentUser= FirebaseAuth.instance.currentUser!.uid;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List locs=["Accra","Volta"];
  List<Requests>posts=[];
  List<Requests>fposts=[];
  List<Requests>pposts=[];

  int pageIndex=0;


  @override
  void initState() {
    getUserLoc();
    super.initState();

  }



  getUserLoc()async{
    if (currentUser!=null)
      await usersRef
          .doc(currentUser)
          .get()
          .then((ds){
        var loc=ds.data()!['Location'];
        setState(()=> _dropdownValue=loc);
        // print(currentUserName);
      }).catchError((e){
        print(e);
      });
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


  getRequestsTimeline()async{
    QuerySnapshot snapshot=
    await requestsTimelineRef
        .where('Location',isEqualTo: _dropdownValue)
        .orderBy('Timestamp',descending: true)
        .get();
    List<Requests> posts=snapshot.docs.map((doc)=>Requests.fromDocument(doc))
        .toList();
    setState(()=>  this.posts=posts);


  }
  buildRequestsTimeline(){
    if(posts==null){
      return Text('No posts');
    }
    return ListView(children:posts);
  }


  void dropdownCallback(selectedValue){

      setState((){
        _dropdownValue= selectedValue;
      });
  }

  var _dropdownValue;
  var gloc;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100.withOpacity(0.1),
      // drawer: Drawer(child: Side(),),
      key: scaffoldKey,
      drawer: Drawer(child: Side(),),
      appBar:AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        title: Column(
          children: [
            SizedBox(
              height: 1,
            ),
            FittedBox(
              child: Text('Requests',
                style: TextStyle(
                    color: Colors.green,
                    fontSize:14,
                    fontFamily: 'Gotham',
                    fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 4,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){scaffoldKey.currentState!.openDrawer();},
                  child: Icon(Icons.menu),
                ),
                ///City
                StreamBuilder(
                    stream: usersRef.doc(currentUser).snapshots(),
                    //Resolve Value Available In Our Builder Function
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: Text('null'));
                      }
                      //Deserialize
                      //print(widget.profileId);
                      var DocData = snapshot.data as DocumentSnapshot;
                      GUser gUser = GUser.fromDocument(DocData);
                      return FittedBox(
                        fit: BoxFit.fitHeight,
                        child: DropdownButton(
                          isDense: true,
                          alignment: AlignmentDirectional.centerEnd,
                          dropdownColor: Colors.white,
                          elevation: 1,
                          // itemHeight:48,
                          underline: SizedBox(),
                          value:_dropdownValue==null?gUser.city.toString():_dropdownValue,
                          focusColor: Colors.white,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.orange
                          ),
                          items:[
                            DropdownMenuItem(
                              child:Text('Accra'),value: "Accra",
                            ),
                            DropdownMenuItem(
                              child:Text('Kumasi'),value: "Kumasi",
                            ),
                            DropdownMenuItem(
                              child:Text('Central'),value: "Central",
                            ),

                          ],
                          onChanged:dropdownCallback,
                        ),
                      );
                    }

                ),
                SizedBox(),
              ],
            ),

            Divider(
              color: Colors.green.shade100.withOpacity(0.2),
            ),
            FittedBox(
              child: TitledBottomNavigationBar(
                activeColor: Colors.orange,
                inactiveColor: Colors.green,
                enableShadow: false,
                height: 40,
                reverse: false,
                currentIndex: pageIndex,
                onTap: onTap,
                items: [
                  TitledNavigationBarItem(
                    icon:Icon(Icons.all_inclusive),
                    title:Text('All'),
                  ),
                  TitledNavigationBarItem(
                    icon:Icon(Icons.money_off),
                    title:Text('Free'),
                  ),
                  TitledNavigationBarItem(
                    icon:Icon(Icons.monetization_on_sharp),
                    title:Text('Paid'),
                  ),
                ],
              ),
            ),
          ],
        ),
        toolbarHeight:100,
        backgroundColor: Colors.white,
      ),

      body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children:[
            ///All posts page
            RefreshIndicator(
              onRefresh: () =>getRequestsTimeline(),
              child: FutureBuilder(
                  future:getRequestsTimeline(),
                  builder: (context,snapshot){
                    if (snapshot.hasData)
                      return CircularProgressIndicator();
                    return buildRequestsTimeline();

                  }),
            ),

          ]


      ),
    );
  }
}
