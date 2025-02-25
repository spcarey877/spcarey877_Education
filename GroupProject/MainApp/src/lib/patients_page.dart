import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main_app/data/patient.dart';
import 'package:main_app/database.dart';
import 'package:main_app/myDrawer.dart';
import 'package:main_app/patient_panel.dart';
import 'package:main_app/register_patient.dart';
import 'package:main_app/util/widgets.dart';


class PatientsPage extends StatefulWidget {
  Database _db;

  PatientsPage(this._db);

  @override
  State<StatefulWidget> createState() {
    return _PatientsPageState(_db);
  }
}

class _PatientsPageState extends State<PatientsPage> {
  Database _db;

  _PatientsPageState(this._db);

  @override
  Widget build(BuildContext context) {
    List<Patient> allPatients = _db.getAllPatients();
    allPatients.sort((p, other) => p.getDisplayableId().compareTo(other.getDisplayableId()));

    var openPatientPage = (String patientId) async {
      final String deleted = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PatientPanel(_db, patientId)));
      if (deleted != null && deleted.isNotEmpty && deleted == "yes") {
        setState(() {
          allPatients = _db.getAllPatients();
        });
      }
    };

    var widget = Scaffold(
      appBar: AppBar(title: Text("Patients List"), actions: [
        IconButton(
            onPressed: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => RegisterPatient(_db)))
                  .then(
                      (
                      value) //Avoid wrapping into LoginStateWidget because of setState
                  {
                    try {
                      setState(() {
                        allPatients = _db.getAllPatients();
                      });
                    } catch (error) {
                      //Ignore error since it is caused by setState being called while auto logging out
                    }
                  });
            },
            icon: Icon(Icons.person_add)),
      ]),
      drawer: MyDrawerStateful(_db),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40.0),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var patient in allPatients)
              longButtons(patient.getDisplayableId().toUpperCase(),
                      () => {openPatientPage(patient.getPatientId())})
          ]),
        ),
      ),
    );
    return widget;
  }
}
