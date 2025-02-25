import 'package:flutter/material.dart';
import 'package:main_app/MedicationCalculatorWidget.dart';
import 'package:main_app/data/smart_widget.dart';
import 'mylib.dart';

class MedCalcPage extends SmartWidget {
  MedCalcPage(Database db) : super(db);

  @override
  Widget build(BuildContext context) {
    return Scaffold(



          drawer: MyDrawerStateful(super.getDb()),


        body: Center (

         child: MedicationCalculatorWidget(),
    ),
    );
  }
}