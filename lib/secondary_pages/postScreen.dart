import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/post.dart';
import '../models/userfiles.dart';
import '../widgets/constant_widgets.dart';



class PostScreen extends StatefulWidget {
 final String id;

  PostScreen({required this.id}) ;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final postsTimelineRef = FirebaseFirestore.instance.collection('postsTimeline');
  final usersRef = FirebaseFirestore.instance.collection('users');
  bool isLoading=false;

  @override
  void initState() {
buildProfilePosts();
    super.initState();

  }


  buildProfilePosts() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.id)
            .collection('userposts')
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
              return Column(
                children:<Widget>[
                  ///Details about the post
                  Container(
                    margin:EdgeInsets.only(top:10,),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ///UserImage,username & time,price
                        Row(
                          children: [
                            ///UserProfilePhoto
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: StreamBuilder(
                                  stream: usersRef.doc(widget.id).snapshots(),
                                  //Resolve Value Available In Our Builder Function
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          //borderRadius: BorderRadius.circular(50),
                                        ),
                                      );
                                    }
                                    //Deserialize
                                    //print(widget.profileId);
                                    var DocData = snapshot.data as DocumentSnapshot;
                                    GUser gUser = GUser.fromDocument(DocData);
                                    return CachedNetworkImage(
                                      imageUrl:gUser.profilePhotoUrl.toString(),
                                      imageBuilder: (context, imageProvider) => Container(
                                        height:45,
                                        width: 45,
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
                                    );
                                  }

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

                              ],
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                             data['Donated']==true?SizedBox():data['OnTimeline']==true?
                             (widget.id==currentUserId?
                             ///If there is already a request, cancel request is shown
                             GestureDetector(
                               onTap: ()=>
                                   showModalBottomSheet(
                                       isScrollControlled: true,
                                       context: context,
                                       builder: (BuildContext context){
                                         return DraggableScrollableSheet(
                                             expand: false,
                                             initialChildSize: 0.3,
                                             minChildSize: 0.1,
                                             maxChildSize: 0.3,
                                             builder: (BuildContext context, ScrollController scrollcontroller){
                                               return Column(
                                                   children:snapshot.data!.docs
                                                       .map((DocumentSnapshot document) {
                                                     Map<String, dynamic> data =
                                                     document.data()! as Map<String,dynamic>;
                                                     //new_unique_id=data['UniqueId'].toString();
                                                     return
                                                       Column(
                                                         children: [
                                                           ListTile(
                                                             title:Text('Delete post entirely'),
                                                             onTap:()async{
                                                               p_id= await data['PostId'].toString();
                                                               deleteEntirely();
                                                             },
                                                           ),
                                                           ListTile(
                                                             title:Text('Remove post from timeline'),
                                                             onTap:()async{
                                                               p_id= await data['PostId'].toString();

                                                               timelineDelete();
                                                             },
                                                           ),
                                                         ],
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

                             )
                             /*GestureDetector(
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
                                        title:Text('Delete post'),
                                        onTap:()=>timelineDelete(),
                                      );
                                    }
                                );
                              }
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(Icons.edit),
                      ),

                    )*/:
                             ///If user has already sent a request he can only cancel and not resend a request
                             StreamBuilder<QuerySnapshot?>(
                                 stream:FirebaseFirestore.instance
                                     .collection('requests')
                                     .doc(currentUserId)
                                     .collection('acceptanceRequestsSent')
                                     .where('To',isEqualTo:widget.id.toString())
                                     .where('PostId',isEqualTo:data['PostId'].toString())
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
                                                         title:Text('Send acceptance request to : '+"  "+data['Username'].toString()),
                                                         onTap:(){},
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
                                                             //new_unique_id=data['UniqueId'].toString();
                                                             return
                                                               ListTile(
                                                                 title:Text('Cancel request to : '+"  "+data['Username'].toString()),
                                                                 onTap:(){},
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



                             )
                             )
                                 :GestureDetector(
                               onTap:()=>
                                   showModalBottomSheet(
                                       isScrollControlled: true,
                                       //barrierDismissible: true,
                                       //semanticsDismissible: true,
                                       barrierColor: Colors.black.withOpacity(0.2),
                                       context: context,
                                       builder: (BuildContext context){
                                         return DraggableScrollableSheet(
                                           initialChildSize: 0.3,
                                           minChildSize: 0.3,
                                           maxChildSize: 0.3,
                                           expand: false,
                                           builder:
                                               (BuildContext context, ScrollController scrollController) {
                                             return Column(
                                               children: [
                                                 ListTile(
                                                   title: Text('Delete from timeline'),
                                                   onTap: (){
                                                     p_id=data['PostId'].toString();
                                                     timelineDelete();
                                                   },
                                                 ),
                                                 ListTile(
                                                   title: Text('Delete Entirely'),
                                                   onTap: (){
                                                     p_id=data['PostId'].toString();
                                                    deleteEntirely();
                                                   },
                                                 ),
                                               ],
                                             );
                                           },

                                         );
                                       }
                                   ),
                               child:Icon(Icons.delete)
                             ),

                            ///Price
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: data['Price Status'].toString().toLowerCase()=="free"? Colors.green:Colors.orange,
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
                            ///If owner of the post is the currentuser he wont be allowed to send himself
                            ///a request hence the button will not show on his post
                          ],
                        ),
                        ///Description
                        Container(
                            margin: EdgeInsets.only(left:5, right:5,bottom: 10,top: 5),
                            alignment: Alignment.centerLeft,
                            child: Text(data['Description'].toString(),
                            )),
                        ///PostImage
                        GestureDetector(
                          onTap: ()=>ShowViewPosts(
                            context,
                            username:data['Username'],
                            status: data['Price Status'],
                            mediaUrl:data['MediaUrl'],
                            description: data['Description'],
                            ownerId: data['OwnerID'],
                          ),
                          child: Container(
                            height: 300,
                            width: MediaQuery.of(context).size.width,
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
                        ),
                      ],
                    ),
                  ),
                  ///PostOwner's successfully shared record
                  Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Row(
                        children: [
                         data['Donated']!=true?
                         (data['On Timeline']!=true? Icon(Icons.dangerous_sharp,color: Colors.red,):SizedBox())
                             :Icon(Icons.check_circle,color: Colors.green,),

                        ],
                      ),
                    ),
                  ),
                  ///Colored section to separate posts in list

                ],
              );

            })
                .toList()

                .cast(),

          );
        }
    );

  }

  timelineDelete()async{
    ///change timeline status
    await postsRef
        .doc(widget.id)
        .collection('userposts')
        .doc(p_id)
        .update({
      'On Timeline':false
    });
    ///delete from timeline
    await postsTimelineRef
        .doc(p_id)
        .update({
      'On Timeline':false
    });

    Navigator.pop(context);
  }


  deleteEntirely()async{
    ///delete entirely
    await postsRef
        .doc(widget.id)
        .collection('userposts')
        .doc(p_id)
        .delete();
   await postsTimelineRef
        .doc(p_id)
        .delete();

    Navigator.pop(context);
  }



  bool? del_e;
  var p_id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        title:CustomText8('Profile Posts',

        ),
        toolbarHeight:90,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: buildProfilePosts()
    );
  }
}
