import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main_app/exchange_data.dart';
import 'package:main_app/mylib.dart';
import 'package:main_app/util/connection_service.dart';
import 'package:main_app/util/validators.dart';

class RegisterConfimationPage extends StatelessWidget {
  Database _db;
  bool _isSenior;

  RegisterConfimationPage(this._db, this._isSenior);

  @override
  Widget build(BuildContext context) {
    if (_isSenior) {
      final formKey = new GlobalKey<FormState>();
      TextEditingController serverFieldController = TextEditingController();
      TextEditingController tokenFieldController = TextEditingController();

      var serverField = TextFormField(
          controller: serverFieldController,
          validator: serverValidator,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
              hintText: "Server address", errorMaxLines: 3));

      var tokenField = TextFormField(
          controller: tokenFieldController,
          validator: tokenValidator,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
              hintText: "Access token", errorMaxLines: 3));

      var validate = () async {
        formKey.currentState.save();
        if (!formKey.currentState.validate()) {
          return;
        }
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                  child: SimpleDialog(children: [
                    Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait...",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ],
                    )
                  ]),
                  onWillPop: () async => false);
            });
        bool correctInformation = await ConnectionService.tryToRegisterSenior(
            serverFieldController.text, tokenFieldController.text);
        Navigator.of(context).pop();
        if (correctInformation) {
          _db.registerNewNurse(true);
          while(Navigator.of(context).canPop())
            Navigator.of(context).pop();
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return WillPopScope(
                    child: ButtonBarTheme(
                        data: ButtonBarThemeData(
                            alignment: MainAxisAlignment.center),
                        child: AlertDialog(
                          title: Text(
                            "Error",
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                              "Either the server is not responding or you have entered the details wrong. Please also check your internet connection."),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                                child: Text("OK"))
                          ],
                        )),
                    onWillPop: () async => false);
              });
        }
      };
      return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus.unfocus();
          },
          child: Scaffold(
            appBar: AppBar(title: Text("Register as a Senior Nurse")),
            body: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      ListTile(leading: Icon(Icons.web), title: serverField),
                      SizedBox(height: 20),
                      ListTile(leading: Icon(Icons.info), title: tokenField),
                      SizedBox(height: 20),
                      longButtons("Validate", validate)
                    ],
                  ),
                )
              ],
            ),
          ));
    } else {
      return ReceiveDataStartPage(_db);
    }
  }
}
