
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:sates/startup/wrapper.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:uuid/uuid.dart';
import '../models/requests.dart';
import '../models/userfiles.dart';
import 'package:sates/models/post.dart';
import 'package:sates/authentication/auth.dart';
import 'package:timeago/timeago.dart'as timeago;
import 'package:readmore/readmore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../secondary_pages/edit_profile.dart';
import '../widgets/constant_widgets.dart';



class Profile extends StatefulWidget {
  final String? profileId;


  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final usersRef = FirebaseFirestore.instance.collection('users');
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final recordsRef = FirebaseFirestore.instance.collection('records');
  final reviewsRef = FirebaseFirestore.instance.collection('reviews');
  final reportsRef = FirebaseFirestore.instance.collection('reports');
  final requestsRef = FirebaseFirestore.instance.collection('requests');
  final requestsTimelineRef = FirebaseFirestore.instance.collection('requestsTimeline');
  final ratingsRef = FirebaseFirestore.instance.collection('ratings');


  var _textController = new TextEditingController();
  int pageIndex=0;
  final PageController _pageController= PageController();
  final AuthService _auth= AuthService();
  final _formkey= GlobalKey<FormState>();
  bool isLoading=false;
  int postCount=0;
  var reviewID= Uuid().v4();
  String reportId= Uuid().v4();
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  List<UserProfilePosts> pposts=[];
  List<Requests>requests=[];

  //Profile page could be for any profile
  // this is the current user
  //Same As (currentUser != null) ? currentUser.id : null

  @override
  void initState() {
    getProfilePosts();
    getProfileRequests();
    //getProfileReviews();
    buildProfileHeader();
    //getRating();
    //buildProfileRate();
    //checkUserPermission();
    print('Profile Init');
    super.initState();
  }


/*


  getRating()async{
      await ratingsRef
          .doc(widget.profileId)
          .collection('ratedBy')
          .doc(currentUserId)
          .get()
          .then((ds){
        o_rate=ds.data()!['Rating'];
        o_rate1=double.parse(o_rate!);
       print(o_rate1);
      }).catchError((e){
        print(e);
      });

      await buildProfileHeader();
     QuerySnapshot snapshot = await ratingsRef
          .doc(widget.profileId)
          .collection('ratedBy')
          .get();

      setState(() {
        ratingsCount = snapshot.docs.length;
        ratingsCount1 = snapshot.docs.length * 5;
        print('Number of people who rated is ' + ratingsCount!.toString());
      });

  }
*/


  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userposts')
        .orderBy('Timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      print(postCount);
      //Iterate over snapshot.documents with map
      //For each Doc deserialize post document
      // snapshot with Post.fromDocument pass in doc to it
      // In the end call to list to make it a list

      pposts = snapshot.docs.map((doc) => UserProfilePosts.fromDocument(doc)).toList();
      //Documents is a list of all the stuff in snapshot
      //map goes over each document and returns 1 doc each
      //each doc passed into factory and all are turned into a list
    });
  }


  getProfileRequests() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await requestsRef
        .doc(widget.profileId)
        .collection('userRequests')
        .orderBy('Timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      //Iterate over snapshot.documents with map
      //For each Doc deserialize post document
      // snapshot with Post.fromDocument pass in doc to it
      // In the end call to list to make it a list

      requests = snapshot.docs.map((doc) => Requests.fromDocument(doc)).toList();
      //Documents is a list of all the stuff in snapshot
      //map goes over each document and returns 1 doc each
      //each doc passed into factory and all are turned into a list
    });
  }



///Logout
  logout(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Are you sure you want to log out'),
            children: [
              Row(
                children: [
                  SimpleDialogOption(
                    child:Text('Yes'),
                      onPressed:()
                      async{
                     await _auth.signOut();
                     Navigator.pushReplacement(context,
                         MaterialPageRoute(builder: (context)=> Wrapper()));

                      }

                  ),
                  SimpleDialogOption(
                    child:Text('No'),
                    onPressed: ()=>Navigator.pop(context),
                  ),
                ],
              ),

            ],
          );
        }
    );
  }


  buildCountColumn({String? label, int? count}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label.toString(),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

///check if current user has received from the target profile owner before
/*
  checkUserPermission()async{
   await StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('records')
            .doc(currentUserId)
            .collection('receivedSuccessfully')
            .where('Pending',isEqualTo: false)
            .where('Status',isEqualTo: "true")
            .where('From',isEqualTo:widget.profileId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return SizedBox();
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return SizedBox();
          }
          if(snapshot.hasData && snapshot.data?.size==0){
            return SizedBox();
          }
          return ListView(
            children:snapshot.data!.docs
                .map((DocumentSnapshot document){
              Map<String, dynamic> data=
              document.data()! as Map<String,dynamic>;
              Pending= data['Pending'].toString();
              return
                  SizedBox();



            })
                .toList()

                .cast(),

          );
        }
    );
  }

*/


  ///adding review details to firestore
sendReview({String? content,String? from, String? to, required DateTime Timestamp, String? review_id}){
  reviewsRef
  .doc(currentUserId)
  .collection('Sent')
  .doc(review_id)
  .set({
    'From':from,
    'To':to,
    'Content':content,
    'Time':Timestamp,
    'Review_ID':review_id,
  });


  reviewsRef
  .doc(widget.profileId)
  .collection('Received')
  .doc(review_id)
  .set({
    'From':from,
    'To':to,
    'Content':content,
    'Time':Timestamp,
    'Review_ID':review_id,
  });
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

///posts, about, reviews section
  section(){
    return Container(
      height:MediaQuery.of(context).size.height/1.8,
      child: PageView(
        controller:  _pageController,
        onPageChanged: onPageChanged,
        //physics: Neve rScrollableScrollPhysics(),
        children: [
          buildProfilePosts(),
          buildProfileRequests(),
          buildProfilebody(),
         // fetchProfileReviews(),
          buildProfileReviews(),

        ],
      ),
    );
}

/*
///rate
  rate({required String user_rate, required String rate,required String rvalue,}){
    ratingsRef
      .doc(widget.profileId)
      .collection('ratedBy')
      .doc(currentUserId)
      .set({
    'Rating':rate,
    'Rated_By':currentUserId,
    });


    usersRef
        .doc(widget.profileId)
        .update({
      'Rating':user_rate,
      'Rating_value':rvalue,
      'No_ppl_rated':ratingsCount,
    });



  }
*/

///building container for reviews from firestore
buildProfileReviews(){
  if(isLoading) {
    return CircularProgressIndicator();
  }else{
    return  Container(
      color: Colors.green.shade50,
      child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .doc(widget.profileId)
                .collection('Received')
                .orderBy('Time',descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
              if (snapshot.hasError){
                return Center(child: Text('Error loading reviews..'));
              }
              if(snapshot.connectionState==ConnectionState.waiting){
                return Center(
                  child:Text('Loading...'),
                );
              }
              if(snapshot.hasData && snapshot.data?.size==0){
                return Center(
                  child:Text('No reviews yet...'),
                );
              }
              return ListView(
                children:snapshot.data!.docs
                    .map((DocumentSnapshot document){
                  Map<String, dynamic> data=
                  document.data()! as Map<String,dynamic>;
                  rfrom=data['From'].toString();
                  return FittedBox(
                    child: Container(
                      margin: EdgeInsets.all(8),
                      color: Colors.white,
                      width:MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              buildReviewHeader(),
                              Expanded(child: SizedBox()),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right:8.0),
                                    child: GestureDetector(
                                        onTap: ()async{
                                          newReviewId= await data['Review_ID'].toString();
                                          confirmDelete();

                                        },
                                        child: Icon(Icons.delete)
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 7),
                                    child: Text(
                                      timeago.format(data['Time'].toDate()),
                                      overflow:TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.grey
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.all(22.0),
                            child:ReadMoreText(
                              data['Content'].toString(),

                              trimLines: 3,
                              colorClickableText: Colors.pink,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: '  Show more',
                              trimExpandedText: '   Show less',
                              moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                              color: Colors.green
                              ),
                              lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                                  color: Colors.green
                              ),
                            ),
                          )
                        ],
                      ),
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
  ///method to build username ,time an photo of review container
  buildReviewHeader(){
    return FutureBuilder(
      future: usersRef.doc(rfrom).get(),
      //Resolve Value Available In Our Builder Function
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        //Deserialize
        //print(widget.profileId);
        var DocData = snapshot.data as DocumentSnapshot;
        GUser gUser = GUser.fromDocument(DocData);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // buildCountColumn(label: 'posts', count: postCount),
            ///Username
            Padding(
              padding: const EdgeInsets.only(left: 11,top:11),
              child: CircleAvatar(
                radius: 20,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl:gUser.profilePhotoUrl!,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        //borderRadius: BorderRadius.circular(50),
                        shape: BoxShape.circle,
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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:8.0,top:11),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (gUser.lname.toString()+" "+gUser.fname.toString()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(left:2),
                      height:5,
                      width: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:3,top:1),
                      child:Text(gUser.identify_as.toString(),
                      style: TextStyle(
                        fontSize:12,
                        color: Colors.grey,
                      ),),
                    ),
                  ],
                ),
              ],
            ),

          ],
        );
      },
    );
  }


///Deleting reviews
 DeleteReview({String? newRID})async{
  reviewsRef
  .doc(widget.profileId)
  .collection('Received')
  .doc(newReviewId)
  .delete();

  reviewsRef
      .doc(currentUserId)
      .collection('Sent')
      .doc(newReviewId)
      .delete();
  }


  handleDeleteReview()async{
  print(newReviewId);
   DeleteReview(
    newRID:newReviewId
  );
  }



///profile posts
  buildProfilePosts() {
    if(isLoading){
      return Center(
        child:Text('Loading...')
      );
    }else{
      return GridView(
        padding: EdgeInsets.all(5),
        physics: ScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5,
          childAspectRatio: 2,
        ),
        children:pposts,
      );
    }

    }
    ///profile requests
  buildProfileRequests() {
  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('requestsTimeline')
          .where('OwnerID',isEqualTo:widget.profileId)
          .orderBy('Timestamp',descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
        if (snapshot.hasError){
          return Text('Error');
        }
        if(snapshot.hasData && snapshot.data?.size==0){
          return Center(
            child:Text('No posts'),
          );
        }
        return ListView(
          children:snapshot.data!.docs
              .map((DocumentSnapshot document){
            Map<String, dynamic> data=
            document.data()! as Map<String,dynamic>;
            r_id=data['RequestId'].toString();
            final DateTime ttimestamp=DateTime.now();
            ///Template for requests made by users
            return ttimestamp.compareTo(data['Expire_at']!.toDate())>0?SizedBox():
           Container(
              height: 130,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color:  Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0,5),
                      spreadRadius: 2,
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius:7,
                    ),
                  ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0,top: 5),
                        child: CustomText7('Requested for'+" "+data['Requested'].toString()),
                      ),
                      Expanded(child: SizedBox()),
                      widget.profileId!=currentUserId?
                      Padding(
                        padding: const EdgeInsets.only(right:8.0,top:5),
                        child:GestureDetector(
                          onTap:()=>showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.6,
                                    minChildSize: 0.4,
                                    maxChildSize: 0.9,
                                    builder: (BuildContext context, ScrollController scrollcontroller){
                                      return ExpandablePanel(
                                          header: ListTile(
                                            title:Text('Report Post'),
                                          ),
                                          collapsed:Text(''),
                                          expanded:Container(
                                            child:Column(
                                              children: [
                                                ListTile(
                                                    title:Text('Inappropriate content'),
                                                    onTap: () async{
                                                      rport='Inappropriate content';
                                                      handleReport();
                                                    }
                                                ),
                                              ],
                                            ),
                                          )
                                      );
                                    }
                                );
                              }
                          ),
                          child: Icon(Icons.info),
                        ),
                      ):
                      Padding(
                        padding: const EdgeInsets.only(right:8.0,top:5),
                        child:GestureDetector(
                          onTap:()=>showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context){
                                return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.6,
                                    minChildSize: 0.4,
                                    maxChildSize: 0.9,
                                    builder: (BuildContext context, ScrollController scrollcontroller){
                                      return handleDeletingRequest(data['RequestId'].toString());
                                    }
                                );
                              }
                          ),
                          child: Icon(Icons.delete),
                        ),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      ///UserProfilePhoto
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 85,
                          width:85,
                          child:
                          ///StreamBuilder to get profile image upon update
                          StreamBuilder(
                              stream: usersRef.doc(widget.profileId).snapshots(),
                              //Resolve Value Available In Our Builder Function
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                //Deserialize
                                //print(widget.profileId);
                                var DocData = snapshot.data as DocumentSnapshot;
                                GUser gUser = GUser.fromDocument(DocData);
                                return Center(
                                  child: CachedNetworkImage(
                                    imageUrl:gUser.profilePhotoUrl.toString(),
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        //shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                );
                              }

                          ),
                        ),
                      ),
                      ///Username,Position,Time
                      ///Username & position
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomText3(data['Username'].toString(),),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.all(8),
                                  height:5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                ),
                                CustomText5(data['Requested as'].toString(),FontStyle.italic
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          FittedBox(
                            child: CustomText6(data['Timestamp']),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ///Price
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: data['Price Status']==null? Colors.green:Colors.orange,
                            ),

                            ///Price
                            child: FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(data['Price Status']==null?'Free':data['Currency'].toString()+" "+data['Price Status'].toString(),
                                  style: TextStyle(
                                    fontSize:15,
                                    color:Colors.white,
                                  ),
                                  softWrap: true,),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ///Time post was made

                    ],
                  ),

                ],
              ),
            );

          })
              .toList()

              .cast(),

        );
      }
  );

/*    if(isLoading){
      return Center(
        child:Text('Loading...')
      );
    }else{
      return Container(
        color:Colors.green.shade50,
        child: ListView(
          children:requests,
        ),
      );
    }*/

    }

    handleDeletingRequest(String r_id){
     return Column(
    children: [
      ListTile(
        onTap: ()=>timelineDelete(r_id),
        title: Text('Remove request from timeline'),
      ),
      ListTile(
        onTap: ()=>deleteEntirely(r_id),
        title: Text('Delete request permanently'),
      ),
    ],
  );

    }

  timelineDelete(String r_id)async{
    ///change timeline status
    await requestsRef
        .doc(widget.profileId)
        .collection('userRequests')
        .doc(r_id)
        .update({
      'On Timeline':false
    });
    ///delete from timeline
    await requestsTimelineRef
        .doc(r_id)
        .delete();

  }

  var r_id;

  deleteEntirely(String r_id)async{
    ///delete entirely
    await requestsRef
        .doc(widget.profileId)
        .collection('userRequests')
        .doc(r_id)
        .delete();
    await requestsTimelineRef
        .doc(r_id)
        .delete();
  }

  handleReport()async{
    await rport;
    final DateTime timestamp= DateTime.now();
    await reportsRef.doc(reportId).set({
      'OwnerID':currentUserId,
      'Report_Id':reportId,
      'Timestamp':timestamp,
      'Handled':false,
      'Content':rport,
      'PostOwnerID':widget.profileId,
      'Expire_at':timestamp.add(Duration(days:30))
    });
    setState((){
      String reportId= Uuid().v4();
    });
    Navigator.pop(context);
  }



  ///profile about
  buildProfilebody() {
    if (isLoading) {
      return CircularProgressIndicator();
    }else{
      return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        //Deserialize
        //print(widget.profileId);
        var DocData = snapshot.data as DocumentSnapshot;
        GUser gUser = GUser.fromDocument(DocData);
        return Column(
           // mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///bio
              Padding(
                padding: const EdgeInsets.only(left:16.0),
                child: Text('bio',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.withOpacity(0.5)
                  ),),
              ),
             ///bio from firestore
              Padding(
                padding: const EdgeInsets.only(left: 16.0,top:1,bottom: 16),
                child: FittedBox(
                  child: CustomText7(gUser.bio.toString()==""? '...':gUser.bio.toString(),
                    ),
                ),
              ),
              ///works at
              Padding(
                padding: const EdgeInsets.only(left:16.0),
                child: Text('Works at',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.withOpacity(0.5)
                  ),),
              ),
              ///works at from firestore
              Padding(
                padding: const EdgeInsets.only(left: 16.0,bottom: 16),
                child: FittedBox(
                  child: CustomText7(gUser.works_at.toString()==""? '...':gUser.works_at.toString(),
                   ),
                ),
              ),
              ///stays in
              Padding(
                padding: const EdgeInsets.only(left:16.0),
                child: Text('Stays in',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.withOpacity(0.5)
                  ),),
              ),
              ///stays in from firestore
              Padding(
                padding: const EdgeInsets.only(left: 16.0,top:2,bottom: 16),
                child: FittedBox( child:CustomText7(gUser.street_name.toString()==""? '...':gUser.street_name.toString(),
                  ),
              ),
              )
            ]
        );
      }
      );



    }
    }

    ///header for the profile
  buildProfileHeader() {
    //Resolve Future Needed To Get User Info Based
    // On Their ID
    //Resolves It Once Needs To Be Refreshed To See New data
    //Should Be A Stream Builder Here
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      //Resolve Value Available In Our Builder Function
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
              height: MediaQuery.of(context).size.height/3,
              width: MediaQuery.of(context).size.width,
              color: Colors.green.shade50);
        }

        //Deserialize
       //print(widget.profileId);
        var DocData = snapshot.data as DocumentSnapshot;
        GUser gUser = GUser.fromDocument(DocData);
        old_rate=(gUser.rate!);
        old_rate1=double.parse(old_rate!);
        rate_value1=double.parse(gUser.ratevalue!);
        print(old_rate1! + 1);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                ///BackProfilePhoto
                GestureDetector(
                  onTap: (){},
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.green.shade50,
                    height: 300,
                    child: CachedNetworkImage(
                      fit: BoxFit.fitWidth,
                      imageUrl:gUser.backprofilePhotoUrl.toString(),
                      placeholder: (context, url) => Icon(Icons.person_outline_rounded,size: 40,),
                      errorWidget: (context, url, error) => Center(child: Text('Upload a cover photo'),),
                    ),
                  ),
                ),
                ///ProfilePhoto
                Column(
                 /* mainAxisAlignment:MainAxisAlignment.spaceBetween,
                 crossAxisAlignment: CrossAxisAlignment.start,*/
                  children: [
                    SizedBox(height:240,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(
                        imageUrl:gUser.profilePhotoUrl!,
                        imageBuilder: (context, imageProvider) => Container(
                         height: 100,
                          width:100,
                          decoration: BoxDecoration(
                            //borderRadius: BorderRadius.circular(50),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.orange,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Icon(Icons.person),
                        errorWidget: (context, url, error) => Icon(Icons.person_off),
                      )
                    ),
                    
                  ],
                )
              ],
            ),

            ///Username and edit profile button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // buildCountColumn(label: 'posts', count: postCount),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0,top: 8,bottom: 1),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: CustomText2(
                      (gUser.lname.toString()+" "+gUser.fname.toString()),

                    ),
                  ),
                ),
                widget.profileId== currentUserId? GestureDetector(
                  onTap:()=>select(context,gUser.lname.toString()+" "+gUser.fname.toString(),
                      gUser.profilePhotoUrl.toString(),
                      gUser.backprofilePhotoUrl.toString() ),
                  child: Container(
                      margin: EdgeInsets.only(right: 8.0,top: 8,bottom: 1),
                      child: FittedBox(child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: CustomText7('Edit Profile',
                        ),
                      ),
                      ),
                    decoration: BoxDecoration(
                      border:Border.all(
                        color: Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ): SizedBox()
              ],
            ),
            ///Display Email
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0,bottom: 2),
              child: CustomText5(
                gUser.email.toString(),
                null
              ),
            ),
           /* Padding(
              padding: const EdgeInsets.only(left:20.0,top: 7,bottom:2),
              child: GestureDetector(
                onTap:()=>rateDialog(),
                child: Row(
                  children: [
                    RatingBar.builder(
                      itemSize: 18,
                      initialRating:rate_value1!,
                      minRating: 1,
                      maxRating: 5,
                      itemCount: 5,
                      allowHalfRating: true,
                      itemBuilder: (context, index)=>Icon(Icons.star,color: Colors.amber,),
                      ignoreGestures: true,
                      onRatingUpdate: (rating) {
                       // setState(()=>new_rate=rating);
                        //print(new_rate1);
                      },
                    ),
                    Text((gUser.ratevalue!.toString()))
                  ],
                ),
              ),
            ),*/
           /* Padding(
              padding: const EdgeInsets.only(left:20.0,bottom:14),
              child: CustomText5(gUser.no_rate_ppl.toString()+' people rated',
              FontStyle.italic,
              ),
            ),*/

          ],
        );
      },
    );
  }

  ///edit profile options
  select(parentContext, String? Username,
      String? Profilephoto,String? backProfilePhoto){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Edit Profile'),
            children: [
              SimpleDialogOption(
                child:Text('Change Profile Details'),
                onPressed:()=>
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
                              return  EditProfileDetails();
                            },

                          );
                        }
                    ),

              ),
              SimpleDialogOption(
                child:Text('Change Profile Photo'),
                onPressed:()=>
                    showModalBottomSheet(
                        isScrollControlled: true,
                        //barrierDismissible: true,
                        //semanticsDismissible: true,
                        barrierColor: Colors.black.withOpacity(0.2),
                        context: context,
                        builder: (BuildContext context){
                          return DraggableScrollableSheet(
                            initialChildSize: 0.55,
                            minChildSize: 0.55,
                            maxChildSize: 0.55,
                            expand: false,
                            builder:
                                (BuildContext context, ScrollController scrollController) {
                              return EditProfileImage(Username:Username,imFile:Profilephoto,);
                            },

                          );
                        }
                    ),

              ),
              SimpleDialogOption(
                child:Text('Change Cover Photo'),
                onPressed:()=>
                    showModalBottomSheet(
                        isScrollControlled: true,
                        //barrierDismissible: true,
                        //semanticsDismissible: true,
                        barrierColor: Colors.black.withOpacity(0.2),
                        context: context,
                        builder: (BuildContext context){
                          return DraggableScrollableSheet(
                            initialChildSize: 0.7,
                            minChildSize: 0.6,
                            maxChildSize: 0.7,
                            expand: false,
                            builder:
                                (BuildContext context, ScrollController scrollController) {
                              return EditProfileBackImage(Username:Username,imFile:backProfilePhoto,);
                            },

                          );
                        }
                    ),

              ),
              SimpleDialogOption(
                child:Text('Cancel'),
                onPressed: ()=>Navigator.pop(context),
              ),
            ],
          );
        }
    );
  }

/*
  rateDialog(){
    showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            title: Text('Rate this User'),
            children: [
              SimpleDialogOption(
                child:RatingBar.builder(
                  initialRating:0,
                  itemCount: 5,
                  itemBuilder: (context, index)=>Icon(Icons.star,color: Colors.amber,),
                  onRatingUpdate: (rating) {
                    setState(()=>new_rate=rating);
                    //print(new_rate1);
                  },
                ),
              ),
              Row(
                children: [
                  SimpleDialogOption(
                      child:Text('Done'),
                      onPressed: ()async{
                        await handleRating();
                      }
                  ),
                  SimpleDialogOption(
                    child:Text('Cancel'),
                    onPressed: ()=>Navigator.pop(context),
                  ),
                ],
              ),

            ],
          );
        }
    );
  }
*/


/*
///handling rating
  handleRating()async{
  await getRating();
  if(o_rate==null)
    {
      setState(()=>o_rate="0");
    }
await ratingsCount1;
  old_rate1==null?'0':old_rate1;
  o_rate==null?"0":o_rate;
 final double result=(old_rate1! - o_rate1! + new_rate!);
 final double result1=((result/ratingsCount1!)).toDouble();
 await result;
 await result1;
  if(old_rate1==0.0){
       rate(
         rate:new_rate!.toString(),
         user_rate:new_rate!.toString(),
         rvalue:(result1*5).toString(),
         */
/*(
               (
                   ((old_rate1! + new_rate! - o_rate1!)~/ratingsCount!.toDouble()
               )*5).toDouble()
           ).toString()*//*

       );
     }else{
       rate(
           rate:new_rate!.toString(),
           user_rate:(result).toString(),
           rvalue:(result1*5).toString(),
             */
/*  (
                   (
                       (old_rate1! + new_rate! - o_rate1!)~/ratingsCount!.toDouble())*5
               ).toDouble()
           ).toString()*//*

           );//((old_rate1! - o_rate1! + new_rate!)~/ratingsCount1!).toString());
         */
/*  user_rate:(old_rate1! - o_rate1! + new_rate!).toString(),
           rate:new_rate.toString() ,
           rvalue: ((old_rate1!- o_rate1! + new_rate!)~/ratingsCount1!).toString());*//*

     }

setState((){
  Navigator.pop(context);
});
   print((((old_rate1! + new_rate! - o_rate1!)~/ratingsCount!).toDouble()).toString()+ 'Yes');
  }
*/



///handling the review process
  handleReviewing()async{
    final DateTime timestamp= DateTime.now();
    await msg;
    sendReview(
        content:msg,
        from:currentUserId,
        to:widget.profileId,
        review_id:reviewID,
       Timestamp:timestamp,
    );

    setState((){
      _textController.clear();
      reviewID= Uuid().v4();
      isOpen=!isOpen;
    });
  }

  confirmDelete()async{
    return showDialog(
        context: context,
        builder: (content){
          return SimpleDialog(
            title: Text('Do you want to delete this review'),
            children: [
              SimpleDialogOption(
                child: Text('Yes'),
                onPressed:()async{
                  await handleDeleteReview();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );

  }

  var msg;
var rport;
 bool isOpen=false;
var rfrom;
var rtime;
///taking string from firestore
String? old_rate;
String? o_rate;
String? oldCUserRate;
int? ratingsCount;
///parsing them into double values
double? oldCUserRate1;
double? old_rate1;
double? new_rate;
double? o_rate1;
int? ratingsCount1;
double? rate_value1;

var newReviewId;

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        elevation: 0,
        //centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        title:CustomText8('Profile',

        ),
        toolbarHeight:100,
        backgroundColor: Colors.white,
        actions: [
            GestureDetector(
              onTap: ()=>
                logout(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.logout_rounded,semanticLabel:'Logout',),
              ),
            ),
            GestureDetector(
              onTap: ()async{
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.settings),
              ),
            ),
        ],
      ),
      body:ListView(
        children: <Widget>[
          buildProfileHeader(),
          TitledBottomNavigationBar(
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
                title:Text('Posts'),
              ),
              TitledNavigationBarItem(
                icon:Icon(Icons.all_inclusive),
                title:Text('Requests'),
              ),
              TitledNavigationBarItem(
                icon:Icon(Icons.free_breakfast),
                title:Text('About'),
              ),
              TitledNavigationBarItem(
                icon:Icon(Icons.free_breakfast),
                title:Text('Reviews'),
              ),
            ],
          ),
          Divider(
          ),
          Expanded(child:section()),


        ],
      ),

      ///Code to enable user write a review
      floatingActionButton:Row(
        mainAxisAlignment:MainAxisAlignment.end,
        children: [
          widget.profileId==currentUserId?
          SizedBox():
          isOpen==true?
          Expanded(
            child: Form(
              key: _formkey,
              child: Container(
                margin: EdgeInsets.only(left: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0,3),
                        spreadRadius: 2,
                        color: Colors.green.withOpacity(0.3),
                        blurRadius:3,
                      ),
                    ],
                  border: Border.all(
                    width: 0.5,
                    color: Colors.orange
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left:10,top: 4,bottom: 4),
                        color: Colors.transparent,
                        child: TextFormField(
                          controller: _textController,
                          validator: (val)=>val!.isEmpty?'Type something':null,
                          onChanged: (val){
                            setState(() => msg=val);
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none
                          ),

                        ),
                      ),
                    ),

                    ///if there is input show send icon, if not show cancel icon

                    _textController.text.length>1?
                   IconButton(
                      icon: Icon(Icons.send_sharp,color: Colors.green,),
                      onPressed: ()async {
                        if (_formkey.currentState!.validate()){
                          handleReviewing();
                        }else{

                        }
                      },
                    ):
                    IconButton(
                      icon: Icon(Icons.cancel_outlined,color: Colors.green,),
                      onPressed: (){
                        setState(()=>
                            isOpen=!isOpen
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ):
          FloatingActionButton(
          elevation: 5.5,
          backgroundColor:Colors.green.shade50,
            child: Icon(Icons.edit_outlined,
            color: Colors.orange,
            ),
            onPressed: () {
              setState(()=>
              isOpen=!isOpen
              );

            },

          ),

        ],
      ),





    );

  }
}



