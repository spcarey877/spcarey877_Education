import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:main_app/data/smart_widget.dart';

import 'MultipleGraphWidget.dart';
import 'database.dart';

class StatelessMultiGraphWidget extends SmartWidget{
  Database _db;
  String _patientId;

  StatelessMultiGraphWidget(Database db, String patientId) : super(db){
    _db = db;
    _patientId = patientId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MultipleGraphWidget.initWithPatient(_db, _patientId)
    );
  }
}