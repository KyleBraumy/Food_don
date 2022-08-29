import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart'as Im;
import 'package:sates/widgets/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sates/authentication/auth.dart';
import 'package:sates/main_pages/home.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sates/models/userfiles.dart';
import 'package:sates/widgets/progress.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/constant_widgets.dart';



final FirebaseAuth auth =FirebaseAuth.instance;
final usersRef = FirebaseFirestore.instance.collection('users');
final storageRef = FirebaseStorage.instance.ref('Images');
final postsRef = FirebaseFirestore.instance.collection('posts');
final timelineRef = FirebaseFirestore.instance.collection('postsTimeline');
final requestsTimelineRef = FirebaseFirestore.instance.collection('requestsTimeline');
final requestsRef = FirebaseFirestore.instance.collection('requests');

///Sharing posts
class ShareForm extends StatefulWidget {
 bool isOrgInd;
ShareForm({required this.isOrgInd});

  @override
  State<ShareForm> createState() => _ShareFormState(

  );
}

class _ShareFormState extends State<ShareForm> {

  final _formkey= GlobalKey<FormState>();
  bool isUploading=false;
  String postId= Uuid().v4();
  final currentUser= auth.currentUser;
  _fetch()async{
    if (currentUser!.uid!=null)
      await usersRef
          .doc(currentUser!.uid)
          .get()
          .then((ds){
        _username=ds.data()!['Last Name']+" "+ds.data()!['First Name'];

      }).catchError((e){
        print(e);
      });
  }

  File? file;

  ///Take photo using camera
  handleTakePhoto(context)async{
    Navigator.pop(context);
    var image= await ImagePicker.platform.pickImage(source:ImageSource.camera);
    setState((){
      file=File(image!.path);
    });
  }
  ///Choose photo from gallery
  handleChooseFromGallery(context)async{
    Navigator.pop(context);
    var image= await ImagePicker.platform.pickImage(source:ImageSource.gallery);
    setState((){
      file=File(image!.path);
    });
  }
  ///Function to clear image
  clearImage(){
    setState((){
      file=null;
    });
}
  ///Dialog to show select image options
  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title:  Text('Select Image'),
            children: [
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed:()=>handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child: Text('Choose image from Gallery'),
                onPressed:()=>handleChooseFromGallery(context),
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: ()=>Navigator.pop(context),
              ),
            ],
          );
    }
    );
  }

//form values
  String? _username;
  late bool IsOrgInd=widget.isOrgInd;
  var city;
  late String _ingredients;
  late String _description;
  late String _status;

  ///Compress uploaded image for upload
  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    //Read Image File We Have In State Putting It In imageFile
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressesImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 50));
    setState(() {
      file = compressesImageFile;
    });
  }
  ///Upload image unto firebase storage
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
    storageRef.child('post_$postId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  ///Create post details for user in firestore
 createFirestorePostDetails({String? username, String? description, String? mediaUrl,
   String? pstatus,DateTime? timestamp,String? city,String? ingr_cont,String? shared_as, String? shared}){
   postsRef
   .doc(currentUser!.uid)
   .collection('userposts')
    .doc(postId)
     .set({
     'PostId':postId,
     'Username':username,
     'Donated':false,
     'On Timeline':true,
     'Price Status':pstatus,
     'OwnerID':currentUser!.uid,
     'Timestamp':timestamp,
     'Description':description,
     'Location':city,
     'MediaUrl':mediaUrl,
     'Ingredients_Content':ingr_cont,
     'Shared':shared,
     'Shared as':shared_as,
   });


 }

 ///Add post to timeline
 addPostTimeline({String? username,String? description, String? pstatus, String? mediaUrl,
   DateTime?  timestamp,String? city,String? ingr_cont,String? shared_as, String? shared}){
   timelineRef
    .doc(postId)
     .set({
     'PostId':postId,
     'Username':username,
     'Price Status':pstatus,
     'OwnerID':currentUser!.uid,
     'Timestamp':timestamp,
     'Donated':false,
     'On Timeline':true,
     'Description':description,
     'MediaUrl':mediaUrl,
     'Location':city,
     'Ingredients_Content':ingr_cont,
     'Shared':shared,
     'Shared as':shared_as,
   });


 }



///Submit function to handle all the processes in order of priority
 handleSubmit()async{
   final DateTime timestamp= DateTime.now();
    setState((){
      isUploading=true;
    });
    if (_formkey.currentState!.validate()){
         await compressImage();
         String mediaUrl=await uploadImage(file);
         createFirestorePostDetails(
           username: _username,
           pstatus: _status,
           timestamp:timestamp,
           city:city,
           mediaUrl:mediaUrl,
           description:_description,
           ingr_cont: _ingredients,
           shared: result1,
           shared_as: result,
         );
         addPostTimeline(
           username: _username,
           pstatus: _status,
           timestamp:timestamp,
           city:city,
           mediaUrl:mediaUrl,
           description:_description,
           ingr_cont: _ingredients,
           shared: result1,
           shared_as: result,
         );
         setState((){
           isUploading=false;
           postId= Uuid().v4();
           Navigator.pop(context);

         });

       }else{
      setState((){
        isUploading=false;
      });
    }


 }


  void dropdownCallback2(selectedValue){
    setState((){
      city= selectedValue;
    });
  }


String result="";
String result1="";
String error="";
bool value1 =false;
bool value2 =false;
bool value3 =false;
bool value4 =false;
  var res_C="Select city closest to your residence";

  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    print (result);
    print (result1);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading:  GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            alignment: Alignment.center,
            child: Text('Cancel',style:TextStyle(
                color: Colors.green
            )),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text('Share',style:TextStyle(
          color: Colors.orange
        )),
        actions: [
          ///Post button
          file==null? SizedBox():
          RaisedButton(
            color: Colors.green,
            onPressed:isUploading?null: ()=> handleSubmit(),
            child:  Text('Post',
              style:  TextStyle(color: Colors.white),),

          ),
        ],
      ),

      body: IsOrgInd==true?
      SingleChildScrollView(
        child:Column(
          children: [

            isUploading? linearProgress(): SizedBox(),
            ///Image upload Container

            file==null?
            GestureDetector(
              onTap: ()=>selectImage(context),
              child: Container(
                margin:  EdgeInsets.all(10),
                height: 300,
                width: size.width,
                color:Colors.green.shade100,
                child: Center(
                  child:Icon(Icons.image_outlined,
                    color: Colors.orange.shade300,
                    size: 50,),
                ),
              ),
            ):
                ///Container for uploaded image file
            Container(
              margin:  EdgeInsets.all(10),
              width: size.width,
              height: 300,
              decoration: BoxDecoration(
                image:DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(file!),
                ),
              ),
            ),
            ///Form for content upload
            Form(
              key:_formkey,
              child: Column(
                children: [
                  ///Choose image and clear image enables only if user has uploaded a file
                  Row(
                    children: [
                      Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: Colors.green,
                          onPressed: ()=>selectImage(context),
                          child:  Text('Choose Image',
                            style: TextStyle(color: Colors.white),),

                        ),
                      ),
                       Expanded(
                        flex: 2,
                          child:  SizedBox(
                      )),
                      Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: file==null?  SizedBox():FlatButton(
                          color: Colors.transparent,
                          onPressed: ()=>clearImage(),
                          child:  Text('Clear Image',
                            style:  TextStyle(color: Colors.red),),

                        ),
                      ),
                    ],
                  ),

                   SizedBox(height: 20.0),
                  ///FutureBuilder to get Username(Last name+ First name)
                  StreamBuilder(
                      stream: usersRef.doc(currentUser!.uid).snapshots(),
                      //Resolve Value Available In Our Builder Function
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: Text('null'));
                        }
                        //Deserialize
                        //print(widget.profileId);
                        var DocData = snapshot.data as DocumentSnapshot;
                        GUser gUser = GUser.fromDocument(DocData);
                        return Container(
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Colors.green.shade100.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: TextFormField(
                              readOnly: true,
                              initialValue:gUser.lname.toString()+" "+gUser.fname.toString(),
                              validator: (val)=>val!.isEmpty?'Enter your Name':null,
                              onChanged: (val){
                                setState(() => _username=val);
                              },
                              decoration: InputDecoration(
                                  border:InputBorder.none
                              ),

                            ),
                          ),
                        );
                      }

                  ),

                  ///status textfield
                  Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.green.shade100.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left:12.0),
                      child: TextFormField(
                        validator: (val)=>val!.isEmpty?'Enter your Value':null,
                        onChanged: (val){
                          setState(() => _status=val);
                        },
                        decoration:  InputDecoration(
                         labelText: 'Status',border: InputBorder.none
                        ),

                      ),
                    ),
                  ),
                  ///city
                  Container(
                    height:size.height/17,
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.green.shade100.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: DropdownButton(
                        hint: Padding(
                          padding:  EdgeInsets.all(4.0),
                          child: FittedBox(child: Text("  "+res_C)),
                        ),
                        isExpanded: true,
                        isDense: true,
                        alignment: AlignmentDirectional.centerEnd,
                        dropdownColor: Colors.white,
                        elevation: 1,
                        // itemHeight:48,
                        underline: SizedBox(),
                        value:city,
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
                            child:Text('Central'),value: "Central",
                          ),
                          DropdownMenuItem(
                            child:Text('Kumasi'),value: "Kumasi",
                          ),
                        ],
                        onChanged:dropdownCallback2,
                      ),
                    ),
                  ),

                  ///description textfield
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green.shade100.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding:EdgeInsets.only(left:12.0),
                      child: TextFormField(
                        validator: (val)=>val!.isEmpty?'Description':null,
                        onChanged: (val){
                          setState(() => _description=val);
                        },
                        decoration:  InputDecoration(
                         labelText: 'Description',border: InputBorder.none
                        ),

                      ),
                    ),
                  ),
                  ///ingredients textfield
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green.shade100.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding:  EdgeInsets.only(left:8.0),
                      child: Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          validator: (val)=>val!.isEmpty?'Ingredients/content':null,
                          onChanged: (val){
                            setState(() => _ingredients=val);
                          },
                          decoration:  InputDecoration(
                           labelText: 'Ingredients/content',border:InputBorder.none
                          ),

                        ),
                      ),
                    ),
                  ),
                  //Dropdown
                   SizedBox(height: 20.0),

                ],
              ),
            )

          ],
        ),
      ):
      SingleChildScrollView(

        child:Column(

          children: [
             Padding(
              padding: EdgeInsets.only(top:20.0,bottom: 10),
              child: CustomText('What do you identify as?',
              null
              ),
            ),
            ///Organization AND Individual containers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///1st checkbox
                Stack(
                  children:[ 
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.orange,
                        borderRadius: BorderRadius.circular(20)
                      ),
                    margin:  EdgeInsets.only(top:7),
                    height: size.height/4,
                    width: size.width/2.2,
                    child: Center(
                      child: Text('Organization'),
                    ),
                  ),
                    Padding(
                      padding:  EdgeInsets.only(left:1.0,top:7),
                      child: Checkbox(
                      value:value1,
                      onChanged: (newVal) {
                        setState(() {
                          value1 = !value1;
                          value2=false;
                          if(value1==true){
                            setState((){
                              result="Organization";
                            });
                          }
                        });
                      }),
                    )
                  ]
                ),
                ///2nd checkbox
                Stack(
                  children:[
                    Container(
                    margin:  EdgeInsets.only(top:7),
                    height: size.height/4,
                    width: size.width/2.2,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),

                      ),
                      child: Center(
                        child: Text('Individual'),
                      ),
                  ),
                    Padding(
                      padding:  EdgeInsets.only(left:1.0,top:7),
                      child: Checkbox(
                      value:value2,
                      onChanged: (newVal) {
                        setState(() {
                          value2 = !value2;
                          value1=false;
                          if(value2==true){
                            setState((){
                              result="Individual";
                            });
                          }
                        });
                      }),
                    )
                  ]
                ),

              ],
            ),

            ///Validating the checkboxes before proceeding
            if(value1==true || value2==true)
              Column(
                children: [
                  Padding(
                    padding:  EdgeInsets.only(top:30.0,bottom: 10),
                    child: CustomText('What do you wish to share?',null),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ///3rd checkbox
                      Stack(
                          children:[
                            Container(
                              margin:  EdgeInsets.only(top:7),
                              height: size.height/4,
                              width: size.width/2.2,
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Center(
                                child: Text('Food Items'),
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:1.0,top:7),
                              child: Checkbox(
                                  value:value3,
                                  onChanged: (newVal) {
                                    setState(() {
                                      value3 = !value3;
                                      value4=false;
                                      if(value3==true){
                                        setState((){
                                          result1="Food Items";
                                        });
                                      }
                                    });
                                  }),
                            ),
                          ]
                      ),
                      ///4th checkbox
                      Stack(
                          children:[
                            Container(
                              margin:  EdgeInsets.only(top:7),
                              height: size.height/4,
                              width: size.width/2.2,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Center(
                                child: Text('Meal'),
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:1.0,top:7),
                              child: Checkbox(
                                  value:value4,
                                  onChanged: (newVal) {
                                    setState(() {
                                      value4 = !value4;
                                      value3=false;
                                      setState((){
                                        result1="Meal";
                                      });
                                    });
                                  }),
                            )
                          ]
                      ),

                    ],
                  ),
                ],
              ),
             SizedBox(),

            ///when all required fields are filled, display next icon
            if((value3==true || value4==true)&& (value1==true || value2==true) )
              GestureDetector(
                onTap: ()async{
                  setState(()=> IsOrgInd=true);
                },
                child: Container(
                  margin: EdgeInsets.all(40),
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Icon(Icons.navigate_next,color: Colors.white,),
                ),
              ),
              Container(
                margin: EdgeInsets.all(40),
                height: 40,
                width: 70,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Icon(Icons.navigate_next,color: Colors.white,),
              ),

          ],
        ),
      )
    );



 }


}





///Request posting
class RequestForm extends StatefulWidget {
  bool isOrgInd;
 RequestForm({required this.isOrgInd});

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {

  _fetch()async{
    if (currentUser!.uid!=null)
      await usersRef
          .doc(currentUser!.uid)
          .get()
          .then((ds){
        _username=ds.data()!['Last Name']+" "+ds.data()!['First Name'];
       _userImage=ds.data()!['ProfilePhotoUrl'];
      }).catchError((e){
        print(e);
      });
  }


  final _formkey= GlobalKey<FormState>();
  bool isUploading=false;
  String RequestpostId= Uuid().v4();
  final currentUser= auth.currentUser;


  ///Create post details for user in firestore
  createFirestorePostDetails({String? username, String? description,
    String? pstatus,String? timestamp,String? location,String? requested,String? requestedId, String? requested_as}){
    requestsRef
        .doc(currentUser!.uid)
        .collection('userRequests')
        .doc(RequestpostId)
        .set({
      'RequestId':RequestpostId,
      'Username':username,
      'Price Status':pstatus,
      'OwnerID':currentUser!.uid,
      'Timestamp':timestamp,
      'Description':description,
      'Location':location,
      'Requested':requested,
      'Requested as':requested_as,
    });


  }

  ///Add post to timeline
  addPostTimeline({String? username, String? description,
    String? pstatus,String? timestamp,String? location,String? requested,String? requestedId, String? requested_as}){
    requestsTimelineRef
        .doc(RequestpostId)
        .set({
      'RequestId':RequestpostId,
      'Username':username,
      'Price Status':pstatus,
      'OwnerID':currentUser!.uid,
      'Timestamp':timestamp,
      'Description':description,
      'Location':location,
      'Requested':requested,
      'Requested as':requested_as,
    });


  }







  handleSubmit()async{
    final DateTime timestamp= DateTime.now();
    setState((){
      isUploading=true;
    });
    if (_formkey.currentState!.validate()){
      createFirestorePostDetails(
        username: _username,
        pstatus: _status,
        timestamp:timestamp.toString(),
        location:_location,
        description:_description,
        requested: result1,
        requested_as: result,
      );
      addPostTimeline(
        username: _username,
        pstatus: _status,
        timestamp:timestamp.toString(),
        location:_location,
        description:_description,
        requested: result1,
        requested_as: result,
      );
    }else{
      isUploading=false;
    }
    Navigator.pop(context);

  }



  late bool IsOrgInd=widget.isOrgInd;
  String result="";
  String result1="";
  String error="";
  bool value1 =false;
  bool value2 =false;
  bool value3 =false;
  bool value4 =false;




  String? _username;
  String? _userImage;
  late String _location;
  late String _description;
  late String _status;

  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    print (result);
    print (result1);
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading:  GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              child: Text('Cancel',style:TextStyle(
                  color: Colors.green
              )),
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.orange),
          centerTitle: true,
          title: Text('Request',style:TextStyle(
              color: Colors.orange
          )),
          actions: [
            ///Post button
            RaisedButton(
              color: Colors.green,
              onPressed:isUploading?null: ()=> handleSubmit(),
              child:  Text('Post',
                style:  TextStyle(color: Colors.white),),

            ),
          ],
        ),

        body: IsOrgInd==true?
        SingleChildScrollView(
          child:Column(
            children: [

              isUploading? linearProgress(): SizedBox(),
              ///Image upload Container
              FutureBuilder(
                  future: _fetch(),
                  builder: (context,snapshot){
                    if (snapshot.connectionState!=ConnectionState.done)
                      return Container(
                          margin:  EdgeInsets.all(10),
                          height: size.height/4,
                          width: size.width,
                          color:Colors.grey[300],
                          child: CachedNetworkImage(
                            fit:BoxFit.fitWidth,
                            imageUrl:_userImage.toString(),
                            placeholder: (context, url) => Container(
                              margin:  EdgeInsets.all(10),
                              height: size.height/4,
                              width: size.width,
                              color:Colors.grey[300],
                              child: Center(
                                child: Icon(Icons.image),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.image_not_supported),

                          )
                      );
                    return Container(
                        margin:  EdgeInsets.all(10),
                        height: size.height/4,
                        width: size.width,
                        color:Colors.grey[300],
                        child: CachedNetworkImage(
                          fit:BoxFit.fitWidth,
                          imageUrl:_userImage.toString(),
                          placeholder: (context, url) => Container(
                            margin:  EdgeInsets.all(10),
                            height: size.height/4,
                            width: size.width,
                            color:Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.image),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.image_not_supported),

                        )
                    );

                  }),

              ///Form for content upload
              Form(
                key:_formkey,
                child: Column(
                  children: [
                     SizedBox(height: 20.0),
                    ///FutureBuilder to get Username(Last name+ First name)
                    FutureBuilder(
                        future: _fetch(),
                        builder: (context,snapshot){
                          if (snapshot.connectionState!=ConnectionState.done)
                            return CircularProgressIndicator();
                          return Padding(
                            padding:  EdgeInsets.all(8.0),
                            child: TextFormField(
                              readOnly: true,
                              initialValue:_username,
                              validator: (val)=>val!.isEmpty?'Enter your Name':null,
                              onChanged: (val){
                                setState(() => _username=val);
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.blue,
                                hintText: 'Enter your Name ',labelText: 'Username',border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),

                              ),
                              ),

                            ),
                          );

                        }),

                     SizedBox(height: 20.0),
                    ///Enter location textfield
                    Container(
                      color: Colors.grey.shade100,
                      // margin: EdgeInsets.only(left: 18,right:18),
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (val)=>val!.isEmpty?'Enter your Location':null,
                          onChanged: (val){
                            setState(() => _location=val);
                          },
                          decoration:  InputDecoration(
                            hintText: 'Enter your Location',labelText: 'Location',border:UnderlineInputBorder(

                          ),
                          ),

                        ),
                      ),
                    ),
                     SizedBox(height: 20.0),
                    ///status textfield
                    Container(
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (val)=>val!.isEmpty?'Enter your Value':null,
                          onChanged: (val){
                            setState(() => _status=val);
                          },
                          decoration:  InputDecoration(
                            hintText: 'Enter your Value',labelText: 'Status',border: UnderlineInputBorder(
                          ),
                          ),

                        ),
                      ),
                    ),
                     SizedBox(height: 20.0),
                    ///description textfield
                    Container(
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (val)=>val!.isEmpty?'Description':null,
                          onChanged: (val){
                            setState(() => _description=val);
                          },
                          decoration:  InputDecoration(
                            hintText: 'Enter description',labelText: 'Description',border: UnderlineInputBorder(
                          ),
                          ),

                        ),
                      ),
                    ),
                     SizedBox(height: 20.0),
                    //Dropdown
                     SizedBox(height: 20.0),

                  ],
                ),
              )

            ],
          ),
        ):
        SingleChildScrollView(

          child:Column(

            children: [
              ///Organization AND Individual containers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ///1st checkbox
                  Stack(
                      children:[
                        Container(
                          margin:  EdgeInsets.only(top:7),
                          height: size.height/4,
                          width: size.width/2.2,
                          color: Colors.orange,
                        ),
                        Checkbox(
                            value:value1,
                            onChanged: (newVal) {
                              setState(() {
                                value1 = !value1;
                                value2=false;
                                if(value1==true){
                                  setState((){
                                    result="Organization";
                                  });
                                }
                              });
                            })
                      ]
                  ),
                  ///2nd checkbox
                  Stack(
                      children:[
                        Container(
                          margin:  EdgeInsets.only(top:7),
                          height: size.height/4,
                          width: size.width/2.2,
                          color: Colors.blue,
                        ),
                        Checkbox(
                            value:value2,
                            onChanged: (newVal) {
                              setState(() {
                                value2 = !value2;
                                value1=false;
                                if(value2==true){
                                  setState((){
                                    result="Individual";
                                  });
                                }
                              });
                            })
                      ]
                  ),

                ],
              ),

              ///proceed when checkbox 1 is ticked
              value1==true?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ///3rd checkbox
                  Stack(
                      children:[
                        Container(
                          margin:  EdgeInsets.only(top:7),
                          height: size.height/4,
                          width: size.width/2.2,
                          color: Colors.orange,
                        ),
                        Checkbox(
                            value:value3,
                            onChanged: (newVal) {
                              setState(() {
                                value3 = !value3;
                                value4=false;
                                if(value3==true){
                                  setState((){
                                    result1="Food Items";
                                  });
                                }
                              });
                            })
                      ]
                  ),
                  ///4th checkbox
                  Stack(
                      children:[
                        Container(
                          margin:  EdgeInsets.only(top:7),
                          height: size.height/4,
                          width: size.width/2.2,
                          color: Colors.blue,
                        ),
                        Checkbox(
                            value:value4,
                            onChanged: (newVal) {
                              setState(() {
                                value4 = !value4;
                                value3=false;
                                setState((){
                                  result1="Meal";
                                });
                              });
                            })
                      ]
                  ),

                ],
              ):
              SizedBox(),


              ///proceed when checkbox 2 is ticked
              value2==true?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ///3rd checkbox
                  Stack(
                      children:[
                        Container(
                          margin:  EdgeInsets.only(top:7),
                          height: size.height/4,
                          width: size.width/2.2,
                          color: Colors.orange,
                        ),
                        Checkbox(
                            value:value3,
                            onChanged: (newVal) {
                              setState(() {
                                value3 = !value3;
                                value4=false;
                                setState((){
                                  result1="Food Items";
                                });
                              });
                            })
                      ]
                  ),
                  ///4t checkbox
                  Stack(
                      children:[
                        Container(
                          margin:  EdgeInsets.only(top:7),
                          height: size.height/4,
                          width: size.width/2.2,
                          color: Colors.blue,
                        ),
                        Checkbox(
                            value:value4,
                            onChanged: (newVal) {
                              setState(() {
                                value4 = !value4;
                                value3=false;
                                if(value4==true){
                                  setState((){
                                    result1="Meal";
                                  });
                                }
                              });
                            })
                      ]
                  ),
                ],
              ):
              SizedBox(),

              ///when all required fields are filled, display next icon
              value1==true?
              GestureDetector(
                onTap: ()async{
                  if(value3==false){
                    if(value4==false){
                      setState((){
                        error="Tick at least one";
                      });
                    }else{
                      setState(()=> IsOrgInd=true);
                    }
                  }else{
                    setState(()=> IsOrgInd=true);
                  }

                },
                child: Container(
                  margin: EdgeInsets.all(40),
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Icon(Icons.navigate_next,color: Colors.white,),
                ),
              ):SizedBox(),
              value2==true?
              GestureDetector(
                onTap: ()async {
                  if(value3==false){
                    if(value4==false){
                      setState((){
                        error="Tick at least one";
                      });
                    }else{
                      setState(()=> IsOrgInd=true);
                    }
                  }else{
                    setState(()=> IsOrgInd=true);
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(40),
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Icon(Icons.navigate_next,color: Colors.white,),
                ),
              ):SizedBox(),

              Text(error),


              ///Container for uploaded image file

              ///Form for content upload
              /* Form(
              key:_formkey,
              child: Column(
                children: [
                  ///Choose image and clear image enables only if user has uploaded a file
                  Row(
                    children: [
                      Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: Colors.green,
                          onPressed: ()=>selectImage(context),
                          child:  Text('Choose Image',
                            style: TextStyle(color: Colors.white),),

                        ),
                      ),
                       Expanded(
                          flex: 2,
                          child:  SizedBox(
                          )),
                      Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: file==null?  SizedBox():FlatButton(
                          color: Colors.transparent,
                          onPressed: ()=>clearImage(),
                          child:  Text('Clear Image',
                            style:  TextStyle(color: Colors.red),),

                        ),
                      ),
                    ],
                  ),

                   SizedBox(height: 20.0),
                  ///FutureBuilder to get Username(Last name+ First name)
                  FutureBuilder(
                      future: _fetch(),
                      builder: (context,snapshot){
                        if (snapshot.connectionState!=ConnectionState.done)
                          return  CircularProgressIndicator();
                        return Padding(
                          padding:  EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: false,
                            initialValue:_username,
                            validator: (val)=>val!.isEmpty?'Enter your Name':null,
                            onChanged: (val){
                              setState(() => _username=val);
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.blue,
                              hintText: 'Enter your Name ',labelText: 'Username',border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),

                            ),
                            ),

                          ),
                        );

                      }),

                   SizedBox(height: 20.0),
                  ///Enter location textfield
                  Container(
                    color: Colors.grey.shade100,
                    // margin: EdgeInsets.only(left: 18,right:18),
                    child: Padding(
                      padding:  EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (val)=>val!.isEmpty?'Enter your Location':null,
                        onChanged: (val){
                          setState(() => _location=val);
                        },
                        decoration:  InputDecoration(
                          hintText: 'Enter your Location',labelText: 'Location',border:UnderlineInputBorder(

                        ),
                        ),

                      ),
                    ),
                  ),
                   SizedBox(height: 20.0),
                  ///status textfield
                  Container(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding:  EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (val)=>val!.isEmpty?'Enter your Value':null,
                        onChanged: (val){
                          setState(() => _status=val);
                        },
                        decoration:  InputDecoration(
                          hintText: 'Enter your Value',labelText: 'Status',border: UnderlineInputBorder(
                        ),
                        ),

                      ),
                    ),
                  ),
                   SizedBox(height: 20.0),
                  ///description textfield
                  Container(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding:  EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (val)=>val!.isEmpty?'Description':null,
                        onChanged: (val){
                          setState(() => _description=val);
                        },
                        decoration:  InputDecoration(
                          hintText: 'Enter description',labelText: 'Description',border: UnderlineInputBorder(
                        ),
                        ),

                      ),
                    ),
                  ),
                   SizedBox(height: 20.0),
                  ///ingredients textfield
                  Container(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding:  EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (val)=>val!.isEmpty?'Ingredients/content':null,
                        onChanged: (val){
                          setState(() => _ingredients=val);
                        },
                        decoration:  InputDecoration(
                          hintText: 'Ingredients/content',labelText: 'Ingredients/content',border: UnderlineInputBorder(
                        ),
                        ),

                      ),
                    ),
                  ),
                  //Dropdown
                   SizedBox(height: 20.0),

                ],
              ),
            )*/

            ],
          ),
        )
    );



  }

}
