import 'package:flutter/material.dart';
import 'package:sates/startup/firstpage.dart';
import 'package:sates/startup/startpage.dart';
import 'package:sates/authentication/auth.dart';
import 'package:sates/models/usermods.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(Foodshare());
}


class Foodshare extends StatefulWidget {
  @override
  State<Foodshare> createState() => _FoodshareState();
}

class _FoodshareState extends State<Foodshare> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<USER?>.value(
      value: AuthService().user,
      initialData: null,

      child: MaterialApp(
        theme: ThemeData(
         primaryColor: Colors.green,
          accentColor:Colors.orange,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/start',
        routes: {
          '/start':(context) => Firstpage(),
        },
      ),
    );
  }
}
