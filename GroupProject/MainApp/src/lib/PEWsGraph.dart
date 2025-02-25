import 'package:flutter/material.dart';
import 'mylib.dart';

class PEWsGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("PEW's graph"),
        ),


        drawer: MyDrawerStateful(null),


        body: Center (

         child: const Text('This is where the PEW\'s graph will be.'),
    ),
    );
  }
}