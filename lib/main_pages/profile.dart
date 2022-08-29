import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sates/startup/wrapper.dart';
import 'package:sates/widgets/header.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:uuid/uuid.dart';
import '../models/userfiles.dart';
import 'package:sates/models/post.dart';
import 'package:sates/authentication/auth.dart';
import 'package:timeago/timeago.dart'as timeago;
import 'package:readmore/readmore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../secondary_pages/edit_profile.dart';



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
  final ratingsRef = FirebaseFirestore.instance.collection('ratings');


  var _textController = new TextEditingController();
  int pageIndex=0;
  final PageController _pageController= PageController();
  final AuthService _auth= AuthService();
  final _formkey= GlobalKey<FormState>();
  bool isLoading=false;
  int postCount=0;
  var reviewID= Uuid().v4();
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  List<UserProfilePosts> pposts=[];

  //Profile page could be for any profile
  // this is the current user
  //Same As (currentUser != null) ? currentUser.id : null

  @override
  void initState() {
    getProfilePosts();
    //getProfileReviews();
    buildProfileHeader();
    getRating();
    //buildProfileRate();
    //checkUserPermission();
    print('Profile Init');
    super.initState();
  }




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

  //If Doc Exist You are Following if null doc.exists is false



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
          buildProfilebody(),
         // fetchProfileReviews(),
          buildProfileReviews(),
        ],
      ),
    );
}

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

///building container for reviews from firestore
buildProfileReviews(){
  if(isLoading) {
    return CircularProgressIndicator();
  }else{
    return  Container(
      color: Colors.grey.shade300,
      child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .doc(widget.profileId)
                .collection('Received')
                .orderBy('Time',descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
              if (snapshot.hasError){
                return Text('Error');
              }

              if(snapshot.hasData && snapshot.data?.size==0){
                return Center(
                  child:Text('No pending approvals'),
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
      return CircularProgressIndicator();
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
                  child: Text(gUser.bio.toString()==""? '...':gUser.bio.toString(),
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.black
                    ),),
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
                  child: Text(gUser.works_at.toString()==""? '...':gUser.works_at.toString(),
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.black
                    ),),
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
                child: FittedBox( child:Text(gUser.street_name.toString()==""? '...':gUser.street_name.toString(),
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.black
                  ),),
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
          return Center(child: CircularProgressIndicator());
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
                    color: Colors.green,
                    height: MediaQuery.of(context).size.height/6,
                    child: CachedNetworkImage(
                      fit: BoxFit.fitWidth,
                      imageUrl:gUser.backprofilePhotoUrl.toString(),
                      placeholder: (context, url) => Icon(Icons.image),
                      errorWidget: (context, url, error) => Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                ///ProfilePhoto
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height/13,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 50,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl:gUser.profilePhotoUrl!,
                            imageBuilder: (context, imageProvider) => Container(
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
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      )
                    )
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
                    child: Text(
                      (gUser.lname.toString()+" "+gUser.fname.toString()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                widget.profileId== currentUserId? GestureDetector(
                  onTap:()=>select(context,gUser.fname.toString(),
                      gUser.profilePhotoUrl.toString(),
                      gUser.backprofilePhotoUrl.toString() ),
                  child: Container(
                      margin: EdgeInsets.only(right: 8.0,top: 8,bottom: 1),
                      child: FittedBox(child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text('Edit Profile',
                        style: TextStyle(
                          color: Colors.green
                        ),
                        textAlign: TextAlign.center,
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
              child: Text(
                gUser.email.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black.withOpacity(0.5)
                ),
              ),
            ),
            Padding(
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
            ),
            Padding(
              padding: const EdgeInsets.only(left:20.0,bottom:14),
              child: Text(gUser.no_rate_ppl.toString()+' people rated',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              ),
            ),

          ],
        );
      },
    );
  }

  ///edit profile options
  select(parentContext, String? Username, String? Profilephoto,String? backProfilePhoto){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Edit Profile'),
            children: [
              SimpleDialogOption(
                child:Text('Change Profile Details'),
                onPressed:()=>Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>
                        EditProfileDetails())),

              ),
              SimpleDialogOption(
                child:Text('Change Profile Image'),
                onPressed:()=>Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>
                    EditProfileImage(Username:Username,imFile:Profilephoto,))),

              ),
              SimpleDialogOption(
                child:Text('Change Background Image'),
                onPressed:()=>Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>
                        EditProfileBackImage(Username:Username,imFile:backProfilePhoto,))),

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


///handling rating
  handleRating()async{
  await getRating();
await ratingsCount1;
 final double result=(old_rate1! - o_rate1! + new_rate!);
 final double result1=((result/ratingsCount1!)).toDouble();
 await result;
 await result1;
  if(old_rate1==0.0){
       rate(
         rate:new_rate!.toString(),
         user_rate:new_rate!.toString(),
         rvalue:(result1*5).toString(),
         /*(
               (
                   ((old_rate1! + new_rate! - o_rate1!)~/ratingsCount!.toDouble()
               )*5).toDouble()
           ).toString()*/
       );
     }else{
       rate(
           rate:new_rate!.toString(),
           user_rate:(result).toString(),
           rvalue:(result1*5).toString(),
             /*  (
                   (
                       (old_rate1! + new_rate! - o_rate1!)~/ratingsCount!.toDouble())*5
               ).toDouble()
           ).toString()*/
           );//((old_rate1! - o_rate1! + new_rate!)~/ratingsCount1!).toString());
         /*  user_rate:(old_rate1! - o_rate1! + new_rate!).toString(),
           rate:new_rate.toString() ,
           rvalue: ((old_rate1!- o_rate1! + new_rate!)~/ratingsCount1!).toString());*/
     }

setState((){
  Navigator.pop(context);
});
   print((((old_rate1! + new_rate! - o_rate1!)~/ratingsCount!).toDouble()).toString()+ 'Yes');
  }



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

    rateDialog();

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
        //centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        title:Text('Profile',
          style: TextStyle(
              color: Colors.orange,
              fontSize: 20
          ),
          textAlign: TextAlign.center,
        ),
        toolbarHeight:60,
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
            reverse: true,
            currentIndex: pageIndex,
            onTap: onTap,
            items: [
              TitledNavigationBarItem(
                icon:Icon(Icons.all_inclusive),
                title:Text('Posts'),
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
                    ]
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
          backgroundColor: Colors.white,
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



