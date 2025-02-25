import 'dart:math';

import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:flutter/material.dart';
import 'package:main_app/data/smart_widget.dart';
import 'package:main_app/database.dart';
import 'package:main_app/mylib.dart';
import 'package:main_app/util/validators.dart';

import 'data/patient.dart';

class RegisterPatient extends SmartWidget {
  Database _db;
  final _formKey = new GlobalKey<FormState>();

  RegisterPatient(this._db) : super(_db);

  @override
  Widget build(BuildContext context) {
    TextEditingController _ageController = TextEditingController();
    TextEditingController _initialsController = TextEditingController();
    String _pid = DateTime.now().microsecondsSinceEpoch.toString();
    bool _checkboxValue = false;

    var ageField = TextFormField(
      autofocus: false,
      keyboardType: TextInputType.number,
      validator: intValidator,
      controller: _ageController,
      decoration: InputDecoration(hintText: "Age", errorMaxLines: 3),
    );

    var initialsField = TextFormField(
      autofocus: false,
      validator: initialsValidator,
      controller: _initialsController,
      decoration: InputDecoration(hintText: "Initials", errorMaxLines: 3)
    );

    var checkBoxField = CheckboxListTileFormField(
      title: Text("Newborn"),
      onSaved: (bool value) {
        _checkboxValue = value;
      }
    );

    var addPatient = () {
      _formKey.currentState.save();
      if (_formKey.currentState.validate()) {
        var randomizer = new Random();
        String _displayableId = _initialsController.text.toLowerCase() + (randomizer.nextInt(89999) + 10000).toString();
        Patient p = Patient(_pid, int.parse(_ageController.text), _checkboxValue, _displayableId);
        _db.putPatient(p);
        _db.putUncommittedPatient(p);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                  child: ButtonBarTheme(
                      data: ButtonBarThemeData(
                          alignment: MainAxisAlignment.center),
                      child: AlertDialog(
                          title: SelectableText.rich(
                            TextSpan(
                                text:
                                    "The patient was added successfully. Their ID is ",
                                style: TextStyle(color: Colors.black, fontSize: 25),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: _displayableId,
                                      style: TextStyle(color: Colors.green))
                                ]),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            )
                          ])),
                  onWillPop: () async => false);
            });
      }
    };

    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus.unfocus();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("Add new patient"),
              actions: [
                new IconButton(icon: Icon(Icons.save), onPressed: addPatient)
              ],
            ),
            body: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.only(top: 40.0, left: 5.0, right: 5.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.person),
                            title: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: SelectableText(_pid),
                            ),
                          ),
                          ListTile(leading: Icon(Icons.info), title: ageField),
                          ListTile(leading: Icon(Icons.account_circle_outlined), title: initialsField,),
                          checkBoxField,
                          Padding(padding: EdgeInsets.only(bottom: 15)),
                          ElevatedButton(
                              onPressed: addPatient, child: Text("Save"))
                        ],
                      ),
                    )))));
  }
}
