
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:async';


class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
      'users');
  final CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
  final CollectionReference chatsRef = FirebaseFirestore.instance.collection(
      'chats');

  //final CollectionReference userrecordscollection= FirebaseFirestore.instance.collection('user_records');

  Future createUserDetails(String ID,
      var timestamp,String email,String profilePhotoUrl,
      String bio,String lname,String fName,String occupation,
      String address,String identify_as,String? works_at,String street_name,
      String phone1,String? phone2, String city
      ) async {
    return await usersRef.doc(uid).set({
      'Id':ID,
      'Timestamp':timestamp,
      'Email':email,
      'ProfilePhotoUrl':profilePhotoUrl,
      'BackProfilePhotoUrl':"",
      'Bio':bio,
      'Address':address,
      'First Name':fName,
      'Last Name':lname,
      'Occupation':occupation,
      'Identify_as':identify_as,
      'No_ppl_rated':0,
      'Rating':"0.0",
      'Rating_value':"0.0",
      'Works_at':works_at,
      'Street name':street_name,
      'City':city,
      'Contact 1':phone1,
      'Contact 2':phone2,
    });
  }


  Future createUserInfo(String email,
      ) async {
    return await usersRef.doc(uid).set({
      'Id':uid,
      'Email':email,
      'First Name':null,
      'Last Name':null,
    });
  }


}