import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:sates/models/Database.dart';
import 'package:sates/models/usermods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../secondary_pages/edit_profile.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
class AuthService{

 final DateTime timestamp=DateTime.now();
 USER? _userFromUser(User? user){
    return user !=null ? USER(uid: user.uid) : null;
  }

  Stream<USER?> get user{
   return _auth.authStateChanges()
   .map(_userFromUser);
  }


  //Sign in with email&password
  Future signInWithEmailandPassword(String email,String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }


  //Register with email&password
  Future registerWithEmailandPassword(String email,String password,
      ) async{
    try{
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email,
        password: password,

    );
    User? user = result.user;
    //String profilePhotoUrl=await uploadImage(file);
    //create a document for user
    await DatabaseService(uid:user!.uid).createUserInfo(email);
    return _userFromUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign out
 Future signOut() async {
   try {
     return await _auth.signOut();
   }catch(e){
     print(e.toString());
     return null;
   }
 }
/* String profilepicId=Uuid().v4();
 Future<String> uploadImage(imageFile) async {
   UploadTask uploadTask =
   storageRef.child('post_$profilepicId.jpg').putFile(imageFile);
   TaskSnapshot storageSnap = await uploadTask;
   String downloadUrl = await storageSnap.ref.getDownloadURL();
   return downloadUrl;
 }*/

}
