
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_app/PEWsCalculator.dart';
import 'package:main_app/data/login_state.dart';
import 'package:main_app/data/login_state_widget.dart';
import 'package:main_app/data/smart_widget.dart';
import 'package:main_app/patients_page.dart';
import 'package:provider/provider.dart';

import 'exchange_data.dart';
import 'mylib.dart';

bool isIos;

void main() async {
  Database _db = Database();
  await _db.init();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<LoginState>(
      create: (final BuildContext context) {
        isIos = Theme.of(context).platform == TargetPlatform.iOS;
        return LoginState(_db.hasAcknowledged());
      },
    )
  ], child: MaterialApp(home: LoginStateWidget(MyApp(_db)))));
}

class MyApp extends SmartWidget {
  MyApp(Database db) : super(db);

  @override
  Widget build(BuildContext context) {
    //final navigatorKey = GlobalKey<NavigatorState>();
    /*Provider.of<LoginState>(context, listen: false).navigatorKey = navigatorKey;
    Provider.of<LoginState>(context, listen: false).addListener(() {
      if (Provider.of<LoginState>(context, listen: false).currentState == state.LoggedIn)
        {
          return;
        }
      while(navigatorKey.currentState.canPop())
        navigatorKey.currentState.pop();

      navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => Login(_db)));
    });*/
    // return Consumer<LoginState>(
    //     builder: (final BuildContext context, final LoginState loginState, final Widget child){
    //       return MaterialApp(
    //         //navigatorKey: navigatorKey,
    //         title: 'Flutter Demo',
    //         theme: ThemeData(
    //           primarySwatch: Colors.blue,
    //           visualDensity: VisualDensity.adaptivePlatformDensity,
    //         ),
    //         home: MyHomePage(_db, title: 'Flutter Demo Home Page');
    //         );
    // });
    return MyHomePage(super.getDb(), title: 'Home Page');
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  Database _db;

  MyHomePage(this._db, {Key key, this.title});


  @override
  Widget build(BuildContext context) {
    ElevatedButton medCalcButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                MedCalcPage(_db)));
      },
      child: Row(children: <Widget>[
        const SizedBox(height: 200),
        Container(
          width: 200,
          child: Text(
            'Medication Calculator',
            style: TextStyle(fontSize: 30),
            maxLines: 2,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Icon(
          Icons.calculate_outlined,
          color: Colors.red,
          size: 100,
        ),
      ]),
    );

    ElevatedButton patientsButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                PatientsPage(this._db)));
      } ,
      child: Row(children: <Widget>[
        const SizedBox(height: 200),
        Container(
          width: 200,
          child: const Text('Patients',
              style: TextStyle(fontSize: 30)),
        ),
        const SizedBox(
          width: 25,
        ),
        Icon(
          Icons.people,
          color: Colors.red,
          size: 100,
        ),
      ]),
    );

    ElevatedButton educationButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                EducationalVideos(_db)));
      } ,
      child: Row(children: <Widget>[
        const SizedBox(height: 200),
        Container(
          width: 200,
          child: const Text('Education and Guidelines',
              style: TextStyle(fontSize: 30)),
        ),
        const SizedBox(
          width: 25,
        ),
        Icon(
          Icons.video_collection_outlined,
          color: Colors.red,
          size: 100,
        ),
      ]),
    );

    ElevatedButton pewsCalcButon = ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                LoginStateWidget(PEWsCalculator(_db))));
      },
      child: Row(children: <Widget>[

        const SizedBox(height: 200),
        Container(
          width: 200,
          child: const Text('PEWS Calculator',
              style: TextStyle(fontSize: 30)),
        ),
        const SizedBox(
          width: 25,
        ),
        Icon(
          Icons.view_list,
          color: Colors.red,
          size: 100,
        ),
      ]),
    );

    Offstage authorizeButton = Offstage(
      offstage : !_db.isNurseSenior(),
      child : ElevatedButton(
        onPressed: () {
          const MethodChannel _channel =
          const MethodChannel('ble-data/send');
          _channel.invokeMethod("authorize", {"json": "TEST"});
          while (Navigator.canPop(context)) Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  SendDataPage(true)));
        },
        child: Row(children: <Widget>[

        const SizedBox(height: 200),
        Container(
        width: 200,
        child: const Text('Authorize Nurse',
        style: TextStyle(fontSize: 30)),
        ),
        const SizedBox(
        width: 25,
        ),
        Icon(
        Icons.login,
        color: Colors.red,
        size: 100,
        ),
        ]),
        )
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: MyDrawerStateful(_db),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            const SizedBox(height: 25),
            medCalcButton,
            const SizedBox(height: 25),
            patientsButton,
            const SizedBox(height: 25),
            educationButton,
            const SizedBox(height: 25),
            authorizeButton,
            const SizedBox(height: 25),
            pewsCalcButon
          ],
        ),
      ),
    );
  }
}
