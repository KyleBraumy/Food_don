
import 'package:sates/models/usermods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sates/startup/startpage.dart';

import '../main_pages/home.dart';


class Wrapper extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final user = Provider.of<USER?>(context);
    //Either select or log in page
    if (user == null){
      return Startpage();
    }else {
      return home();
    }
  }
}
