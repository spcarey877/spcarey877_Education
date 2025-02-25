import 'package:checkbox_formfield/checkbox_list_tile_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main_app/StatelessLookupPewsCalcWidget.dart';
import 'package:main_app/StatelessMedCalcPatientWidget.dart';
import 'package:main_app/StatelessMultiGraphWidget.dart';
import 'package:main_app/data/login_state_widget.dart';
import 'package:main_app/data/patient.dart';
import 'package:main_app/database.dart';
import 'package:main_app/mylib.dart';
import 'package:main_app/util/validators.dart';
import 'package:pews_module/PewsCalculatorWidget.dart';
import 'package:pews_module/PewsEscalation.dart';

import 'data/pews_models.dart';

class PatientPanel extends StatefulWidget {
  Database _db;
  String _patientId;

  PatientPanel(this._db, this._patientId);

  @override
  State<StatefulWidget> createState() {
    return _PatientPanelState(_db, _patientId);
  }
}

class _PatientPanelState extends State<PatientPanel> {

  Database _db;
  String _patientId;
  String _displayableId;
  bool _newborn;
  int _age;
  int _recentPews;
  String _escalation;

  _PatientPanelState(this._db, this._patientId) {
    Patient _thisPatient = _db.getPatient(_patientId);
    this._age = _thisPatient.getAge();
    this._newborn = _thisPatient.getIsNewborn();
    this._displayableId = _thisPatient.getDisplayableId().toUpperCase();
    if (_thisPatient
        .getPatientData()
        .isNotEmpty) {
      Pews _thisPews = _thisPatient
          .getPatientData()
          .reduce((p1, p2) => p1.time.isBefore(p2.time) && p2.isCompleted ? p2 : p1);
      this._recentPews =_thisPews.isCompleted ? _thisPews.totalScore : -1;
      if (_recentPews == -1) {
        _escalation = "";
      }
      else {
        this._escalation =
            PewsEscalation.pewsEsc[_recentPews > 7 ? 7 : _recentPews][0] +
                " observations";
      }
    } else {
      _recentPews = -1;
      _escalation = "";
    }
  }

  @override
  void setState(fn) {
    Patient _thisPatient = _db.getPatient(_patientId);
    if (_thisPatient
        .getPatientData()
        .isNotEmpty) {
      Pews _thisPews = _thisPatient
          .getPatientData()
          .reduce((p1, p2) => p1.time.isBefore(p2.time) && p2.isCompleted ? p2 : p1);
      this._recentPews =_thisPews.isCompleted ? _thisPews.totalScore : -1;
      if (_recentPews == -1) {
        _escalation = "";
      }
      else {
        this._escalation =
            PewsEscalation.pewsEsc[_recentPews > 7 ? 7 : _recentPews][0] +
                " observations";
      }
    } else {
      _recentPews = -1;
      _escalation = "";
    }
    super.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var openPewsCalc = () async {
      await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) =>
              LoginStateWidget(
                  StatelessLookupPewsCalcWidget(_db, _patientId))));
      setState(() { });
    };

    var openMedCalc = () {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) =>
              LoginStateWidget(
                  StatelessMedCalcPatientWidget(_db, _patientId))));
    };

    var openPewsGraph = () {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) =>
              LoginStateWidget(StatelessMultiGraphWidget(_db, _patientId))));
    };

    var deleteButton = () {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ButtonBarTheme(
                data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
                child: AlertDialog(
                  title: Text("Are you sure you want to delete this patient?"),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.green)),
                      child: Text(
                        'YES',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        _db.removePatient(_patientId);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop("yes");
                      },
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.red)),
                      child: Text('NO', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
          });
    };

    var changeAge = () {
      bool _checkboxValue = _newborn;
      TextEditingController _ageController = TextEditingController();

      var ageField = TextFormField(
        autofocus: false,
        keyboardType: TextInputType.number,
        validator: intValidator,
        controller: _ageController,
        decoration:
        InputDecoration(hintText: _age.toString(), errorMaxLines: 5),
      );

      var checkBoxField = CheckboxListTileFormField(
        title: Text("Newborn"),
        onSaved: (bool value) {
          _checkboxValue = value;
        },
        initialValue: _newborn,
      );

      final _formKey = new GlobalKey<FormState>();

      var updateAge = () {
        _formKey.currentState.save();
        if (_formKey.currentState.validate()) {
          Patient thisPatient = _db.getPatient(_patientId);
          thisPatient.setAge(int.parse(_ageController.text));
          thisPatient.setIsNewborn(_checkboxValue);
          _db.putPatient(thisPatient);
          _db.putUncommittedPatient(thisPatient).then((v) {
            Navigator.of(context).pop();
            super.setState(() {
              _age = int.parse(_ageController.text);
              _newborn = _checkboxValue;
            });
          });
        }
      };

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ButtonBarTheme(
                data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
                child: AlertDialog(
                  title: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ListTile(leading: Text("Age"), title: ageField),
                        checkBoxField
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.green)),
                      child:
                      Text('UPDATE', style: TextStyle(color: Colors.white)),
                      onPressed: updateAge,
                    )
                  ],
                ));
          });
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_displayableId),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: deleteButton)
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        children: [
          Column(children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    )
                  ]),
              padding: EdgeInsets.all(20),
              child: Column(children: [
                SelectableText(
                  "You are seeing information for patient",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SelectableText(_displayableId,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
              ]),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    )
                  ]),
              padding: EdgeInsets.all(20),
              child: Column(children: [
                SelectableText("Age",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ListTile(
                  title: SelectableText(
                      _newborn == false
                          ?
                      "The patient is " + _age.toString() + " years old"
                          : "This is a newborn patient",
                      textAlign: TextAlign.center),
                  trailing:
                  IconButton(icon: Icon(Icons.edit), onPressed: changeAge),
                )
              ]),
            ),
            SizedBox(height: 40),
            Offstage(
              offstage: _recentPews < 0,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      )
                    ]),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      child: SelectableText(
                        "Most Recent PEWS:",
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                    ),
                    Container(
                        child: ColoredBox(
                          color: PewsCalculatorWidget.pewsToColor(
                              this._recentPews),
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: SelectableText(_recentPews.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 60),
                              onTap: openPewsGraph,)
                          ),
                        )
                    ),
                    Container(
                        child: SelectableText(
                            this._escalation,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                        )
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    )
                  ]),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SelectableText("Actions",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  SizedBox(
                    height: 10,
                  ),
                  longButtons("View graph", openPewsGraph),
                  // Add button to PEWS Graph
                  longButtons("Calculate PEWS", openPewsCalc),

                  longButtons("Medication Calculator", openMedCalc)
                ],
              ),
            )
          ])
        ],
      ),
    );
  }
}
