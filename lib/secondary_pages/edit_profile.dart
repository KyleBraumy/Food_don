import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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




class EditProfileImage extends StatefulWidget {
String? Username;
String? imFile;
EditProfileImage({this.imFile,this.Username});

  @override
  State<EditProfileImage> createState() => _EditProfileImageState(

  );
}

class _EditProfileImageState extends State<EditProfileImage> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final storageRef = FirebaseStorage.instance.ref('Images');
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final timelineRef = FirebaseFirestore.instance.collection('postsTimeline');

  final _formkey= GlobalKey<FormState>();
  bool isUploading=false;
  String postId=Uuid().v4();
  final currentUser= FirebaseAuth.instance.currentUser;
/*
  _fetch()async{
    if (currentUser!.uid!=null)
      await usersRef
          .doc(currentUser!.uid)
          .get()
          .then((ds){
        _username=ds.data()!['Username'];
        print(_username);
      }).catchError((e){
        print(e);
      });
  }
*/

  File? file;
loadPhotoUrl()async{
  await widget.imFile;
  if (widget.imFile!=null){
    return  CachedNetworkImage(
      imageUrl:widget.imFile.toString(),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
  handleTakePhoto(context)async{
    Navigator.pop(context);
    var image= await ImagePicker.platform.pickImage(source:ImageSource.camera);
    setState((){
      file=File(image!.path);
    });
  }
  handleChooseFromGallery(context)async{
    Navigator.pop(context);
    var image= await ImagePicker.platform.pickImage(source:ImageSource.gallery);
    setState((){
      file=File(image!.path);
    });
  }
  clearImage(){
    setState((){
      file=null;
    });
  }
  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Select Image'),
            children: [
              SimpleDialogOption(
                child:Text('Photo with Camera'),
                onPressed:()=>handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child:Text('Choose image from Gallery'),
                onPressed:()=>handleChooseFromGallery(context),
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

//form values
  String? _username;

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
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
    storageRef.child('post_$postId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  updateProfileImage({String? PhotoUrl}){
    usersRef
        .doc(currentUser!.uid)
        .update({
      'ProfilePhotoUrl':PhotoUrl,
    });


  }
  handleSubmitP()async{
    setState((){
      isUploading=true;
    });

    await compressImage();
    String profilePhotoUrl=await uploadImage(file);
    updateProfileImage(
      PhotoUrl:profilePhotoUrl,
    );
   setState((){
      isUploading=false;
      postId=Uuid().v4();
    });

  }

  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        title:Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 30,
            ),
            CustomText8('Change Profile Photo',
            ),
          ],
        ),
        toolbarHeight:80,
        backgroundColor: Colors.white,
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        child:Column(
          children: [
            isUploading? linearProgress():SizedBox(),
            file==null ? ( widget.imFile==null? SizedBox() :
            CachedNetworkImage(
              imageUrl:widget.imFile.toString(),
              imageBuilder: (context, imageProvider) => Container(
                height: 170,
                width: 200,
                margin:  EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border:Border.all(
                      width: 1,
                      color: Colors.orange
                  ),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )):
            Container(
              height: 170,
              width: 200,
              margin:  EdgeInsets.all(10),
              decoration: BoxDecoration(
                border:Border.all(
                    width: 1,
                    color: Colors.orange
                ),
                shape: BoxShape.circle,
                  image: DecorationImage(
                      image: FileImage(file!),
                      fit: BoxFit.fitWidth
                  ),
              ),
            ),
            ///Image upload Container
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    color: Colors.green,
                    onPressed: ()=>selectImage(context),
                    child: file==null? Text('Update Image',
                      style: TextStyle(color: Colors.white),):
                    Text('Change Image',
                      style: TextStyle(color: Colors.white),)

                  ),
                ),
                Expanded(
                    flex: 2,
                    child: SizedBox(
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    color: Colors.transparent,
                    onPressed: ()=>clearImage(),
                    child: Text('Clear Image',
                      style: TextStyle(color: Colors.red),),

                  ),
                ),
              ],
            ),
            Form(
              key:_formkey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left:15,top:3,right: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.green.shade50,
                    ),
                    child: Padding(
                          padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              readOnly: false,
                              initialValue:widget.Username,
                              decoration: InputDecoration(
                                border:InputBorder.none
                              ),

                            ),
                          ),
                  ),
                  SizedBox(height: 20.0),
                  ///Dropdown
                  SizedBox(height: 20.0),
                  ///Post button
                  file==null?
                  SizedBox():
                  RaisedButton(
                    color: Colors.green,
                    onPressed:isUploading?null: ()=> handleSubmitP(),
                    child: Text('Done',
                      style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

  }

}




class EditProfileBackImage extends StatefulWidget {
  String? Username;
  String? imFile;
  EditProfileBackImage({this.imFile,this.Username});

  @override
  State<EditProfileBackImage> createState() => _EditProfileBackImageState();
}

class _EditProfileBackImageState extends State<EditProfileBackImage> {
  final storageRef = FirebaseStorage.instance.ref('Images');
  final _formkey= GlobalKey<FormState>();
  bool isUploading=false;
  String postId=Uuid().v4();
  final currentUser= FirebaseAuth.instance.currentUser;
/*
  _fetch()async{
    if (currentUser!.uid!=null)
      await usersRef
          .doc(currentUser!.uid)
          .get()
          .then((ds){
        _username=ds.data()!['Username'];
        print(_username);
      }).catchError((e){
        print(e);
      });
  }
*/

  File? file;
  loadPhotoUrl()async{
    await widget.imFile;
    if (widget.imFile!=null){
      return  CachedNetworkImage(
        imageUrl:widget.imFile.toString(),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }
  }
  handleTakePhoto(context)async{
    Navigator.pop(context);
    var image= await ImagePicker.platform.pickImage(source:ImageSource.camera);
    setState((){
      file=File(image!.path);
    });
  }
  handleChooseFromGallery(context)async{
    Navigator.pop(context);
    var image= await ImagePicker.platform.pickImage(source:ImageSource.gallery);
    setState((){
      file=File(image!.path);
    });
  }
  clearImage(){
    setState((){
      file=null;
    });
  }
  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Select Image'),
            children: [
              SimpleDialogOption(
                child:Text('Photo with Camera'),
                onPressed:()=>handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child:Text('Choose image from Gallery'),
                onPressed:()=>handleChooseFromGallery(context),
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

//form values
  String? _username;

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
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
    storageRef.child('post_$postId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  updateProfileImage({String? PhotoUrl}){
    usersRef
        .doc(currentUser!.uid)
        .update({
      'BackProfilePhotoUrl':PhotoUrl,
    });


  }
  handleSubmitP()async{
    setState((){
      isUploading=true;
    });

    await compressImage();
    String profilePhotoUrl=await uploadImage(file);
    updateProfileImage(
      PhotoUrl:profilePhotoUrl,
    );
    setState((){
      isUploading=false;
      postId=Uuid().v4();
    });
    Navigator.pop(context);
  }
/*
  updateBackProfileImage({String? PhotoUrl}){
    usersRef
        .doc(currentUser!.uid)
        .update({
      'BackProfilePhotoUrl':PhotoUrl,
    });


  }
  handleSubmitBackP()async{
    setState((){
      isUploading=true;
    });

    await compressImage();
    String profilePhotoUrl=await uploadImage(file);
    updateProfileImage(
      PhotoUrl:profilePhotoUrl,
    );
   setState((){
      isUploading=false;
      postId=Uuid().v4();
    });

  }
*/

  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        title:Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 30,
            ),
            CustomText8('Change Cover Photo',
            ),
          ],
        ),
        toolbarHeight:80,
        backgroundColor: Colors.white,
        actions: [
          ///Post button
          file==null?
          SizedBox():
          RaisedButton(
            color: Colors.green,
            onPressed:isUploading?null: ()=> handleSubmitP(),
            child: Text('Done',
              style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child:Column(
          children: [
            isUploading? linearProgress():SizedBox(),
            file==null ? ( widget.imFile==null? SizedBox() :CachedNetworkImage(
              imageUrl:widget.imFile.toString(),
              imageBuilder: (context, imageProvider) => Container(
                height: 300,
                width: size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Container(
                height: 300,
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.green.shade50
                ),
                child: Center(child: Text('Upload a cover photo...')),

              ),
            )):
            Container(
              height: 300,
              width: size.width,

              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                image: DecorationImage(
                    image: FileImage(file!),
                    fit: BoxFit.fitWidth
                ),
              ),
            ),
            ///Image upload Container
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                      color: Colors.green,
                      onPressed: ()=>selectImage(context),
                      child: file==null? Text('Update Image',
                        style: TextStyle(color: Colors.white),):
                      Text('Change Image',
                        style: TextStyle(color: Colors.white),)

                  ),
                ),
                Expanded(
                    flex: 2,
                    child: SizedBox(
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    color: Colors.transparent,
                    onPressed: ()=>clearImage(),
                    child: Text('Remove Image',
                      style: TextStyle(color: Colors.red),),

                  ),
                ),
              ],
            ),
            Form(
              key:_formkey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left:15,top:3,right: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.green.shade50,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        readOnly: false,
                        initialValue:widget.Username,
                        decoration: InputDecoration(
                            border:InputBorder.none
                        ),

                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ///Dropdown
                  SizedBox(height: 20.0),

                ],
              ),
            )
          ],
        ),
      ),
    );

  }


}




class EditProfileDetails extends StatefulWidget {

  const EditProfileDetails({Key? key}) : super(key: key);

  @override
  State<EditProfileDetails> createState() => _EditProfileDetailsState();
}

class _EditProfileDetailsState extends State<EditProfileDetails> {

  final currentUserId= FirebaseAuth.instance.currentUser!.uid;
  final _formkey= GlobalKey<FormState>();
  final usersRef = FirebaseFirestore.instance.collection('users');
  String empty='You cannot leave this empty';
  String numbersyntax='Enter Without initial zero \n Check to make sure there are 9 digits';

  var occupation;
  var old_occupation;
  var phone2;
  var works_at;
  var ccode="+233";


  bool isChange= false;




  createUserDetails({
    String? occupation,
    String? works_at,
    String? phone2,
  }){
    usersRef.doc(currentUserId).update({
      'Occupation':occupation,
      'Works_at':works_at,
      'Contact 2':phone2,
    });
  }


handlechange()async{
    setState((){
      isLoading=true;
    });
if(_formkey.currentState!.validate()){
await old_occupation;
  await createUserDetails(occupation:occupation==null?old_occupation:occupation,
      works_at:works_at,
      phone2:phone2);

}else{
setState((){
    isLoading=true;
  });

};




}


bool? isLoading;
  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        //centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.orange
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        title:Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 30,
            ),
            CustomText8('Edit Profile',
            ),
          ],
        ),
        toolbarHeight:80,
        backgroundColor: Colors.white,
        actions: [
          isChange==true?
          GestureDetector(
                child:RaisedButton(
                  child:Text('Done',),
                     onPressed: ()async{
                       await handlechange();
                       Navigator.pop(context);
                     }),
          ):
          GestureDetector(
              child:RaisedButton(
                  child: Text('Change'),
              onPressed: () {
                    setState(()=>isChange=!isChange);
              },),
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder(
            future:usersRef.doc(currentUserId).get(),
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
              old_occupation=gUser.occupation.toString();
              return SingleChildScrollView(
                child:Container(
                  margin: EdgeInsets.all(8),
                  color: Colors.white,
                  child: Form(
                    key: _formkey,
                    child: Container(
                      color: Colors.green.withOpacity(0.1),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ///Identity section
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            margin: EdgeInsets.all(18.0),
                            child: Column(
                              children: [
                                ///Identification
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Identification',
                                    style: TextStyle(
                                        fontFamily: 'Gotham',
                                        color: Colors.orange.withOpacity(0.6),
                                        fontSize:14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2
                                    ),
                                  ),
                                ),
                                ///Second phone number
                                Container(
                                  margin: EdgeInsets.fromLTRB(30.0,0,30,20),
                                  decoration: BoxDecoration(
                                      color: Colors.green.shade100.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left:8.0),
                                    child: TextFormField(
                                      readOnly: isChange?false:true,
                                      validator:(val)=>val!.isEmpty?null:
                                      (val.length>=10 || val.length<9 ?numbersyntax:null),
                                      onChanged: (val){
                                        setState(()=>phone2=val.replaceAll(' ','')
                                        );
                                      },
                                      decoration: InputDecoration(
                                          labelText:'Contact line 2',
                                          hintText: ccode+" "+gUser.phone2.toString(),border: InputBorder.none
                                      ),

                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///employment section
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            margin: EdgeInsets.fromLTRB(18.0,0,18,18),
                            child: Column(
                              children: [
                                ///Employment title
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text('Employment',
                                    style: TextStyle(
                                        fontFamily: 'Gotham',
                                        color: Colors.orange.withOpacity(0.6),
                                        fontSize:14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2
                                    ),
                                  ),
                                ),
                                ///Occupation
                                Padding(
                                  padding: EdgeInsets.fromLTRB(30.0,10,30,10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green.shade100.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: TextFormField(
                                      onChanged: (val){
                                        setState(()=> occupation=val.replaceAll(' ','')
                                        );
                                      },

                                      decoration: InputDecoration(
                                          labelText:'Occupation',
                                          hintText: gUser.occupation.toString(),border:InputBorder.none
                                      ),
                                    ),
                                  ),
                                ),
                                ///works_at
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30.0,10,30,30),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green.shade100.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: TextFormField(

                                      onChanged: (val){
                                        setState(()=> works_at=val.replaceAll(' ','')
                                        );

                                      },

                                      decoration: InputDecoration(
                                        labelText:'Works at',
                                          hintText: gUser.works_at==null?'No info':gUser.works_at.toString(),border:InputBorder.none
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              );


            }
        ),
      ),
    );
  }
}
