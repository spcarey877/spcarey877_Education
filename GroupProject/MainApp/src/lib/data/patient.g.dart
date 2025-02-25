// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      fields[0] as String,
      fields[2] as int,
      fields[3] as bool,
      fields[4] as String,
    )
      .._recordedData = (fields[1] as List)?.cast<Pews>()
      ..lastChanged = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj._patientId)
      ..writeByte(1)
      ..write(obj._recordedData)
      ..writeByte(2)
      ..write(obj._age)
      ..writeByte(3)
      ..write(obj._newborn)
      ..writeByte(4)
      ..write(obj._displayableId)
      ..writeByte(5)
      ..write(obj.lastChanged);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
