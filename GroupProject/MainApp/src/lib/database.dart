import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/src/binary/binary_writer_impl.dart';
import 'package:hive/src/binary/binary_reader_impl.dart';
import 'package:main_app/background_data_exchange.dart';
import 'package:main_app/data/patient.dart';
import 'package:main_app/util/channels.dart';
import 'data/patient.dart';
import 'data/pews_models.dart';

class Database {
  static const int RECORD_DURATION = 48;
  Box<Patient> _patientBox;
  Box<bool> _nurseBox;
  Box<Patient> _uncommittedPatientBox;
  Box<int> _ints;

  Future init() async {
    await Hive.initFlutter();
    //Comment the following two lines if you data to be stored permanently
    //Hive.deleteBoxFromDisk("patient");
    //Hive.deleteBoxFromDisk("nurse");
    Hive.registerAdapter<Patient>(PatientAdapter());
    Hive.registerAdapter(RespiratoryDistressLevelsAdapter());
    Hive.registerAdapter(AVPULevelsAdapter());
    Hive.registerAdapter(CNSLevelsAdapter());
    Hive.registerAdapter(PewsAdapter());

    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: 'hiveKey');
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(key: 'hiveKey', value: base64UrlEncode(key));
    }

    var encryptionKey = base64Url.decode(await secureStorage.read(key: 'hiveKey'));
    var encryptionCipher = HiveAesCipher(encryptionKey);

    this._patientBox = await Hive.openBox('patient', encryptionCipher: encryptionCipher);
    this._uncommittedPatientBox = await Hive.openBox('uncommittedPatient', encryptionCipher: encryptionCipher);
    this._nurseBox = await Hive.openBox('nurse', encryptionCipher: encryptionCipher);
    this._ints = await Hive.openBox('ints', encryptionCipher: encryptionCipher);
    if (!this._ints.containsKey('version')) {
      await this._ints.put('version', 0);
    }
    if (!this._ints.containsKey('isCentral')) {
      await this._ints.put('isCentral', 0);
    }

    print('Current database version is ${getVersion()}');

    if (this._uncommittedPatientBox.isNotEmpty) {
      print('There are ${this._uncommittedPatientBox.length} uncommitted patients');
    }

    initMethodCallHandler(this);
    if (isRegistered())
      initializeTimer(this);

    if (isCentral()) {
      bleDataSend.invokeMethod("startBle", {"version": getVersion(), "json": exportJson()});
    }

    deleteStaleRecords();
  }

  Future<dynamic> onChannelRead(MethodCall call) async {
    BinaryReaderImpl reader = BinaryReaderImpl(call.arguments as Uint8List, Hive);
    Patient p = PatientAdapter().read(reader);
    print('Merging ${p.getPatientId()} (${p.getDisplayableId()})...');
    if (await mergePatient(p, true)) {
      int version = this._ints.get('version') + 1;
      await this._ints.put('version', version);
      bleDataSend.invokeMethod("startBle", {"version": getVersion(), "json": exportJson()});
      return version;
    }
    return this._ints.get('version');
  }

  Future<void> putPatient(Patient patient) {
    return _patientBox.put(patient.getPatientId(), patient);
  }

  Patient getPatient(String patientId) {
    return _patientBox.get(patientId);
  }

  void putUncommittedPews(Patient p, Pews record) {
    Patient uncommitted = _uncommittedPatientBox.get(p.getPatientId());
    if (uncommitted == null) {
      uncommitted = Patient.withRecords(p, [record]);
    } else {
      uncommitted.addRecord(record, null);
    }

    print("Added pews record as uncommitted to ${p.getPatientId()} (${p.getDisplayableId()})");
    _uncommittedPatientBox.put(p.getPatientId(), uncommitted).then((_) {
      runImmediately(this);
    });
  }

  Future<void> putUncommittedPatient(Patient p) {
    Patient uncommitted = _uncommittedPatientBox.get(p.getPatientId());
    // Need to use given patient with existing pews
    // in case fields have been edited (age, etc)
    if (uncommitted != null) {
      uncommitted = Patient.withRecords(uncommitted, p.getPatientData());
    } else {
      uncommitted = Patient.withRecords(p, []);
    }

    print("Added new uncommitted patient ${p.getPatientId()} (${p.getDisplayableId()})");
    return _uncommittedPatientBox.put(p.getPatientId(), uncommitted);
  }

  int getVersion() {
    return _ints.get('version');
  }

  Future<void> setVersion(int to) {
    return _ints.put('version', to);
  }

  Future<void> commitUncommittedPatients(BluetoothCharacteristic dataCharacteristic) async {
    print("There are ${_uncommittedPatientBox.length} values to commit");
    for (Patient p in _uncommittedPatientBox.values) {
      var records = p.getPatientData();
      print("Attempting to commit ${records.length} records of ${p.getPatientId()} (${p.getDisplayableId()})");
      if (records.length == 0) {
        BinaryWriterImpl writer = BinaryWriterImpl(Hive);
        PatientAdapter().write(writer, p);
        await dataCharacteristic.write(writer.toBytes());
      } else {
        for (Pews pews in records) {
          BinaryWriterImpl writer = BinaryWriterImpl(Hive);
          PatientAdapter().write(writer, Patient.withRecords(p, [pews]));
          await dataCharacteristic.write(writer.toBytes());
        }
      }
      print("Successfully committed ${records.length} records of ${p.getPatientId()} (${p.getDisplayableId()})");
      _uncommittedPatientBox.delete(p.getPatientId());
    }
  }

  bool isNurseSenior() {
    if (_nurseBox == null || _nurseBox.isEmpty)
      return false;
    return _nurseBox.values.first;
  }

  void registerNewNurse(bool isSenior) {
    initializeTimer(this);
    this._nurseBox.put("nurse", isSenior);
  }

  bool isRegistered() {
    return _nurseBox.isNotEmpty;
  }

  void deleteStaleRecords() {
    DateTime time = DateTime.now().subtract(const Duration(hours: RECORD_DURATION));
    for (Patient p in _patientBox.values) {
      if (p.lastChanged.isBefore(time)) {
        _patientBox.delete(p.getPatientId());
      } else {
        if (p.removeAllRecordsWhere((pews) => pews.time.isBefore(time))) {
          _patientBox.put(p.getPatientId(), p);
        }
      }
    }
  }

  List<Patient> getAllPatients() {
    return _patientBox.values.toList();
  }

  void removePatient(String patientID) {
    _patientBox.delete(patientID);
  }
  
  String exportJson() {
    String usersJson = jsonEncode(_patientBox.values.toList());
    return usersJson;
  }

  // Returns true if changed
  Future<bool> mergePatient(Patient p, bool isCentralServer) async {
    Patient existing = getPatient(p.getPatientId());
    if (existing == null) {
      await putPatient(p);
      return true;
    }

    Patient newPatient = isCentralServer ? existing.withMergedData(p) : p.withMergedData(existing);
    if (newPatient == existing) {
      return false;
    }

    await putPatient(newPatient);
    return true;
  }

  Future<bool> mergePatients(List<Patient> patients) async {
    var awaitables = <Future<bool>>[];
    for (Patient p in patients) {
      awaitables.add(mergePatient(p, false));
    }
    bool changed = false;
    for (var awaitable in awaitables) {
      if (await awaitable) changed = true;
    }
    return changed;
  }

  Future<int> updateWithJson(String json) async {
    int isSuccessful = 0;
    try {
      bool changed = await mergePatients(jsonDecode(json).map<Patient>((i) => Patient.fromJson(i)).toList());
      print("updateWithJson did change database: $changed");
    } catch (e) {
      isSuccessful = 1;
    }
    return isSuccessful;
  }

  bool isCentral() {
    return this._ints.get('isCentral') != 0;
  }

  void acknowledged() {
    _ints.put("acknowledged", 1);
  }

  bool hasAcknowledged() {
    return _ints.containsKey("acknowledged");
  }

  void makeCentral() {
    cancelTimer();
    this._ints.put('isCentral', 1);
  }
}
