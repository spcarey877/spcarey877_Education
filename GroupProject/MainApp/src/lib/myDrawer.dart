import 'package:flutter/material.dart';
import 'package:main_app/exchange_data.dart';
import 'package:main_app/patients_page.dart';
import 'package:main_app/register_page.dart';
import 'package:main_app/util/channels.dart';
import 'PEWsCalculator.dart';
import 'mylib.dart';


class MyDrawerStateful extends StatefulWidget {
  Database _db;

  MyDrawerStateful(this._db);

  @override
  State<StatefulWidget> createState() {
    return MyDrawer(_db);
  }

}

class MyDrawer extends State<MyDrawerStateful> {
  Database _db;

  MyDrawer(this._db);

  @override
  Widget build(BuildContext context) {
    bool isRegistered = _db.isRegistered();

    var doNurseAuth = _db.isNurseSenior() ? ListTile(
      leading: Icon(Icons.login),
      title: Text('Authorize Nurse'),
      onTap: () {
        bleDataSend.invokeMethod("authorize", {"json": "TEST"});
        while (Navigator.canPop(context)) Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                SendDataPage(true))).then((value) {
                  bleDataSend.invokeMethod("stopAuth");
        });
      },
    ) : SizedBox();

    var doRegister = isRegistered ? SizedBox() : ListTile(
      leading: Icon(Icons.login),
      title: Text('Register Phone'),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RegisterPanel(_db))).then((value) {
          setState(() {
            isRegistered = _db.isRegistered();
            print(isRegistered);
          });
        });
      },
    );

    var doStartServer = !_db.isRegistered() ? ListTile(
      leading: Icon(Icons.login),
      title: Text('Act as server'),
      onTap: () {
        bleDataSend.invokeMethod("startBle", {"version": _db.getVersion(), "json": _db.exportJson()});
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  SendDataPage(false)));
        });
      },
    ) : SizedBox();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Main Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Home'),
            onTap: () {
              while (Navigator.canPop(context)) Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MyApp(this._db)));
            },
          ),
          ListTile(
            leading: Icon(Icons.calculate_outlined),
            title: Text('Medication Calculation'),
            onTap: () {
              while (Navigator.canPop(context)) Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MedCalcPage(this._db)));
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Patients'),
            onTap: () {
              while (Navigator.canPop(context)) Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      PatientsPage(this._db)));
            },
          ),
          ListTile(
            leading: Icon(Icons.video_collection_outlined),
            title: Text('Education and Guidelines'),
            onTap: () {
              while (Navigator.canPop(context)) Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      EducationalVideos(this._db)));
            },
          ),
          doNurseAuth,
          ListTile(
            leading: Icon(Icons.view_list),
            title: Text('PEWS Calculator'),
            onTap: ( ) {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PEWsCalculator(this._db) ));
            },
          ),
          doRegister,
          doStartServer
        ],
      ),
    );
  }
}
