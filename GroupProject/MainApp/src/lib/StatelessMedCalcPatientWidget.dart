import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main_app/MedicationCalculatorWidget.dart';
import 'package:main_app/database.dart';

import 'data/smart_widget.dart';

class StatelessMedCalcPatientWidget extends SmartWidget {
  Database _db;
  String _patientId;
  StatelessMedCalcPatientWidget(Database db, String patientId) : super(db){
    _db = db;
    _patientId = patientId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MedicationCalculatorWidget.initWithAge(_db, _patientId)
    );
  }
}