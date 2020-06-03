import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';


final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {


List<dynamic> users = [];
@override
void initState() { 
  // createUser();
  super.initState();
 
}


  @override
  Widget build(context) {
    return Scaffold(
    );
  }
}
