import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sates/main_pages/profile.dart'as P;

import 'package:sates/models/userfiles.dart';

import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../secondary_pages/viewpost.dart';
import '../secondary_pages/postScreen.dart';





/// #3 All The Variables That Are Stored And Have State
class Post extends StatefulWidget {
  final String? postId;
  final String? username;
  final String? pstatus;
  final String? ownerId;
 var timestamp;
  final String? mediaUrl;
  final String? city;
  final bool? on_timeline;
  final bool? donated;
  final String? description;
  final String? ingredients;
  final String? shared;
  final String? shared_as;


  /// #2 All Post Stuff From Snapshot
  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.on_timeline,
    this.pstatus,
    this.donated,
    this.timestamp,
    this.city,
    this.ingredients,
    this.shared,
    this.shared_as,
    this.mediaUrl,
    this.description,

  });

  /// #1 Document Snapshot Is Made Into Post
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['PostId'],
      ownerId: doc['OwnerID'],
      username: doc['Username'],
      city: doc['City'],
      on_timeline: doc['On Timeline'],
      pstatus: doc['Price Status'],
      ingredients: doc['Ingredients_Content'],
      shared_as: doc['Shared as'],
      shared: doc['Shared'],
      donated: doc['Donated'],
      description: doc['Description'],
      timestamp: doc['Timestamp'],
      mediaUrl: doc['MediaUrl'],
    );
  }

  @override
///
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    timestamp: this.timestamp,
   city:this.city,
    on_timeline:this.on_timeline,
    pstatus:this.pstatus,
    donated:this.donated,
    shared:this.shared,
    shared_as:this.shared_as,
    ingredients:this.ingredients,
    mediaUrl:this.mediaUrl,
  description:this.description,
      );
}

class _PostState extends State<Post> {
  String uniqueId=const Uuid().v4();
  final requestsTimelineRef = FirebaseFirestore.instance.collection('requestsTimeline');
  final requestsRef = FirebaseFirestore.instance.collection('requests');
  final recordsRef = FirebaseFirestore.instance.collection('records');
  final usersRef = FirebaseFirestore.instance.collection('users');
  final timelineRef = FirebaseFirestore.instance.collection('postsTimeline');
  final postsRef = FirebaseFirestore.instance.collection('posts');



  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final String? postId;
  final String? ownerId;
  final String? username;
  var timestamp;
  final String? city;
  final String? pstatus;
  final bool? on_timeline;
  final bool? donated;
  final String? shared;
  final String? shared_as;
  final String? ingredients;
  final String? mediaUrl;
final String? description;
var newU;

//  final currentUser= auth.currentUser;

  _PostState(
      {this.postId,
        this.ownerId,
        this.username,
        this.timestamp,
        this.city,
        this.pstatus,
        this.donated,
        this.on_timeline,
        this.shared,
        this.shared_as,
       this.ingredients,
        this.mediaUrl,
     this.description,
      }
      );

@override
  void initState() {

    super.initState();
  }
  getImage()async{
    final Stream<QuerySnapshot?>usersStream=FirebaseFirestore.instance
        .collection('users')
        .where('Id',isEqualTo:widget.ownerId)
        .snapshots();
    StreamBuilder<QuerySnapshot?>(
        stream: usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return const Text('something went wrong');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Text('Loading');
          }
          snapshot.data!.docs
              .map((DocumentSnapshot document){
            Map<String, dynamic> data=
            document.data()! as Map<String,dynamic>;

            String newUrl=(data['ProfilePhotoUrl']).toString();

            return data;

          });
          return Text('');


        }
    );

  }

  getUserURl()async{
    if (widget.ownerId!=null)
      await usersRef
          .doc(widget.ownerId)
          .get()
          .then((ds){
        newU=ds.data()!['ProfilePhotoUrl'];
        // print(currentUserName);
      }).catchError((e){
        print(e);
      });
  }



  ///Create request sent in user documents
  addToUserSent({String? Share,required DateTime timestamp}){
    requestsRef
        .doc(currentUserId)
        .collection('acceptanceRequestsSent')
        .doc(uniqueId)
        .set({
      'Description':Share,
      'To':ownerId,
      'Status':null,
      'PostId':postId,
      'UniqueId':uniqueId,
      'Timestamp':timestamp,
      'Pending':null,
    });

  }

  ///Create request received in postOwner documents
  addToDestinationReceive({String? Share,required DateTime timestamp}){
    requestsRef
        .doc(ownerId)
        .collection('acceptanceRequestsReceived')
        .doc(uniqueId)
        .set({
      'Description':Share,
      'From':currentUserId,
      'Status':null,
      'PostId':postId,
      'UniqueId':uniqueId,
      'Timestamp':timestamp,
      'Pending':null,
    });


  }

  ///Add to postOwner shared records before approval happens
  addToSharerSharedSuccessfully({String? Share,required DateTime timestamp}){
    recordsRef
        .doc(ownerId)
        .collection('sharedSuccessfully')
        .doc(uniqueId)
        .set({
      'Description':Share,
      'To':currentUserId,
      'Status':null,
      'PostId':postId,
      'UniqueId':uniqueId,
      'Timestamp':timestamp,
      'Pending':null,
    });

  }

  ///Add to user received records before approval happens
  addToUserReceivedSuccessfully({String? Share,required DateTime timestamp}){
    recordsRef
        .doc(currentUserId)
        .collection('receivedSuccessfully')
        .doc(uniqueId)
        .set({
      'Description':Share,
      'From':ownerId,
      'Status':null,
      'PostId':postId,
      'UniqueId':uniqueId,
      'Timestamp':timestamp,
      'Pending':null,
    });


  }


  ///Delete request from user documents
  removefromSenderSent({required String New_unique_id}){
    requestsRef
        .doc(currentUserId)
        .collection('acceptanceRequestsSent')
        .doc(New_unique_id)
        .delete();

  }
  ///Delete from postOwner shared records
  removefromSharerSharedSuccessfully({required String New_unique_id}){
    recordsRef
        .doc(ownerId)
        .collection('sharedSuccessfully')
        .doc(New_unique_id)
        .delete();

  }


  ///Delete request from postOwner documents
  removefromDestinationReceive({required String New_unique_id}){
    requestsRef
        .doc(ownerId)
        .collection('acceptanceRequestsReceived')
        .doc(New_unique_id)
        .delete();


  }
  ///Delete from user received records
  removefromUserReceivedSuccessfully({required String New_unique_id}){
    recordsRef
        .doc(currentUserId)
        .collection('receivedSuccessfully')
        .doc(New_unique_id)
        .delete();

  }





///sending user request
  handleSubmitAcceptanceRequest()async{
    final DateTime Timestamp= DateTime.now();
    addToUserSent(
        Share:share,
      timestamp:Timestamp,
    );
    ///Add post to timeline
    addToDestinationReceive(
      Share:share,
      timestamp:Timestamp,
    );
    addToUserReceivedSuccessfully(
      Share:share,
      timestamp:Timestamp,
    );
    addToSharerSharedSuccessfully(
      Share:share,
      timestamp:Timestamp,
    );
    setState((){
      uniqueId=const Uuid().v4();
    });
    Navigator.pop(context);

    }
///canceling user request
  handleCancelAcceptanceRequest()async{
  await new_unique_id;
    removefromSenderSent(
      New_unique_id: new_unique_id
    );
    ///Add post to timeline
    removefromDestinationReceive(
      New_unique_id: new_unique_id
    );
    Navigator.pop(context);

    }

/*    timelineDelete()async{
      await timelineRef
      .doc(postId)
      .delete();

    }*/

String share="Share Post";


var new_unique_id;


  @override
  Widget build(BuildContext context) {
  ///getting size(height,width) of the target device
    final Size size =MediaQuery.of(context).size;

    ///Template for posts made by users
        return Column(
          children:<Widget>[
            ///Details about the post
            Container(
              margin:EdgeInsets.only(top:10,),
              color: Colors.grey.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ///UserImage,username & time,price
                  Row(
                    children: [
                      ///UserProfilePhoto
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 25,
                          child:
                          ///StreamBuilder to get profile image upon update
                          StreamBuilder(
                              stream: usersRef.doc(widget.ownerId).snapshots(),
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
                                        shape: BoxShape.circle,
                                        //borderRadius: BorderRadius.circular(50),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///Username & position
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=>
                                      P.Profile(profileId:ownerId,)));
                            },
                            child: FittedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(username.toString(),
                                    style: TextStyle(
                                        fontSize:17,

                                    ),
                                    textAlign: TextAlign.left,
                                    softWrap: true,),
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
                                  Text(shared_as.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black.withOpacity(0.5)
                                  ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ///Time post was made
                          FittedBox(
                            child: Text(
                              timeago.format(timestamp.toDate()),
                              overflow:TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize:12,
                                  color: Colors.black.withOpacity(0.5)
                              ),
                              softWrap: true,),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),

                      ownerId==currentUserId?
                      SizedBox():
                      ///If user has already sent a request he can only cancel and not resend a request
                      StreamBuilder<QuerySnapshot?>(
                          stream:FirebaseFirestore.instance
                              .collection('requests')
                              .doc(currentUserId)
                              .collection('acceptanceRequestsSent')
                              .where('To',isEqualTo:ownerId.toString())
                              .where('PostId',isEqualTo:postId.toString())
                              .snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
                            if (snapshot.hasError){
                              return SizedBox();
                            }
                            if(snapshot.connectionState==ConnectionState.waiting){
                              return SizedBox();
                            }
                            ///Checking if there is already a request sent if not the send request is shown
                            if(snapshot.hasData && snapshot.data?.size==0){
                              return GestureDetector(
                                onTap: ()=>
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context){
                                          return DraggableScrollableSheet(
                                              expand: false,
                                              initialChildSize: 0.1,
                                              minChildSize: 0.1,
                                              maxChildSize: 0.2,
                                              builder: (BuildContext context, ScrollController scrollcontroller){
                                                return ListTile(
                                                  title:Text('Send acceptance request to : '+"  "+username.toString()),
                                                  onTap:()=>handleSubmitAcceptanceRequest(),
                                                );
                                              }
                                          );
                                        }
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Icon(Icons.edit_road_rounded),
                                ),

                              );
                            }
                            ///If there is already a request, cancel request is shown
                            return
                              GestureDetector(
                                onTap: ()=>
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context){
                                          return DraggableScrollableSheet(
                                              expand: false,
                                              initialChildSize: 0.1,
                                              minChildSize: 0.1,
                                              maxChildSize: 0.2,
                                              builder: (BuildContext context, ScrollController scrollcontroller){
                                                return Column(
                                                    children:snapshot.data!.docs
                                                        .map((DocumentSnapshot document) {
                                                      Map<String, dynamic> data =
                                                      document.data()! as Map<String,dynamic>;
                                                      new_unique_id=data['UniqueId'].toString();
                                                      return
                                                        ListTile(
                                                          title:Text('Cancel request to : '+"  "+username.toString()),
                                                          onTap:()=>handleCancelAcceptanceRequest(),
                                                        );

                                                    }) .toList()
                                                );
                                              }
                                          );
                                        }
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Icon(Icons.edit_road_rounded),
                                ),

                              );





                          }



                      ),

                      ///Price
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: pstatus.toString()=="free"? Colors.green:Colors.orange,
                          ),
                          ///Price
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(pstatus.toString(),
                                style: TextStyle(
                                    fontSize:17,
                                  color:Colors.white,
                                ),
                                softWrap: true,),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ///Description
                  Container(
                    margin: EdgeInsets.only(left:5, right:5,bottom: 10,top: 5),
                      alignment: Alignment.centerLeft,
                      child: Text(description.toString(),
                  )),
                  ///PostImage
                  GestureDetector(
                    onTap: ()=>ShowViewPosts(
                      context,
                      username:username,
                      status: pstatus,
                      mediaUrl:mediaUrl,
                      description: description,
                      ownerId: ownerId,

                    ),
                    child: Container(
                      height: 300,
                      width: size.width,
                      //margin: EdgeInsets.only(left: 10,right: 10),
                      child: FittedBox(
                        clipBehavior: Clip.hardEdge,
                        fit: BoxFit.fitWidth,
                        child: CachedNetworkImage(
                          imageUrl:mediaUrl!,
                          placeholder: (context, url) => Container(
                              height: 300,
                              width: 300,
                              child:Icon(Icons.image)  ),
                          errorWidget: (context, url, error) => Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ///PostOwner's successfully shared record
            Container(
              height: 30,
              width: size.width,
              color: Colors.grey.shade50,
              child: SizedBox(
              ),
            ),
            ///Colored section to separate posts in list
            Divider(
              thickness: 15,
              color: Colors.brown.withOpacity(0.3),
            ),
          ],
        );

    }

  }

ShowViewPosts(BuildContext context,
    {String? username, String? status, String? mediaUrl,String? description,String?ownerId}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return viewpost(
      postUsername: username,
      postStatus: status,
      postMediaUrl:mediaUrl,
      postDescription:description,
      postOwnerID:ownerId,
    );
  }));
}


class UserProfilePosts extends StatefulWidget {
  final String? mediaUrl;
  final String? postOwnerId;

  UserProfilePosts({
    //this.ingredients,
    this.mediaUrl,
    this.postOwnerId,
  });


  factory UserProfilePosts.fromDocument(DocumentSnapshot doc) {
    return UserProfilePosts(
      mediaUrl: doc['MediaUrl'],
      postOwnerId: doc['OwnerID'],
    );
  }


  @override
  State<UserProfilePosts> createState() => _UserProfilePostsState(

    mediaUrl:this.mediaUrl,
    postOwnerId:this.postOwnerId,

  );
}

class _UserProfilePostsState extends State<UserProfilePosts> {
  final String? mediaUrl;
  final String? postOwnerId;
  _UserProfilePostsState({
    this.mediaUrl,
    this.postOwnerId,
});

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return
    SizedBox(
          width: size.width/3,
          height: size.width/3,
          child: FittedBox(
            fit: BoxFit.cover,
           child: GestureDetector(
        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) {
      return  PostScreen(
        id:postOwnerId,
      );
    })),
         child:  CachedNetworkImage(
                imageUrl:mediaUrl!,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.image_not_supported),

         )

        ),
      ),
    );
  }
}




class PostView extends StatefulWidget {
  
  
  String postId;
  String? Id;

   PostView({
    required this.postId,
    this.Id,
   });

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;

  final usersRef = FirebaseFirestore.instance.collection('users');

  buildReceivedPostView(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('posts')
            .doc(currentUserId)
            .collection('userposts')
            .where('PostId',isEqualTo: widget.postId.toString())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Text('Something went wrong');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Text('Loading');
          }
          if(snapshot.data==null){
            return Text('Null');
          }
          return Scaffold(
            ///List of chats with other users
            body: ListView(
              children:snapshot.data!.docs
                  .map((DocumentSnapshot document){
                Map<String, dynamic> data=
                document.data()! as Map<String,dynamic>;
                return Column(
                  children:<Widget>[
                    ///Details about the post
                    Container(
                      margin:EdgeInsets.only(top:10,),
                      color: Colors.grey.shade50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ///UserImage,username & time,price
                          Row(
                            children: [
                              ///UserProfilePhoto
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 25,
                                  child:
                                  ///StreamBuilder to get profile image upon update
                                  StreamBuilder(
                                      stream: usersRef.doc(currentUserId).snapshots(),
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
                                                shape: BoxShape.circle,
                                                //borderRadius: BorderRadius.circular(50),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///Username & position
                                  FittedBox(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(data['Username'].toString(),
                                          style: TextStyle(
                                            fontSize:17,

                                          ),
                                          textAlign: TextAlign.left,
                                          softWrap: true,),
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
                                        Text(data['Shared as'].toString(),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black.withOpacity(0.5)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ///Time post was made
                                  FittedBox(
                                    child: Text(data['Timestamp'].toString(),
                                      style: TextStyle(
                                          fontSize:12,
                                          color: Colors.black.withOpacity(0.5)
                                      ),
                                      softWrap: true,),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: SizedBox(),
                              ),
                              ///Price
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:data['Price Status'].toString()=="free"? Colors.green:Colors.orange,
                                  ),

                                  ///Price
                                  child: FittedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(data['Price Status'].toString(),
                                        style: TextStyle(
                                          fontSize:17,
                                          color:Colors.white,
                                        ),
                                        softWrap: true,),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Icon(Icons.edit_road_rounded),
                              ),
                            ],
                          ),
                          ///Description
                          Container(
                              margin: EdgeInsets.only(left:5, right:5,bottom: 10,top: 5),
                              alignment: Alignment.centerLeft,
                              child: Text(data['Description'].toString(),
                              )),
                          ///PostImage
                          Container(
                            height: 300,
                            width:MediaQuery.of(context).size.width,
                            //margin: EdgeInsets.only(left: 10,right: 10),
                            child: FittedBox(
                              clipBehavior: Clip.hardEdge,
                              fit: BoxFit.fitWidth,
                              child: CachedNetworkImage(
                                imageUrl:data['MediaUrl'].toString(),
                                placeholder: (context, url) => Container(
                                    height: 300,
                                    width: 300,
                                    child:Icon(Icons.image)  ),
                                errorWidget: (context, url, error) => Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ///PostOwner's successfully shared record
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey.shade50,
                      child: SizedBox(
                      ),
                    ),
                    ///Colored section to separate posts in list
                    Divider(
                      thickness: 15,
                      color: Colors.brown.withOpacity(0.3),
                    ),
                  ],
                );


              })
                  .toList()

                  .cast(),

            ),
          );
        }
    );
  }

  buildSentPostView(){
    return StreamBuilder<QuerySnapshot?>(
        stream:FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.Id)
            .collection('userposts')
            .where('PostId',isEqualTo: widget.postId.toString())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot){
          if (snapshot.hasError){
            return Text('Something went wrong');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Text('Loading');
          }
          if(snapshot.data==null){
            return Text('Null');
          }
          return Scaffold(
            ///List of chats with other users
            body: ListView(
              children:snapshot.data!.docs
                  .map((DocumentSnapshot document){
                Map<String, dynamic> data=
                document.data()! as Map<String,dynamic>;
                return Column(
                  children:<Widget>[
                    ///Details about the post
                    Container(
                      margin:EdgeInsets.only(top:10,),
                      color: Colors.grey.shade50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ///UserImage,username & time,price
                          Row(
                            children: [
                              ///UserProfilePhoto
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 25,
                                  child:
                                  ///StreamBuilder to get profile image upon update
                                  StreamBuilder(
                                      stream: usersRef.doc(widget.Id).snapshots(),
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
                                                shape: BoxShape.circle,
                                                //borderRadius: BorderRadius.circular(50),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///Username & position
                                  FittedBox(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(data['Username'].toString(),
                                          style: TextStyle(
                                            fontSize:17,

                                          ),
                                          textAlign: TextAlign.left,
                                          softWrap: true,),
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
                                        Text(data['Shared as'].toString(),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black.withOpacity(0.5)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ///Time post was made
                                  FittedBox(
                                    child: Text(data['Timestamp'].toString(),
                                      style: TextStyle(
                                          fontSize:12,
                                          color: Colors.black.withOpacity(0.5)
                                      ),
                                      softWrap: true,),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: SizedBox(),
                              ),
                              ///Price
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:data['Price Status'].toString()=="free"? Colors.green:Colors.orange,
                                  ),

                                  ///Price
                                  child: FittedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(data['Price Status'].toString(),
                                        style: TextStyle(
                                          fontSize:17,
                                          color:Colors.white,
                                        ),
                                        softWrap: true,),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Icon(Icons.edit_road_rounded),
                              ),
                            ],
                          ),
                          ///Description
                          Container(
                              margin: EdgeInsets.only(left:5, right:5,bottom: 10,top: 5),
                              alignment: Alignment.centerLeft,
                              child: Text(data['Description'].toString(),
                              )),
                          ///PostImage
                          Container(
                            height: 300,
                            width:MediaQuery.of(context).size.width,
                            //margin: EdgeInsets.only(left: 10,right: 10),
                            child: FittedBox(
                              clipBehavior: Clip.hardEdge,
                              fit: BoxFit.fitWidth,
                              child: CachedNetworkImage(
                                imageUrl:data['MediaUrl'].toString(),
                                placeholder: (context, url) => Container(
                                    height: 300,
                                    width: 300,
                                    child:Icon(Icons.image)  ),
                                errorWidget: (context, url, error) => Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ///PostOwner's successfully shared record
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey.shade50,
                      child: SizedBox(
                      ),
                    ),
                    ///Colored section to separate posts in list
                    Divider(
                      thickness: 15,
                      color: Colors.brown.withOpacity(0.3),
                    ),
                  ],
                );


              })
                  .toList()

                  .cast(),

            ),
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return widget.Id!=currentUserId? buildSentPostView():
    buildReceivedPostView();
  }
}
