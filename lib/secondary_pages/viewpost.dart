import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:sates/secondary_pages/chat_detail.dart';
import '../authentication/createpage.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/constant_widgets.dart';





class viewpost extends StatefulWidget {
  final String? postUsername;
  final String? postStatus;
  final String? postMediaUrl;
  final String? postDescription;
  final String? postOwnerID;
  final String? ingredients;
  final String? location;
  var time;

  viewpost({
    this.postUsername,
    this.postStatus,
    this.postMediaUrl,
    this.postDescription,
    this.postOwnerID,
    this.ingredients,
    this.location,
    this.time,
  });

  @override
  State<viewpost> createState() => _viewpostState(
    postUsername: this.postUsername,
    postStatus: this.postStatus,
    postMediaUrl: this.postMediaUrl,
    postDescription: this.postDescription,
    postOwnerID: this.postOwnerID,
    ingredients:this.ingredients,
    location:this.location,
    time:this.time,
  );
}

class _viewpostState extends State<viewpost> {
  final currentUser= auth.currentUser;
  final String? postUsername;
  final String? postStatus;
  final String? postMediaUrl;
  final String? postOwnerID;
  final String? postDescription;
  final String? ingredients;
  final String? location;
  var time;

  _viewpostState({
    this.postUsername,
    this.postStatus,
    this.postMediaUrl,
    this.postDescription,
    this.postOwnerID,
    this.ingredients,
    this.location,
    this.time,
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
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.orange
        ),
        title:Column(

          children: [

            CachedNetworkImage(
              imageUrl:imUrl.toString(),
              imageBuilder: (context, imageProvider) => Container(
                margin: EdgeInsets.only(bottom: 5),
                height: 35,
                decoration: BoxDecoration(
                  shape:BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 7.0),
              child: CustomText3(postUsername.toString()),
            ),


          ],
        ),
            toolbarHeight:80,
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
              isLoop: true,
              height: 450,
                children:[
                  Container(
                    //height: size.height/2.7,
                    //width: size.width,
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
                        color: Colors.green.shade100.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    margin: EdgeInsets.only(bottom: 20,left: 4,right: 4,top: 4),
                    width: size.width,

                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomText4(postDescription.toString(),Colors.black
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
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.green,
                    ),
                    margin: EdgeInsets.only(top: 15,left: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomText4('Description',Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),


            ///Ingredients

            ExpandablePanel(
              collapsed: Text(''),
              expanded: FittedBox(
                fit: BoxFit.fill,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green.shade100.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  margin: EdgeInsets.only(bottom: 20,left: 4,right: 4,top: 4),
                  width: size.width,

                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CustomText4(ingredients.toString(),
                    Colors.black
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
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.green,
                      ),
                      margin: EdgeInsets.only(top: 15,left: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText4('Ingredients / Content',
                            Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ///Location


            ExpandablePanel(
              collapsed: Text(''),
              expanded:FittedBox(
                fit: BoxFit.fill,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20,left: 4,right: 4,top: 4),
                  width: size.width,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CustomText4(location.toString(),Colors.black
                    ),
                  ),
                ),
              ),
              header: Row(
                children: [
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.green,
                      ),
                      margin: EdgeInsets.only(top: 15,left: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText4('Location',
                            Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            ),

            ///Price

            ExpandablePanel(
              collapsed: Text(''),
              expanded:FittedBox(
                fit: BoxFit.fill,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20,left: 4,right: 4,top: 4),
                  width: size.width,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CustomText4(postStatus.toString(),
                     Colors.black
                    ),
                  ),
                ),
              ),
              header: Row(
                children: [
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.green,
                      ),
                      margin: EdgeInsets.only(top: 15,left: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText4('Price',
                            Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            ),
          ],
        )
      ),


      ///disabling and enabling the message icon depending on post owner
      floatingActionButton:postOwnerID==currentUser!.uid ?
      SizedBox(): FloatingActionButton.extended(
        backgroundColor: Colors.orange,
          onPressed:()=>Navigator.push(context, MaterialPageRoute(
              builder: (context)=> Chatset(
                friendName: postUsername.toString(),
                friendUid: postOwnerID,
               friendurl:imUrl,
                ))),
          label:Text('$postUsername'),
          icon:Icon(Icons.textsms_outlined),
      ),

    );
  }
}
