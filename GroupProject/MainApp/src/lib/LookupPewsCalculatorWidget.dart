import 'package:main_app/data/pews_models.dart';
import 'package:main_app/database.dart';
import 'package:pews_module/PewsCalculatorWidget.dart';

import 'data/patient.dart';

// ignore: must_be_immutable
class LookupPewsCalculatorWidget extends PewsCalculatorWidget{

  Database _db;
  Patient patient;
  String patientId;
  RespiratoryDistressLevelsAdapter respiratoryDistressLevelsAdapter = new RespiratoryDistressLevelsAdapter();

  // @override
  // LookupPewsCalculatorWidget.customInit(String ageField, bool showNewborn): super.customInit(ageField, showNewborn);

  LookupPewsCalculatorWidget.initWithPatient(Database db, String patientId):super.customInitNoAgeEntry(db.getPatient(patientId).getDisplayableId().toUpperCase(), "SUBMIT", "CONTINUE", "Not all fields have been completed, this will not give you an accurate pews reading, do you wish to continue.", "Confirm Entered Pews Score"){
    _db = db;
    this.patientId = patientId;
    this.patient = _db.getPatient(patientId);
    setAge(patientId);
    patient.getDisplayableId();
    isNewborn = patient.getIsNewborn();
  }

  @override
  int setAge(String controllerText){
    age = patient.getAge();
      return age;
  }

  RespiratoryDistressLevels intToRespiratoryDistressLevels(int val){
    switch (val) {
      case 3:
        return RespiratoryDistressLevels.Severe_apnoea;
      case 2:
        return RespiratoryDistressLevels.Moderate;
      case 1:
        return RespiratoryDistressLevels.Mild;
      case 0:
        return RespiratoryDistressLevels.None;
      default:
        return null;
    }
  }

  AVPULevels intToAVPULevels(int val) {
    switch (val) {
      case 0:
        return AVPULevels.Alert;
      case 1:
        return AVPULevels.Voice;
      case 2:
        return AVPULevels.Pain;
      case 3:
        return AVPULevels.Unresponsive;
      default:
        return null;
    }
  }

  CNSLevels intToCNSLevels(int val) {
    switch (val) {
      case 2:
        return CNSLevels.Floppy_Not_Feeding;
      case 1:
        return CNSLevels.Poor_Feeding_Irritable;
      case 0:
        return CNSLevels.Active_Feeding_Well;
      default:
        return null;
    }
  }

  @override
  void submitScore(
      DateTime time,
      int totalScore,
      double temp ,
      int heartRate,
      int respiratoryRate,
      int respiratoryDistressLevelsValue,
      double oxygenSaturation,
      bool roomAir,
      double oxygenDelivery,
      double capillaryRefill,
      int bloodPressureSystolic,
      int bloodPressureDiastolic,
      int pulsePressure,
      int AVPULevelsValue,
      int CNSLevelsValue,
      bool isCompleted){
    print("submitting : " );
    print(temp);
    patient.addRecord(Pews()
      ..time = time == null? DateTime.now() : time
      ..totalScore = totalScore
      ..temp = temp
      ..heartRate = heartRate
      ..respiratoryRate = respiratoryRate
      ..respiratoryDistress = intToRespiratoryDistressLevels(respiratoryDistressLevelsValue)
      ..oxygenSaturation = oxygenSaturation
      ..roomAir = roomAir
      ..oxygenDelivery =  oxygenDelivery
      ..capillaryRefill = capillaryRefill
      ..bloodPressureSystolic = bloodPressureSystolic
      ..bloodPressureDiastolic =bloodPressureDiastolic
      ..pulsePressure = pulsePressure
      ..AVPU = intToAVPULevels(AVPULevelsValue)
      ..CNS = intToCNSLevels(CNSLevelsValue)
      ..isCompleted = isCompleted, _db);
  }



}