import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:main_app/data/login_state.dart';
import 'package:main_app/mylib.dart';

import 'package:provider/provider.dart';

class TermsAndConditions extends StatefulWidget {
  Database _db;

  TermsAndConditions(this._db);

  @override
  State<StatefulWidget> createState() {
    return _TermsState(_db);
  }
}

class _TermsState extends State<TermsAndConditions> {
  Database _db;

  _TermsState(this._db);

  @override
  Widget build(BuildContext context) {
    var openTermsAndConditions = () {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => TermsContent()));
    };

    var moveToApp = () {
      _db.acknowledged();
      Provider.of<LoginState>(context, listen: false).updateState();
    };

    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Privacy Policy",
        textAlign: TextAlign.center,
      )),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40.0),
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
                  offset: Offset(0, 3), // changes position of shadow
                )
              ]),
          padding: EdgeInsets.all(20),
          child: Column(children: [
            SelectableText(
              "This app provides guidelines as aids to clinical practice, but it is the responsibility of every clinician to ensure safe practice in their own environment.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 50,
            ),
            SelectableText(
              "Terms & Conditions",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
              onTap: openTermsAndConditions,
            ),
            SizedBox(height: 20),
            longButtons("Agree", moveToApp)
          ]),
        ),
      ),
    );
  }
}

class TermsContent extends StatelessWidget {
  Future<String> getSource() async {
    String terms = await rootBundle.loadString("lib/util/terms.json");
    return terms;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getSource(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            List<dynamic> jsonData = json.decode(snapshot.data);
            return Scaffold(
              appBar: AppBar(
                  title: Text(
                "Privacy Note",
                textAlign: TextAlign.center,
              )),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(10),
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
                          offset: Offset(0, 3), // changes position of shadow
                        )
                      ]),
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    for (var policy in jsonData)
                      if (policy["heading"] != null &&
                          policy["heading"].length != 0)
                        Column(
                          children: [
                            SelectableText(
                              policy["heading"],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            SelectableText(policy["content"],
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 14))
                          ],
                        )
                      else
                        SelectableText(policy["content"],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14))
                  ]),
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
