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



final FirebaseAuth auth =FirebaseAuth.instance;
final usersRef = FirebaseFirestore.instance.collection('users');
final storageRef = FirebaseStorage.instance.ref('Images');
final postsRef = FirebaseFirestore.instance.collection('posts');
final timelineRef = FirebaseFirestore.instance.collection('postsTimeline');

class EditProfileImage extends StatefulWidget {
String? Username;
String? imFile;
EditProfileImage({this.imFile,this.Username});

  @override
  State<EditProfileImage> createState() => _EditProfileImageState(

  );
}

class _EditProfileImageState extends State<EditProfileImage> {

  final _formkey= GlobalKey<FormState>();
  bool isUploading=false;
  String postId=Uuid().v4();
  final currentUser= auth.currentUser;
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
      appBar: header(context, titleText: 'Make a Post'),
      body: SingleChildScrollView(
        child:Column(
          children: [
            isUploading? linearProgress():SizedBox(),
            file==null ? ( widget.imFile==null? SizedBox() : Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.green,
              height: MediaQuery.of(context).size.height/4,
              child: CachedNetworkImage(
                fit: BoxFit.fitWidth,
                imageUrl:widget.imFile.toString(),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            )):
                Container(
                  height: size.height/4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(file!),
                      fit: BoxFit.fitWidth
                    )
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
                  SizedBox(height: 20.0),
                  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: false,
                            initialValue:widget.Username,
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
  /*  Scaffold(
      appBar: header(context, titleText: 'Make a Post'),
      body: SingleChildScrollView(
        child:Column(
          children: [
            isUploading? linearProgress():Text(''),
            //Image upload Container

            Form(
              key:_formkey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: Colors.green,
                          onPressed: ()=>selectImage(context),
                          child: Text('Change Image',
                            style: TextStyle(color: Colors.white),),

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
                  SizedBox(height: 20.0),
                 Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: false,
                            initialValue:widget.Username,
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
                        ),
                  SizedBox(height: 20.0),
                  //Dropdown
                  SizedBox(height: 20.0),
                  //Post button
                  RaisedButton(
                    color: Colors.green,
                    onPressed:isUploading?null: ()
                   async {
                      await handleSubmitP();
                      Navigator.pop(context);
                    },

                    child: Text('Post',
                      style: TextStyle(color: Colors.white),),

                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
*/
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
  final _formkey= GlobalKey<FormState>();
  bool isUploading=false;
  String postId=Uuid().v4();
  final currentUser= auth.currentUser;
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
      appBar: header(context, titleText: 'Make a Post'),
      body: SingleChildScrollView(
        child:Column(
          children: [
            isUploading? linearProgress():SizedBox(),
            file==null ? ( widget.imFile==null? SizedBox() : Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.green,
              height: MediaQuery.of(context).size.height/7,
              child: CachedNetworkImage(
                fit: BoxFit.fitWidth,
                imageUrl:widget.imFile.toString(),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            )):
            Container(
              height: size.height/7,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(file!),
                      fit: BoxFit.fitWidth
                  )
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
                  SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: false,
                      initialValue:widget.Username,
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
    /*  Scaffold(
      appBar: header(context, titleText: 'Make a Post'),
      body: SingleChildScrollView(
        child:Column(
          children: [
            isUploading? linearProgress():Text(''),
            //Image upload Container

            Form(
              key:_formkey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: Colors.green,
                          onPressed: ()=>selectImage(context),
                          child: Text('Change Image',
                            style: TextStyle(color: Colors.white),),

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
                  SizedBox(height: 20.0),
                 Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: false,
                            initialValue:widget.Username,
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
                        ),
                  SizedBox(height: 20.0),
                  //Dropdown
                  SizedBox(height: 20.0),
                  //Post button
                  RaisedButton(
                    color: Colors.green,
                    onPressed:isUploading?null: ()
                   async {
                      await handleSubmitP();
                      Navigator.pop(context);
                    },

                    child: Text('Post',
                      style: TextStyle(color: Colors.white),),

                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
*/
  }


}




class EditProfileDetails extends StatefulWidget {
  const EditProfileDetails({Key? key}) : super(key: key);

  @override
  State<EditProfileDetails> createState() => _EditProfileDetailsState();
}

class _EditProfileDetailsState extends State<EditProfileDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
          child: Text('Here'),
        ),
      ),
    );
  }
}
