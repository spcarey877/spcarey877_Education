import 'package:flutter/material.dart';
import 'package:main_app/data/smart_widget.dart';
import 'package:pews_module/PewsCalculatorWidget.dart';
import 'mylib.dart';

class PEWsCalculator extends SmartWidget {
  PEWsCalculator(Database db) : super(db);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: MyDrawerStateful(super.getDb()),


      body: Center (

        child: PewsCalculatorWidget(),
      ),
    );
  }
}