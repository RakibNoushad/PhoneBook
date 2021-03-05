import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:phone_book/theme/routes.dart';
import 'package:phone_book/views/opening_screen.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef =
FirebaseDatabase.instance.reference().child("users");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phone Book',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        accentColor: Colors.redAccent,
      ),
      routes: AppRoutes.define(),
      home: OpeningView(),
    );
  }
}