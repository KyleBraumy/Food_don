import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sates/models/userfiles.dart';
import 'package:sates/secondary_pages/makePostForm.dart' as M;
import 'package:sates/models/post.dart';
import 'dart:math' as math;
import 'package:sates/sidebar.dart';
import 'package:sates/widgets/header.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import '../authentication/auth.dart';
import '../authentication/createpage.dart';
import '../widgets/constant_widgets.dart';

final timelineRef = FirebaseFirestore.instance.collection('postsTimeline');

var finalloc;




class Timeline extends StatefulWidget {


  final GUser? CurrentUser;
  Timeline({this.CurrentUser});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final currentUser= auth.currentUser!.uid;
  int pageIndex=0;
  final PageController _pageController= PageController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

List<Post>posts=[];
List<Post>fposts=[];
List<Post>pposts=[];


  @override
  void initstate(){
    getUserLoc();
    getTimeline();
    getFreeTimeline();
    getPaidTimeline();

    super.initState();

  }


  getUserLoc()async{
      await usersRef
          .doc(currentUser)
          .get()
          .then((ds){
        var loc=ds.data()!['City'];
        setState(()=> finalloc=loc);
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
getTimeline()async{

  QuerySnapshot snapshot=
    await timelineRef
    .where('City',isEqualTo: _dropdownValue)
    .where('On Timeline', isEqualTo:true)
    .where('Donated', isEqualTo:false)
    .orderBy('Timestamp',descending: true)
    .get();
    List<Post> posts=snapshot.docs.map((doc)=>Post.fromDocument(doc))
    .toList();
      this.posts=posts;

}
buildTimeline(){
    if(posts.length==0){
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nothing to see here....',
              style: TextStyle(
                color: Colors.black.withOpacity(0.5)
              ),
              ),
            ],
          )
      );
    }
    return ListView(children:posts);
}

getFreeTimeline()async{

  QuerySnapshot snapshot=
    await timelineRef
    .where('Price Status',isEqualTo:'free')
    .where('On Timeline', isEqualTo:true)
    .where('Donated', isEqualTo:false)
    .where('City',isEqualTo: _dropdownValue )
    .get();
    List<Post> fposts=snapshot.docs.map((doc)=>Post.fromDocument(doc))
    .toList();
      this.fposts=fposts;

}
buildFreeTimeline(){
    if(fposts.length==0){
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nothing to see here....',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.5)
                ),
              ),
            ],
          )
      );
    }
    return ListView(children:fposts);
}
getPaidTimeline()async{

  QuerySnapshot snapshot=
    await timelineRef
    .where('Price Status', isNotEqualTo:'free')
    .where('On Timeline', isEqualTo:true)
    .where('Donated', isEqualTo:false)
    .where('City',isEqualTo: _dropdownValue )
    .get();
    List<Post> pposts=snapshot.docs.map((doc)=>Post.fromDocument(doc))
    .toList();
      this.pposts=pposts;


}
buildPaidTimeline(){
    if(pposts.length==0){
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nothing to see here....',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.5)
                ),
              ),
            ],
          )
      );
    }
    return ListView(children:pposts);
}

  onTap(int pageIndex){
    _pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 250),
        curve: Curves.bounceInOut
    );
  }


  void dropdownCallback(selectedValue){

    setState((){
      _dropdownValue= selectedValue;
    });
  }

  var _dropdownValue;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100.withOpacity(0.1),
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
              child: Text('FoodShare',
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
          onRefresh: () =>getTimeline(),
          child: FutureBuilder(
            future:getTimeline(),
              builder: (context,snapshot){
                if (snapshot.hasData)
                return CircularProgressIndicator();
                return buildTimeline();

              }),
          ),
          ///Free posts page
          RefreshIndicator(
          onRefresh: () =>getFreeTimeline(),
          child: FutureBuilder(
            future:getFreeTimeline(),
              builder: (context,snapshot){
                if (snapshot.hasData)
                return CircularProgressIndicator();
                return buildFreeTimeline();

              }),
          ),
          ///Paid posts page
          RefreshIndicator(
          onRefresh: () =>getPaidTimeline(),
          child: FutureBuilder(
            future:getPaidTimeline(),
              builder: (context,snapshot){
                if (snapshot.hasData)
                return CircularProgressIndicator();
                return buildPaidTimeline();

              }),
          ),

        ]


      ),
      /*floatingActionButton: ExpandableFab(
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
                      return M.ShareForm(isOrgInd:false,);
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
                      return M.RequestForm(isOrgInd:false,);
                    },

                  );}),
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
      ),*/
      
      
      
     /* FloatingActionButton(
        onPressed: ()=>showModalBottomSheet(

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
                      return M.makePostForm(isOrgInd:false,);
                },

            );}),

        child: Icon(Icons.set_meal_outlined),
        backgroundColor: Colors.green[500],
      ),*/
    );

  }
}




