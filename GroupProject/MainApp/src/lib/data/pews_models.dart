import 'package:hive/hive.dart';

part 'pews_models.g.dart';

@HiveType(typeId: 1)
class Pews {
  @HiveField(0)
  DateTime time;
  @HiveField(1)
  int totalScore = 0;
  @HiveField(2)
  double temp = 0;
  @HiveField(3)
  int heartRate = 0;
  @HiveField(4)
  int respiratoryRate = 0;
  @HiveField(5)
  RespiratoryDistressLevels respiratoryDistress = null;
  @HiveField(6)
  double oxygenSaturation = 0;
  @HiveField(7)
  bool roomAir = false;
  @HiveField(8)
  double oxygenDelivery = 0;
  @HiveField(9)
  double capillaryRefill = 0;
  @HiveField(10)
  int bloodPressureSystolic = 0;
  @HiveField(11)
  int bloodPressureDiastolic = 0;
  @HiveField(12)
  int pulsePressure = 0;
  @HiveField(13)
  AVPULevels AVPU = null;
  @HiveField(14)
  CNSLevels CNS = null;
  @HiveField(15)
  bool isCompleted =
      false;

  Pews();

  Map toJson() => {
    "time": time.toIso8601String(),
    "totalScore": totalScore,
    "temp": temp,
    "heartRate": heartRate,
    "respiratoryRate": respiratoryRate,
    "respiratoryDistress": respiratoryDistress == null ? -1 : respiratoryDistress.index,
    "oxygenSaturation": oxygenSaturation,
    "roomAir": roomAir,
    "oxygenDelivery": oxygenDelivery,
    "capillaryRefill": capillaryRefill,
    "bloodPressureSystolic": bloodPressureSystolic,
    "bloodPressureDiastolic": bloodPressureDiastolic,
    "pulsePressure": pulsePressure,
    "AVPU": AVPU == null ? -1 : AVPU.index,
    "CNS": CNS == null ? -1 : CNS.index,
    "isCompleted": isCompleted
  };

  Pews.fromJson(Map json) :
        time = DateTime.parse(json["time"]),
        totalScore = json["totalScore"],
        temp = json["temp"],
        heartRate = json["heartRate"],
        respiratoryRate = json["respiratoryRate"],
        oxygenSaturation = json["oxygenSaturation"],
        roomAir = json["roomAir"],
        oxygenDelivery = json["oxygenDelivery"],
        capillaryRefill = json["capillaryRefill"],
        bloodPressureSystolic = json["bloodPressureSystolic"],
        bloodPressureDiastolic = json["bloodPressureDiastolic"],
        pulsePressure = json["pulsePressure"],
        isCompleted = json["isCompleted"] {
    var respiratoryDistress = json["respiratoryDistress"];
    this.respiratoryDistress = respiratoryDistress == -1 ? null : RespiratoryDistressLevels.values[respiratoryDistress];
    var AVPU = json["AVPU"];
    this.AVPU = AVPU == -1 ? null : AVPULevels.values[AVPU];
    var CNS = json["CNS"];
    this.CNS = CNS == -1 ? null : CNSLevels.values[CNS];
  }
  
  Pews.initWithTime() {
    time = DateTime.now();
  }

  Pews.initforTesting(int dif, int s) {
    time = DateTime.now().subtract(Duration(hours: dif));
    totalScore = s;
  }

  Pews.fullInitForTesting(
      double temp,
      int heartRate,
      int rRate,
      RespiratoryDistressLevels respiratoryDistressLevels,
      CNSLevels avpuLevels) {
    time = DateTime.now().subtract(Duration(hours: 17));
    this.temp = temp;
    this.heartRate = heartRate;
    respiratoryRate = rRate;
    respiratoryDistress = respiratoryDistressLevels;
    this.CNS = avpuLevels;
    totalScore = 7;
  }
}

enum PewsFields {
  totalScore,
  temp,
  heartRate,
  respiratoryRate,
  respiratoryDistress,
  oxygenSaturation,
  roomAir,
  oxygenDelivery,
  capillaryRefill,
  bloodPressureSystollic,
  bloodPressureDiastolic,
  pulsePressure,
  AVPU,
  CNS
}

@HiveType(typeId: 3)
enum RespiratoryDistressLevels {
  @HiveField(0)
  Severe_apnoea,
  @HiveField(1)
  Moderate,
  @HiveField(2)
  Mild,
  @HiveField(3)
  None,
}

@HiveType(typeId: 4)
enum AVPULevels {
  @HiveField(0)
  Alert,
  @HiveField(1)
  Voice,
  @HiveField(2)
  Pain,
  @HiveField(3)
  Unresponsive,
}

@HiveType(typeId: 5)
enum CNSLevels {
  @HiveField(0)
  Floppy_Not_Feeding,
  @HiveField(1)
  Poor_Feeding_Irritable,
  @HiveField(2)
  Active_Feeding_Well
}