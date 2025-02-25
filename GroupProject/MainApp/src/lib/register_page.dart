import 'package:flutter/material.dart';
import 'package:main_app/register_confirmation_page.dart';
import 'mylib.dart';


class RegisterPanel extends StatelessWidget {
  Database _db;

  RegisterPanel(this._db);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Phone Registration"),
        ),
        body: Center(
          child: ListView(padding: const EdgeInsets.all(10),
              //List view gives a scrollable collumn

              children: <Widget>[
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              RegisterConfimationPage(_db, false)));
                    });
                  },
                  child: Row(children: <Widget>[
                    const SizedBox(height: 200),
                    Container(
                      width: 200,
                      child: Text(
                        'Register as a Nurse',
                        style: TextStyle(fontSize: 30),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.how_to_reg_outlined,
                      size: 100,
                    ),
                  ]),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            RegisterConfimationPage(_db, true)));
                  },
                  child: Row(children: <Widget>[
                    const SizedBox(height: 200),
                    Container(
                      width: 200,
                      child: Text(
                        'Register as a Senior Nurse',
                        style: TextStyle(fontSize: 30),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.how_to_reg_rounded,
                      size: 100,
                    ),
                  ]),
                )
              ]),
        ));
  }
}
