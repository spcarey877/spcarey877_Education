import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

import 'data/patient.dart';
import 'data/pews_models.dart';
import 'database.dart';


class PewsGraphWidget extends StatefulWidget {

  List<charts.Series> _seriesList;
  bool animate = false;
  bool _is24 = false; //if true then last 48 hours
  String _patientId;
  bool _validPatientId = false;
  Database _db;


  PewsGraphWidget._withData(this._seriesList, this._validPatientId,  {this.animate});

  PewsGraphWidget();
  /// Creates a [charts.TimeSeriesChart] with sample data and no transition.

  factory PewsGraphWidget.withSampleData() {
    return new PewsGraphWidget._withData(
      _createSampleData(),
      // Disable animations for image tests.
      true,

      animate: true,

    );
  }

  PewsGraphWidget.initWithPatient(Database db, String patientId){
    _db = db;
    _patientId = patientId;
    _seriesList = getPatientData();
    _validPatientId = true;
  }



  // We need a Stateful widget to build the selection details with the current
  // selection as the state.
  @override
  State<StatefulWidget> createState() => new _PewsGraphState();

  /// Create one series with sample hard coded data.
  static List<charts.Series<Pews, DateTime>> _createSampleData() {
    final pews_data = [
      Pews.initforTesting(0, 6),
      Pews.initforTesting(1, 5),
      Pews.initforTesting(2, 3),
      Pews.fullInitForTesting(37, 120, 70, RespiratoryDistressLevels.Severe_apnoea, CNSLevels.Poor_Feeding_Irritable),
      Pews.initforTesting(23, 6),
      Pews.initforTesting(24, 7),

      Pews.initforTesting(25, 8),
      Pews.initforTesting(34, 15),
      Pews.initforTesting(48, 2)
    ];

    return [
      new charts.Series<Pews, DateTime>(
        id: 'PEWS score',
        colorFn: (_, __) => charts.MaterialPalette.black,
        domainFn: (Pews score, _) => score.time,
        measureFn: (Pews score, _) => score.totalScore,
        data: pews_data,
      ),
    ];
  }

  List<charts.Series<Pews, DateTime>> getPatientData() {

    Patient p =_db.getPatient(_patientId);
    List<Pews> points = p.getPatientData();
    points.sort((a, b) => (a.time).compareTo(b.time));
    return [ new charts.Series<Pews, DateTime>(
      id: 'PEWS score',
      colorFn: (_, __) => charts.MaterialPalette.black,
      domainFn: (Pews score, _) => score.time,
      measureFn: (Pews score, _) => score.totalScore,
      data: points,
    )];
  }
}

class _PewsGraphState extends State<PewsGraphWidget> {
  DateTime _time;
  Map<String, Pews> _measures;
  Pews _selectedPews = null;
  final ageFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    ageFieldController.dispose();
    super.dispose();
  }

  String enumStringToString(String val) {
    //regex match after .
    return val.split(".")[1];
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    DateTime time;
    final measures = <String, Pews>{};
    Pews selected = null;

    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.time;
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        if (selected == null) selected = datumPair.datum;
        measures[datumPair.series.displayName] = datumPair.datum;
      });
    }

    // Request a build.
    setState(() {
      _time = time;
      _measures = measures;
      _selectedPews = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle() {
      return TextStyle(
        fontSize: 23,
        color: Colors.black.withOpacity(0.6),
      );
    }
    BoxDecoration myBoxDecoration() {
      return BoxDecoration(
        border: Border.all(
          width: 1, //
        ),
        borderRadius: BorderRadius.all(
            Radius.circular(5.0)
        ), //
      );
    }

    void deleteSelected(){
      Patient p = widget._db.getPatient(widget._patientId);
      p.removeRecord(_selectedPews);
      setState(() {
        widget.getPatientData();
      });
    }

    Container ValueDisplayBox = new Container(
        width: MediaQuery
            .of(context)
            .size
            .width - 20,
        decoration: myBoxDecoration(),
        child: Offstage(
            offstage: _selectedPews == null,
            child: Column(
              children: [
                //All PEWS/NEWS FIELDS
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Time  : ", style: textStyle(),),
                      _selectedPews != null ? Text(
                          DateFormat('yyyy-MM-dd  kk:mm').format(_time), style: textStyle()): Text(""),

                    //  DateFormat('yyyy-MM-dd  kk:mm').format(_time);
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Total Score  :", style: textStyle()),
                      _selectedPews != null ? Text(
                          _selectedPews.totalScore.toString(),
                          style: textStyle()) : Text(""),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Respiratory Rate  :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.respiratoryRate != 0 ? Text(
                          _selectedPews.respiratoryRate.toString(),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Respiratory Distress  :", style: textStyle()),

                      _selectedPews != null ?
                      _selectedPews.respiratoryDistress != null ? Text(
                          enumStringToString(
                              _selectedPews.respiratoryDistress.toString()),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),

                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Oxygen Saturation  :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.oxygenSaturation != 0 ? Text(
                          _selectedPews.oxygenSaturation.toString(),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ), Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Oxygen Delivery  :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.roomAir ?
                      Text("Room Air", style: textStyle()) :
                      _selectedPews.oxygenDelivery != 0 ?
                      Text(_selectedPews.oxygenDelivery.toString(),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Heart Rate :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.heartRate != 0 ? Text(
                          _selectedPews.heartRate.toString(),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Capillary Refill  :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.capillaryRefill != 0 ? Text(
                          _selectedPews.capillaryRefill.toString(),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Blood Pressure Systolic  :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.bloodPressureSystolic != 0 ? Text(
                          _selectedPews.bloodPressureSystolic.toString(),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Blood Pressure Diastolic  :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.bloodPressureDiastolic != 0 ? Text(
                          _selectedPews.bloodPressureDiastolic.toString(),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Pulse Pressure  :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.pulsePressure != 0 ? Text(
                          _selectedPews.pulsePressure.toString(),
                          style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("CNS/AVPU  :", style: textStyle()),
                      _selectedPews != null
                          ?
                      _selectedPews.CNS != null ?
                      Text(enumStringToString(_selectedPews.CNS.toString()),
                          style: textStyle()) :
                      _selectedPews.AVPU != null ? Text(
                          enumStringToString(_selectedPews.AVPU.toString()),
                          style: textStyle()) : Text("NONE", style: textStyle())
                          : Text("")

                      // Text(enumStringToString(_selectedPews.AVPU.toString()), style: textStyle()): Text("")
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Temperature  :", style: textStyle()),
                      _selectedPews != null ?
                      _selectedPews.temp != 0 ? Text(
                          _selectedPews.temp.toString(), style: textStyle())
                          : Text("NONE", style: textStyle())
                          : Text(""),
                    ]
                ),
              ],
            ))
    );


    InputDecoration textInputDecoration = new InputDecoration(

      labelText: "Label Text",
      suffixText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(
          color: Colors.amber,
          style: BorderStyle.solid,
        ),

      ),

    );

    Container patientEntry = new Container(
      alignment: Alignment.center,
      width: (MediaQuery
          .of(context)
          .size
          .width),


      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            new Container(width: 200, child: TextField(
              controller: ageFieldController,
              keyboardType: TextInputType.number,
              decoration: textInputDecoration.copyWith(
                  labelText: "Patient ID"),
            )),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // getPatientData();
                });
              },
              child: Text('ENTER'),
            )
          ]),
    );

    SizedBox graphWidget = new SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.3,
      child: new charts.TimeSeriesChart(
          widget._seriesList,
          animate: widget.animate,
          selectionModels: [
            new charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: _onSelectionChanged,
            )
          ],
          // defaultRenderer: new charts.LineRenderer(includePoints: true),
          domainAxis: new charts.DateTimeAxisSpec(
              tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                hour: new charts.TimeFormatterSpec(
                    format: 'HH:mm', transitionFormat: 'HH:mm'),
                day: new charts.TimeFormatterSpec(
                    format: 'd', transitionFormat: 'MM/dd/yyyy'),
              )
          )),
    );

    final children = <Widget>[
      new Offstage(
          offstage: !widget._validPatientId,
          child: graphWidget
      ),
      new Offstage(
          offstage: !widget._validPatientId,
          child: ValueDisplayBox
      ),
      // new ElevatedButton(onPressed: deleteSelected , child: Text("DELETE")),
      new Offstage(
          offstage: _selectedPews != null,
          child: new Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 20,
              // decoration: myBoxDecoration(),

              child: Column(children: [
                SizedBox(height: 30),
                Text("Select a point", style: textStyle()),
              ],
                mainAxisAlignment: MainAxisAlignment.center,
              )
          ))

    ];

    // If there is a selection, then include the details.


    return new Scaffold(appBar: AppBar(
      title: Text("Pews Graph"),
    ),body : Column(children: children));
  }

}