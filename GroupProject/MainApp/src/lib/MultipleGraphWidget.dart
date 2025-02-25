
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;

import 'data/patient.dart';
import 'data/pews_models.dart';
import 'database.dart';

class MultipleGraphWidget extends StatefulWidget {

  /*
  This widget displays a list of graphs, one for each measurement in PEWS

  IMPORTANT: for autologout use the StatelessMultiGraphWidget which wraps this
   */

  List<charts.Series> _pewsSeries;
  List<charts.Series> _respiratoryRateSeries;
  List<charts.Series> _respiratoryDistressSeries;
  List<charts.Series> _oxygenSaturationSeries;
  List<charts.Series> _oxygenDeliverySeries;
  List<charts.Series> _heartRateSeries;
  List<charts.Series> _capillaryRefillSeries;
  List<charts.Series> _bloodPressureSysSeries;
  List<charts.Series> _bloodPressureDiaSeries;
  List<charts.Series> _pulsePressureSeries;
  List<charts.Series> _avpuSeries;
  List<charts.Series> _cnsSeries;
  List<charts.Series> _tempSeries;

  bool animate = false;
  String _patientId;
  String _displayablePatientId;
  Database _db;
  bool _isNewborn = false;
  int age = 0;
  List<bool> hourSelection = [false, true];

  DateTime min = DateTime.now(); //needed for custom axis
  DateTime max = DateTime.now();

  MultipleGraphWidget();
  /// Creates a [charts.TimeSeriesChart] with sample data and no transition.

  MultipleGraphWidget.initWithPatient(Database db, String patientId){
    _db = db;
    db.deleteStaleRecords();
    _displayablePatientId = db.getPatient(patientId).getDisplayableId().toUpperCase();
    _patientId = patientId;
    setGraphFields();
  }

  void setGraphFields(){
    _pewsSeries = getPatientData(PewsFields.totalScore);
    _heartRateSeries =getPatientData(PewsFields.heartRate);
    _respiratoryRateSeries = getPatientData(PewsFields.respiratoryRate);
    _respiratoryDistressSeries = getPatientData(PewsFields.respiratoryDistress);
    _oxygenSaturationSeries= getPatientData(PewsFields.oxygenSaturation);
    _oxygenDeliverySeries= getPatientData(PewsFields.oxygenDelivery);
    _capillaryRefillSeries= getPatientData(PewsFields.capillaryRefill);
    _bloodPressureSysSeries = getPatientData(PewsFields.bloodPressureSystollic);
    _bloodPressureDiaSeries= getPatientData(PewsFields.bloodPressureDiastolic);
    _pulsePressureSeries= getPatientData(PewsFields.pulsePressure);
    _avpuSeries = getPatientData(PewsFields.AVPU);
    _cnsSeries = getPatientData(PewsFields.CNS);
    _tempSeries= getPatientData(PewsFields.temp);
    _isNewborn = _db.getPatient(_patientId).getIsNewborn();
    age = _db.getPatient(_patientId).getAge();
  }


  // We need a Stateful widget to build the selection details with the current
  // selection as the state.
  @override
  State<StatefulWidget> createState() => new _PewsGraphState();

  //convert discrete fields to values to be plotted

  int avpuToPews(AVPULevels avpuLevels){
      switch (avpuLevels) {
        case AVPULevels.Alert :
          return 0;
        case AVPULevels.Voice:
          return 1;
        case AVPULevels.Pain:
          return 2;
        case AVPULevels.Unresponsive:
          return 3;
        default:
          return 0;
      }
  }

  int cnsToNews(CNSLevels cns){
      switch (cns) {
        case CNSLevels.Active_Feeding_Well:
          return 0;
        case CNSLevels.Poor_Feeding_Irritable:
          return 1;
        case CNSLevels.Floppy_Not_Feeding:
          return 2;
        default:
          return 0;
      }

  }

  int respiratoryDistressToPews(RespiratoryDistressLevels distress){
    switch(distress){
      case RespiratoryDistressLevels.None:return 0;
      case RespiratoryDistressLevels.Mild: return 1;
      case RespiratoryDistressLevels.Moderate: return 2;
      case RespiratoryDistressLevels.Severe_apnoea: return 3;
    }
  }


  Function(Pews, int) getMeasureFn(PewsFields field){
    switch(field){
      case (PewsFields.heartRate): return (Pews score, _) => score.heartRate;
      case(PewsFields.respiratoryRate):return (Pews score, _) => score.respiratoryRate;
      case(PewsFields.respiratoryDistress): return (Pews score,_) => respiratoryDistressToPews(score.respiratoryDistress);
      case (PewsFields.oxygenSaturation): return (Pews score, _) => score.oxygenSaturation;

      case (PewsFields.oxygenDelivery): return (Pews score, _) => score.oxygenDelivery;
      case (PewsFields.capillaryRefill): return (Pews score, _) => score.capillaryRefill;
      case (PewsFields.bloodPressureSystollic): return (Pews score, _) => score.bloodPressureSystolic;
      case (PewsFields.bloodPressureDiastolic): return (Pews score, _) => score.bloodPressureDiastolic;
      case (PewsFields.pulsePressure): return (Pews score, _) => score.pulsePressure;
      case (PewsFields.temp): return (Pews score, _) => score.temp;
      case (PewsFields.CNS): return (Pews score, _) => cnsToNews(score.CNS);
      case (PewsFields.AVPU): return (Pews score, _) => avpuToPews(score.AVPU);

      default: return (Pews score, _) => score.totalScore;
    }
  }


  bool elementFilter(PewsFields field, Pews element){
    //don't plot 0 or empty values and only plot a PEWS score if all fields are present
    switch(field){
      case (PewsFields.totalScore): return element.isCompleted;
      case (PewsFields.heartRate): return element.heartRate > 0 ;
      case (PewsFields.oxygenSaturation): return element.oxygenSaturation > 0;
      case(PewsFields.capillaryRefill): return element.capillaryRefill>0;
      case (PewsFields.bloodPressureSystollic): return element.bloodPressureSystolic > 0 ;
      case (PewsFields.bloodPressureDiastolic): return element.bloodPressureDiastolic > 0;
      case (PewsFields.pulsePressure): return element.pulsePressure>0;
      case (PewsFields.temp): return (element.temp>0);

      default: return true;
    }
  }

  List<charts.Series<Pews, DateTime>> getPatientData(PewsFields field) {

    Patient p =_db.getPatient(_patientId);
    List<Pews> points = p.getPatientData();

    //sort so graph is in order
    points.sort((a, b) => (a.time).compareTo(b.time));

    if (points.length>= 1){
      min = points[0].time;
      max = points[points.length-1].time;
    }

    //24 hour filter
    if(hourSelection[0]){
      points = points.where((element) => element.time.isAfter(DateTime.now().subtract(Duration(hours: 24)))).toList();
    }

    //remove unnecessary points
    points = points.where((element) => elementFilter(field, element)).toList();

    //set min and max time (universal to all graphs to align all axis)


    return [ new charts.Series<Pews, DateTime>(
      id: 'PEWS score',
      colorFn: (_, __) => charts.MaterialPalette.black,
      domainFn: (Pews score, _) => score.time,
      measureFn: getMeasureFn(field),
        data : points,
    )
    ];
  }
}

class _PewsGraphState extends State<MultipleGraphWidget> {

  static const zero_colour = Color(0xFFFFFFFF);
  static const one_color = Color(0xFFc4bfbe);
  static const two_color = Color(0xFFfff480);
  static const three_color = Color(0xFFff9580);

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

    //DateTime ticks - uniform across all graphs
    List<charts.TickSpec<DateTime>>  getTicks(){

      DateTime minTick = widget.min;
      if(widget.hourSelection[0]){
        DateTime change = DateTime.now().subtract(Duration(hours:24));
        if (minTick.isBefore(change)) minTick = change;
      }

      minTick = minTick.subtract(Duration(minutes :minTick.minute));

      int dif = (DateTime.now().difference(minTick)).inHours + 1;
      int increment = 1;
      if (dif<6){
        increment = 1;
      }else if (dif <12){
        increment  =2;
      }else if (dif< 16){
        increment = 3;
      }else if (dif <24){
        increment = 4;
      }else{
        increment = 8;
      }

      List<charts.TickSpec<DateTime>> ticks = [];
      for (DateTime i = minTick.subtract(Duration(hours:1)); i.isBefore(DateTime.now().add(Duration(hours: 1)));  i = i.add(Duration(hours: increment)) ){
        ticks.add(new charts.TickSpec(i));
      }
      return ticks;
    }

    //specific to each graph - get the min and max value as if out of standard
    //range the graph axis need to be extended
    //NOTE - the client did not want automatically adjusting axis with no
    //zero-bound as they wanted the axis to be fixed and only extend when
    // necessary
    double getMinMax(max, PewsFields field) {
      List<Pews> data = widget._db.getPatient(widget._patientId).getPatientData();
      if (data.isEmpty) return null;
      switch (field) {
        case PewsFields.totalScore:
          if(max){
            return data.reduce((curr, next) => curr.totalScore > next.totalScore? curr: next).totalScore.toDouble();
          }
         return data.reduce((curr, next) => curr.totalScore < next.totalScore? curr: next).totalScore.toDouble();
        case PewsFields.temp:
          if(max){
            return data.reduce((curr, next) => curr.temp > next.temp? curr: next).temp;
          }
          return data.reduce((curr, next) => curr.temp < next.temp? curr: next).temp;
        case PewsFields.heartRate:
          if(max){
            return data.reduce((curr, next) => curr.heartRate > next.heartRate? curr: next).heartRate.toDouble();
          }
          return data.reduce((curr, next) => curr.heartRate < next.heartRate? curr: next).heartRate.toDouble();
        case PewsFields.respiratoryRate:
          if(max){
            return data.reduce((curr, next) => curr.respiratoryRate > next.respiratoryRate? curr: next).respiratoryRate.toDouble();
          }
          return data.reduce((curr, next) => curr.respiratoryRate < next.respiratoryRate? curr: next).respiratoryRate.toDouble();
        case PewsFields.oxygenSaturation:
          if(max){
            return data.reduce((curr, next) => curr.oxygenSaturation > next.oxygenSaturation? curr: next).oxygenSaturation;
          }
          return data.reduce((curr, next) => curr.oxygenSaturation < next.oxygenSaturation? curr: next).oxygenSaturation;
        case PewsFields.oxygenDelivery:
          if(max){
            return data.reduce((curr, next) => curr.oxygenDelivery > next.oxygenDelivery? curr: next).oxygenDelivery.toDouble();
          }
          return data.reduce((curr, next) => curr.oxygenDelivery < next.oxygenDelivery? curr: next).oxygenDelivery.toDouble();
        case PewsFields.capillaryRefill:
          if(max){
            return data.reduce((curr, next) => curr.capillaryRefill > next.capillaryRefill? curr: next).capillaryRefill;
          }
          return data.reduce((curr, next) => curr.capillaryRefill < next.capillaryRefill? curr: next).capillaryRefill;
        case PewsFields.bloodPressureSystollic:
          if(max){
            return data.reduce((curr, next) => curr.bloodPressureSystolic > next.bloodPressureSystolic? curr: next).bloodPressureSystolic.toDouble();
          }
          return data.reduce((curr, next) => curr.bloodPressureSystolic < next.bloodPressureSystolic? curr: next).bloodPressureSystolic.toDouble();
        case PewsFields.bloodPressureDiastolic:
          if(max){
            return data.reduce((curr, next) => curr.bloodPressureDiastolic > next.bloodPressureDiastolic? curr: next).bloodPressureDiastolic.toDouble();
          }
          return data.reduce((curr, next) => curr.bloodPressureDiastolic < next.bloodPressureDiastolic? curr: next).bloodPressureDiastolic.toDouble();
        case PewsFields.pulsePressure:
          if(max){
            return data.reduce((curr, next) => curr.pulsePressure > next.pulsePressure? curr: next).pulsePressure.toDouble();
          }
          return data.reduce((curr, next) => curr.pulsePressure < next.pulsePressure? curr: next).pulsePressure.toDouble();
      }
    }

    List<charts.TickSpec<int>>  getCustomTicks(int minDefault, int maxDefault , PewsFields field){
      double minActual = getMinMax(false, field);
      double maxActual = getMinMax(true, field);

      int min;
      int max;

      if (minActual == null || minActual == 0) min = minDefault;
      else min = minActual.floor();
      if (maxActual == null) max = maxDefault;
      else max = maxActual.ceil();

      //extend the axis if needed
      if(maxDefault<max) maxDefault = max;
      if(minDefault>min) minDefault = min;

      int dif = maxDefault - minDefault;
      int inc = 1;
      if (dif>=100) inc = 20;
      else if (dif>=30) inc = 10;
      else if (dif>=10) inc = 5;
      List<charts.TickSpec<int>> ticks = [];

      for (int i = minDefault ; i<= maxDefault;  i += inc ){
        ticks.add(new charts.TickSpec(i));
      }

      return ticks;
    }

    charts.DateTimeAxisSpec dateTimeAxisSpec = new charts.DateTimeAxisSpec(
        tickFormatterSpec:
        new charts.AutoDateTimeTickFormatterSpec(
          hour: new charts.TimeFormatterSpec(
              format: 'HH:mm', transitionFormat: 'HH:mm'),
          day: new charts.TimeFormatterSpec(
              format: 'd', transitionFormat: 'MM/dd/yyyy'),
        )
    );

    charts.NumericAxisSpec numericAxisSpec = new charts.NumericAxisSpec(
        tickProviderSpec:
        new charts.BasicNumericTickProviderSpec(
            zeroBound: false));

  charts.DateTimeAxisSpec variableDateTimeSpec = new charts.DateTimeAxisSpec(
    tickProviderSpec: new charts.StaticDateTimeTickProviderSpec(getTicks())
  );


  //each chart has their own custom colour annotation to match the physical
  //  charts and this varies based on age
  //  the annotation will extend based on min and max value
    charts.RangeAnnotation pewsAnnotation(){
      double maxd = getMinMax(true, PewsFields.totalScore);
      if(maxd ==null) maxd = 0;
      int max =maxd.ceil();
      if (max<10) max = 10;
      return  new charts.RangeAnnotation([
        new charts.RangeAnnotationSegment(
            0.5, 1.5, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(Color(0xFF8aff80))),
        new charts.RangeAnnotationSegment(
            1.5, 2.5, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor( Color(0xFFb5ff80))),
        new charts.RangeAnnotationSegment(
            2.5, 3.5, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(Color(0xFFe1ff80))),
        new charts.RangeAnnotationSegment(
            3.5, 5.5, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(Color(0xFFfff480))),
        new charts.RangeAnnotationSegment(
            5.5, 6.5, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(Color(0xFFffcc80))),
        new charts.RangeAnnotationSegment(
            6.5, 7.5, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(Color(0xFFffaa80))),
        new charts.RangeAnnotationSegment(
            7.5, max, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(Color(0xFFff9580))),
      ]);
    }

    charts.RangeAnnotation respiratoryRateAnnotation() {
      double maxd = getMinMax(true, PewsFields.respiratoryRate);
      if(maxd ==null) maxd = 0;
      int max =maxd.ceil();
      if (max<90) max = 90;

      if (widget._isNewborn) {
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              30, 50, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              50, 70, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              70, 80, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              0, 30, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              80, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }else if (widget.age < 1) {
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              25, 50, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              50, 60, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              20, 25, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              60, 70, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              0, 20, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              70, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }else { //same for 1-5 and 5-12 chart
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              20, 40, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              40, 50, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              10,20, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              50, 60, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              0,10, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              60, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }
    }

    charts.RangeAnnotation oxygenSaturationAnnotation(){
      double mind = getMinMax(false, PewsFields.oxygenSaturation);
      if(mind ==null) mind = 0;
      int min =mind.floor();
      if (min<80 || min == 0 ) min = 80;
      if (widget._isNewborn) {
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              94, 100, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              90, 94, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              85, 90, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              min, 85, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }else{
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              94, 100, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              90, 94, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              min, 90, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }
    }

    charts.RangeAnnotation heartRateAnnotation(){
      double maxd = getMinMax(true, PewsFields.heartRate);
      if(maxd ==null) maxd = 0;
      int max =maxd.ceil();
      if (max<200) max = 200;
      double mind = getMinMax(false, PewsFields.heartRate);
      if(mind ==null) mind = 0;
      int min =mind.floor();         if (min>40 || min == 0) min = 40;

      if(widget._isNewborn){
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              100, 160, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              80, 100, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              60, 80, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              min, 60, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              160, 180, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              180, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }else if (widget.age < 1){
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              180, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              170, 180, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              150, 170, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              90, 150, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              70, 90, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              60, 70, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              min, 60, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      } else if (widget.age<5){
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              170, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              150, 170, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              130, 150, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              80, 130, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              60, 80, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              min, 60, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      } else{
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              150, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              130, 150, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              110, 130, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              70, 110, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              60, 70, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              min, 60, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }
    }

    charts.RangeAnnotation capillaryRefillAnnotation(){
      double maxd = getMinMax(true, PewsFields.capillaryRefill);
      if(maxd ==null) maxd = 0;
      int max =maxd.ceil();
      if (max<6) max = 6;
      if (widget._isNewborn) {
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              0, 3, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              3, 4, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              4,max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }else{
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              0, 3, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              3, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
        ]);
      }
    }

    charts.RangeAnnotation systolicBloodPressureAnnotation(){
      double maxd = getMinMax(true, PewsFields.bloodPressureSystollic);
      if(maxd ==null) maxd = 0;
      int max =maxd.ceil();      if (max<150) max = 150;
      double mind = getMinMax(false, PewsFields.bloodPressureSystollic);
      if(mind ==null) mind = 0;
      int min =mind.floor();
      if (min>40 || min == 0 ) min = 40;

      if(widget._isNewborn){
        return  new charts.RangeAnnotation([]);
      }else if (widget.age < 1){
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              120, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              110, 120, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              80, 110, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              70, 80, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              60, 70, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              min, 60, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      } else if (widget.age<5){
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              130, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              120, 130, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              110, 120, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              80, 110, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              70, 80, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              min, 70, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      } else{
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              140, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              130, 140, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              110, 130, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              90, 110, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              80, 90, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              min, 80, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }
    }

    charts.RangeAnnotation pulsePressureAnnotation(){
      double maxd = getMinMax(true, PewsFields.pulsePressure);
      if(maxd ==null) maxd = 0;
      int max =maxd.ceil();      if (max<40) max = 40;
      return  new charts.RangeAnnotation([
        new charts.RangeAnnotationSegment(
            0, 20, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(zero_colour)),
        new charts.RangeAnnotationSegment(
            20, max, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(two_color)),
      ]);
    }

    charts.RangeAnnotation respiratoryDistressAnnotation(){
      return  new charts.RangeAnnotation([
        new charts.RangeAnnotationSegment(
            0, 1, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(zero_colour),
            startLabel: 'None'
        ),
        new charts.RangeAnnotationSegment(
           1, 2, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(one_color),
            startLabel: 'Mild'),
        new charts.RangeAnnotationSegment(
            2, 3, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(two_color)
            ,
            startLabel: 'Moderate'),
        new charts.RangeAnnotationSegment(
           3, 4, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(three_color),
            startLabel: 'Severe/Apnoea'),
      ]);
    }
    charts.RangeAnnotation avpuAnnotation(){
      return  new charts.RangeAnnotation([
        new charts.RangeAnnotationSegment(
            1, 0, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(zero_colour),
            startLabel: 'Alert'
        ),
        new charts.RangeAnnotationSegment(
            2, 1, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(one_color),
            startLabel: 'Voice'),
        new charts.RangeAnnotationSegment(
            3, 2, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(two_color)
            ,
            startLabel: 'Pain'),
        new charts.RangeAnnotationSegment(
            4, 3, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(three_color),
            startLabel: 'Unresponsive'),
      ]);
    }
    charts.RangeAnnotation cnsAnnotation(){
      return  new charts.RangeAnnotation([
        new charts.RangeAnnotationSegment(
            1, 0, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(zero_colour),
            startLabel: 'Active/ Feeding Well'
        ),
        new charts.RangeAnnotationSegment(
            2, 1, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(one_color),
            startLabel: 'Irritable/ Poor Feeding'),
        new charts.RangeAnnotationSegment(
            3, 2, charts.RangeAnnotationAxisType.measure,
            color: charts.ColorUtil.fromDartColor(two_color)
            ,
            startLabel: 'Floppy/Not Feeding'),

      ]);
    }

    charts.RangeAnnotation temperatureAnnotation(){
      double maxd = getMinMax(true, PewsFields.temp);
      if(maxd ==null) maxd = 0;
      int max =maxd.ceil();
      if (max<40) max = 40;
      double mind = getMinMax(false, PewsFields.temp);
      if(mind ==null) mind = 0;
      int min =mind.floor();
      if (min>30 || min ==0 ) min = 30;
      if (widget._isNewborn){
        return  new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(
              39.5, max, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
          new charts.RangeAnnotationSegment(
              38.5, 39.5, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              37.5, 38.5, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              36.5, 37.5, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(zero_colour)),
          new charts.RangeAnnotationSegment(
              35.5, 36.5, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(one_color)),
          new charts.RangeAnnotationSegment(
              34, 35.5, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(two_color)),
          new charts.RangeAnnotationSegment(
              min, 34, charts.RangeAnnotationAxisType.measure,
              color: charts.ColorUtil.fromDartColor(three_color)),
        ]);
      }
      return new charts.RangeAnnotation([]);
    }

    //this allows for points in the graphs to be seleted using a custom renderer
    // I created which displays the value on selection
    charts.SelectionModelConfig<DateTime> selectionModelConfig(){
      return new charts.SelectionModelConfig(
        changedListener: (charts.SelectionModel model) {
        if(model.hasDatumSelection){
        final value = model.selectedSeries[0].measureFn(model.selectedDatum[0].index);
        CustomCircleSymbolRenderer.text = value.toString();  // paints the tapped value
        }
      });
    }

    ListView graphWidget = new ListView(
    children :[

      SizedBox(height: 10,),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children:[
          ToggleButtons(children: <Widget>[
            Text("24 hours"),
            Text("48 hours"),
          ],
      onPressed: (int index) {
      setState(() {
        for (int buttonIndex = 0; buttonIndex < widget.hourSelection.length; buttonIndex++) {
          if (buttonIndex == index) {
            widget.hourSelection[buttonIndex] = true;
          } else {
            widget.hourSelection[buttonIndex] = false;
          }
        }
        widget.setGraphFields();
      });
    },
    isSelected: widget.hourSelection,
    ),
        ]
      ),
      // SizedBox(height: 20,),
    new SizedBox(
    height: MediaQuery
        .of(context)
        .size
        .height * 0.3,
    child: new charts.TimeSeriesChart(
    widget._pewsSeries,
    animate: widget.animate,
    domainAxis: variableDateTimeSpec,
      defaultRenderer: new charts.LineRendererConfig(includePoints: true),
    behaviors: [
      pewsAnnotation(),
      charts.LinePointHighlighter(
          symbolRenderer: CustomCircleSymbolRenderer()
      ),
      new charts.ChartTitle('Total PEWS score',
          behaviorPosition: charts.BehaviorPosition.start,
          titleOutsideJustification:
          charts.OutsideJustification.middleDrawArea),
              ],

      selectionModels: [
        selectionModelConfig()
      ],
      primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(0, 10, PewsFields.totalScore))),

    )),
        new SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
                widget._respiratoryRateSeries,
                animate: widget.animate,
                domainAxis: variableDateTimeSpec,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
              behaviors: [
                new charts.ChartTitle('Respiratory Rate',
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),
                respiratoryRateAnnotation(),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(0, 90, PewsFields.respiratoryRate))),
            )),
      new SizedBox(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.3,
          child: new charts.TimeSeriesChart(
            widget._respiratoryDistressSeries,
            animate: widget.animate,
            domainAxis: variableDateTimeSpec,
            defaultRenderer: new charts.LineRendererConfig(includePoints: true),
            behaviors: [
              new charts.ChartTitle('Respiratory Distress',
                  behaviorPosition: charts.BehaviorPosition.start,
                  titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),              respiratoryDistressAnnotation(),
              charts.LinePointHighlighter(
                  symbolRenderer: CustomCircleSymbolRenderer()
              ),

            ],
            selectionModels: [
              selectionModelConfig()
            ],
            primaryMeasureAxis: numericAxisSpec,
          )),
        new SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
                widget._oxygenSaturationSeries,
                animate: widget.animate,
                domainAxis: variableDateTimeSpec,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
              behaviors: [
                new charts.ChartTitle('Oxygen Saturation (%)',
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),
                oxygenSaturationAnnotation(),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(80,100, PewsFields.oxygenSaturation))),
            )),
        new SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
              widget._oxygenDeliverySeries,
              animate: widget.animate,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
              behaviors: [
                new charts.ChartTitle("O\u2082 Delivery (O\u2082 L/min)",
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              // primaryMeasureAxis: numericAxisSpec,
            )),
        new SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
                widget._heartRateSeries,
                animate: widget.animate,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
              behaviors: [
                new charts.ChartTitle("Heart Rate (bpm)",
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),
                heartRateAnnotation(),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(40, 200, PewsFields.heartRate))),
            )),
        new SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
                widget._capillaryRefillSeries,
                animate: widget.animate,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
              behaviors: [
                new charts.ChartTitle("Capillary Refill (secs)",
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),                capillaryRefillAnnotation(),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(0, 6, PewsFields.capillaryRefill))),
            )),
        new SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
                widget._bloodPressureSysSeries,
                animate: widget.animate,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
              behaviors: [
                new charts.ChartTitle("Systolic Blood Pressure",
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),                systolicBloodPressureAnnotation(),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(50, 160, PewsFields.bloodPressureSystollic))),
            )),
        new SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
                widget._bloodPressureDiaSeries,
                animate: widget.animate,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
              behaviors: [
                new charts.ChartTitle("Diastolic Blood Pressure",
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(40, 160, PewsFields.bloodPressureDiastolic))),
            )),
        new Offstage(
            offstage: widget._isNewborn,
            child : SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
                widget._pulsePressureSeries,
                animate: widget.animate,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
              behaviors: [
                new charts.ChartTitle("Pulse Pressure (mmHg)",
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),                pulsePressureAnnotation(),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(0, 40, PewsFields.pulsePressure))),
            ))),
      new Offstage(
          offstage: widget._isNewborn,
          child : SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.3,
              child: new charts.TimeSeriesChart(
                widget._avpuSeries,
                animate: widget.animate,
                defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
    flipVerticalAxis: true,
                behaviors: [
                  new charts.ChartTitle("AVPU",
                      behaviorPosition: charts.BehaviorPosition.start,
                      titleOutsideJustification:
                      charts.OutsideJustification.middleDrawArea),
                  avpuAnnotation(),
                  charts.LinePointHighlighter(
                      symbolRenderer: CustomCircleSymbolRenderer()
                  )
                ],
                selectionModels: [
                  selectionModelConfig()
                ],
                primaryMeasureAxis: numericAxisSpec,
              ))),
      new Offstage(
          offstage: !widget._isNewborn,
          child : SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.3,
              child: new charts.TimeSeriesChart(
                widget._cnsSeries,
                animate: widget.animate,
    flipVerticalAxis: true,
                defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
                behaviors: [
                  new charts.ChartTitle("CNS",
                      behaviorPosition: charts.BehaviorPosition.start,
                      titleOutsideJustification:
                      charts.OutsideJustification.middleDrawArea),                  cnsAnnotation(),
                  charts.LinePointHighlighter(
                      symbolRenderer: CustomCircleSymbolRenderer()
                  )
                ],
                selectionModels: [
                  selectionModelConfig()
                ],
                primaryMeasureAxis: numericAxisSpec,
              ))),

        new SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: new charts.TimeSeriesChart(
                widget._tempSeries,
                animate: widget.animate,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                domainAxis: variableDateTimeSpec,
              behaviors: [
                new charts.ChartTitle("Temperature  (\u00B0 C)",
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea),
                temperatureAnnotation(),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                )
              ],
              selectionModels: [
                selectionModelConfig()
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(tickProviderSpec:charts.StaticNumericTickProviderSpec(getCustomTicks(30, 42, PewsFields.temp))),
            )),
        ],
        // defaultRenderer: new charts.LineRenderer(includePoints: true),
    );


    // If there is a selection, then include the details.
    return new Scaffold(appBar: AppBar(
      title: Text("Pews Graph"),
    ), body: Column (
      children :[
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
            SelectableText(widget._displayablePatientId,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
          ]),
        ),
        Container(height: MediaQuery.of(context).size.height * 0.75,child : graphWidget)
      ]));
  }
}

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  /*
  This is a custom renderer to display the selected value in a box on the graph when it is selected
   */
  static String text;

  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds, {List<int> dashPattern, charts.Color fillColor, charts.FillPatternType fillPattern, charts.Color strokeColor, double strokeWidthPx}) {
    super.paint(canvas, bounds, dashPattern: dashPattern, fillColor: fillColor, fillPattern: fillPattern, strokeColor: strokeColor, strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 10, bounds.height + 10),
        fill: charts.Color.white
    );
    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(
        TextElement(text, style: textStyle),
        (bounds.left).round(),
        (bounds.top - 28).round()
    );
  }

}