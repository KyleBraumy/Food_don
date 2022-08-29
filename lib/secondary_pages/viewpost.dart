import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:sates/secondary_pages/chat_detail.dart';
import '../authentication/createpage.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';




final CU_id=FirebaseFirestore.instance.collection('users').where('Id',isEqualTo: auth.currentUser!.uid).get(
);
class viewpost extends StatefulWidget {
  final String? postUsername;
  final String? postStatus;
  final String? postMediaUrl;
  final String? postDescription;
  final String? postOwnerID;


  viewpost({
    this.postUsername,
    this.postStatus,
    this.postMediaUrl,
    this.postDescription,
    this.postOwnerID,
  });

  @override
  State<viewpost> createState() => _viewpostState(
    postUsername: this.postUsername,
    postStatus: this.postStatus,
    postMediaUrl: this.postMediaUrl,
    postDescription: this.postDescription,
    postOwnerID: this.postOwnerID,
  );
}

class _viewpostState extends State<viewpost> {
  final currentUser= auth.currentUser;
  final String? postUsername;
  final String? postStatus;
  final String? postMediaUrl;
  final String? postOwnerID;
  final String? postDescription;
  final CU_id=FirebaseFirestore.instance.collection('users').where('Id',isEqualTo: auth.currentUser!.uid).get();
  _viewpostState({
    this.postUsername,
    this.postStatus,
    this.postMediaUrl,
    this.postDescription,
    this.postOwnerID,
});

  @override
  void initState() {
    getUserUrl();
    super.initState();
  }



  getUserUrl()async{
    await usersRef
        .doc(widget.postOwnerID)
        .get()
        .then((ds){
      var pUrl=ds.data()!['ProfilePhotoUrl'];
      setState(()=>imUrl=pUrl);
    }).catchError((e){
      print(e);
    });
  }



var imUrl;

  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
   return
    Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.orange
        ),
        title:Column(
          children: [
            CircleAvatar(
              radius: 17,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl:imUrl.toString(),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
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
            Text(postUsername.toString(),
              style: TextStyle(color: Colors.orange,
              fontSize: 20,
              ),
              textAlign: TextAlign.center,),
          ],
        ),
            toolbarHeight:70,
       actions: [
         Padding(
           padding: const EdgeInsets.all(15.0),
           child: Icon(Icons.info_outline_rounded),
         ),
       ],
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child:Column(
          children: <Widget>[
            ImageSlideshow(

                children:[
                  Container(
                    height: size.height/3,
                    width: size.width,
                    color: Colors.green,
                    child: CachedNetworkImage(
                      imageUrl:postMediaUrl!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Container(
                    height: size.height/3,
                    width: size.width,
                    color: Colors.green,
                    child: CachedNetworkImage(
                      imageUrl:postMediaUrl!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Container(
                    height: size.height/3,
                    width: size.width,
                    color: Colors.green,
                    child: CachedNetworkImage(
                      imageUrl:postMediaUrl!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ]
            ),
            ///Description
            ExpandablePanel(
                collapsed: Text(''),
                expanded: FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey.shade300,
                    ),
                    margin: EdgeInsets.only(bottom: 40,left: 4,right: 4),
                    width: size.width,

                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(postDescription.toString(),
                        style: TextStyle(
                          fontSize:17,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
                header:Row(
              children: [
                FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green,
                    ),

                    margin: EdgeInsets.only(top: 15,left: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text('Description',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ],
            ),


            ),


            ///Ingredients
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    color: Colors.green,
                    margin: EdgeInsets.only(top: 15,left: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Ingredients/Content',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.fill,
              child: Container(
                margin: EdgeInsets.all(4),
                width: size.width,
                color: Colors.grey.shade300,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(postDescription.toString(),
                    style: TextStyle(
                      fontSize:17,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            ///Location
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    color: Colors.green,
                    margin: EdgeInsets.only(top: 15,left: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Location',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            FittedBox(
              fit: BoxFit.fill,
              child: Container(
                margin: EdgeInsets.all(4),
                width: size.width,
                color: Colors.grey.shade300,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(postDescription.toString(),
                    style: TextStyle(
                      fontSize:17,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),


            ///Price
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                    color: Colors.green,
                    margin: EdgeInsets.only(top: 15,left: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Price',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.fill,
              child: Container(
                margin: EdgeInsets.all(4),
                width: size.width,
                color: Colors.grey.shade300,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(postStatus.toString(),
                    style: TextStyle(
                      fontSize:17,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),

          ],
        )
      ),

      floatingActionButton:postOwnerID==currentUser!.uid ? SizedBox(): FloatingActionButton.extended(
        backgroundColor: Colors.orange,
          onPressed:()=>Navigator.push(context, MaterialPageRoute(
              builder: (context)=> ChatDetail(
                friendName: postUsername.toString(),
                friendUid: postOwnerID,
                ))),
          label:Text('$postUsername'),
          icon:Icon(Icons.textsms_outlined),
      ),

    );
  }
}
