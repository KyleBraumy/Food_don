import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../sidebar.dart';


AppBar header(context,{ required String titleText, removeBackButton = false}){
  return AppBar(
    automaticallyImplyLeading: removeBackButton? false:true,
    backgroundColor: Colors.white,
    title: Text(titleText,
      style: TextStyle(
        color: Colors.green,
        letterSpacing: 4,
      ),),
    centerTitle: true,
    iconTheme: IconThemeData(
        color: Colors.green,
    ),
  );
}
