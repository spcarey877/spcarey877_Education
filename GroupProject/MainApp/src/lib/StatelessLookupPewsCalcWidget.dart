import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:main_app/LookupPewsCalculatorWidget.dart';
import 'package:main_app/data/smart_widget.dart';
import 'package:main_app/database.dart';

class StatelessLookupPewsCalcWidget extends SmartWidget{
  Database db;
  String patientId;

  StatelessLookupPewsCalcWidget(Database db, String patientId) : super(db) {
    this.db = db;
    this.patientId = patientId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : LookupPewsCalculatorWidget.initWithPatient(db, patientId)
    );
  }

}