import 'package:hive/hive.dart';
import 'package:main_app/data/pews_models.dart';
import 'package:main_app/database.dart';

//HiveType and HiveField needed for automatic generation of Adapters for db
//To generate adapter, run <flutter packages pub run build_runner build>

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient {
  @HiveField(0)
  String _patientId;
  @HiveField(1)
  List<Pews> _recordedData = [];
  @HiveField(2)
  int _age;
  @HiveField(3)
  bool _newborn;
  @HiveField(4)
  String _displayableId;
  @HiveField(5)
  DateTime lastChanged = DateTime.now();

  Patient(this._patientId, this._age, this._newborn, this._displayableId);

  String getPatientId() {
    return this._patientId;
  }

  String getDisplayableId() {
    return this._displayableId;
  }

  bool getIsNewborn() {
    return this._newborn;
  }

  void setIsNewborn(bool newborn) {
    _newborn = newborn;
  }

  List<Pews> getPatientData() {
    return this._recordedData;
  }

  void addRecord(Pews record, Database db) {
    this._recordedData.add(record);
    if (record.time.isAfter(lastChanged)) {
      lastChanged = record.time;
    }
    if (db != null) {
      db.putPatient(this);
      db.putUncommittedPews(this, record);
    }
  }

  // Returns whether any records were removed
  bool removeAllRecordsWhere(bool Function(Pews) f) {
    bool removed = false;
    this._recordedData.removeWhere((p) {
      if (f(p)) {
        removed = true;
        return true;
      }
      return false;
    });
    return removed;
  }

  void removeRecord(Pews record) {
    this._recordedData.remove(record);
  }

  int getAge() {
    return this._age;
  }

  void setAge(int newAge) {
    this._age = newAge;
  }

  Map toJson() => {
    'patientId': _patientId,
    'age': _age,
    'newborn': _newborn,
    'displayableId': _displayableId,
    'data': _recordedData,
    'lastChanged': lastChanged.toIso8601String()
  };

  Patient.fromJson(Map json) :
        _patientId = json['patientId'],
        _age = json['age'],
        _newborn = json['newborn'],
        _displayableId = json['displayableId'],
        _recordedData = json['data'] != null ? json['data'].map<Pews>((json) => Pews.fromJson(json)).toList() : [],
        lastChanged = DateTime.parse(json['lastChanged']);

  Patient.withRecords(Patient p, List<Pews> records) :
        _patientId = p._patientId,
        _age = p._age,
        _newborn = p._newborn,
        _displayableId = p._displayableId,
        _recordedData = records;


  // Add a new list of Pews data, not taking entries with duplicate timestamp
  // (p should be the newer value. _age and _newborn will be taken from p, and
  // it should have the same _patientId and _displayableId)
  Patient withMergedData(Patient p) {
    List<Pews> newData = p._recordedData;
    if ((newData == null || newData.length == 0) && this._newborn == p._newborn && this._age == p._age && !this.lastChanged.isBefore(p.lastChanged)) {
      return this;
    }
    if ((_recordedData == null || _recordedData.length == 0) && !p.lastChanged.isBefore(this.lastChanged)) {
      return p;
    }
    _recordedData.sort((a, b) => a.time.compareTo(b.time));
    newData.sort((a, b) => a.time.compareTo(b.time));
    List<Pews> merged = [];
    int i = 0;
    int j = 0;
    for (; i < _recordedData.length && j < newData.length;) {
      int cmp = _recordedData[i].time.compareTo(newData[j].time);
      if (cmp == 0) {
        // Equal. Arbitrarily take from existing data
        merged.add(_recordedData[i++]);
        ++j;
      } else if (cmp < 0) {
        // newData is newer
        merged.add(_recordedData[i++]);
      } else if (cmp > 0) {
        // _recordedData is newer (newData contains a new entry)
        merged.add(newData[j++]);
      }
    }

    if (
        j == newData.length && 2 * _recordedData.length == merged.length + i &&
        this._newborn == p._newborn && this._age == p._age &&
        !this.lastChanged.isBefore(p.lastChanged)
    ) return this;

    while (i < _recordedData.length) {
      merged.add(_recordedData[i++]);
    }
    while (j < newData.length) {
      merged.add(newData[j++]);
    }

    return Patient(_patientId, p._age, p._newborn, _displayableId)
      .._recordedData = merged
      ..lastChanged = lastChanged.isAfter(p.lastChanged) ? lastChanged : p.lastChanged;
  }

}

List<Pews> decodeList(List<dynamic> lst) {
  List<Pews> returnList;
  if (lst == null || lst.isEmpty)
    return [];
  for (Map<String, dynamic> pews in lst) {
    Pews p = Pews.fromJson(pews);
    returnList.add(p);
  }
  return returnList;
}
