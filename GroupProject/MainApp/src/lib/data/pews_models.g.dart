// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pews_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RespiratoryDistressLevelsAdapter
    extends TypeAdapter<RespiratoryDistressLevels> {
  @override
  final int typeId = 3;

  @override
  RespiratoryDistressLevels read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RespiratoryDistressLevels.Severe_apnoea;
      case 1:
        return RespiratoryDistressLevels.Moderate;
      case 2:
        return RespiratoryDistressLevels.Mild;
      case 3:
        return RespiratoryDistressLevels.None;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, RespiratoryDistressLevels obj) {
    switch (obj) {
      case RespiratoryDistressLevels.Severe_apnoea:
        writer.writeByte(0);
        break;
      case RespiratoryDistressLevels.Moderate:
        writer.writeByte(1);
        break;
      case RespiratoryDistressLevels.Mild:
        writer.writeByte(2);
        break;
      case RespiratoryDistressLevels.None:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RespiratoryDistressLevelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AVPULevelsAdapter extends TypeAdapter<AVPULevels> {
  @override
  final int typeId = 4;

  @override
  AVPULevels read(BinaryReader reader) {
    switch (reader.readByte()) {
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

  @override
  void write(BinaryWriter writer, AVPULevels obj) {
    switch (obj) {
      case AVPULevels.Alert:
        writer.writeByte(0);
        break;
      case AVPULevels.Voice:
        writer.writeByte(1);
        break;
      case AVPULevels.Pain:
        writer.writeByte(2);
        break;
      case AVPULevels.Unresponsive:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AVPULevelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CNSLevelsAdapter extends TypeAdapter<CNSLevels> {
  @override
  final int typeId = 5;

  @override
  CNSLevels read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CNSLevels.Floppy_Not_Feeding;
      case 1:
        return CNSLevels.Poor_Feeding_Irritable;
      case 2:
        return CNSLevels.Active_Feeding_Well;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, CNSLevels obj) {
    switch (obj) {
      case CNSLevels.Floppy_Not_Feeding:
        writer.writeByte(0);
        break;
      case CNSLevels.Poor_Feeding_Irritable:
        writer.writeByte(1);
        break;
      case CNSLevels.Active_Feeding_Well:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CNSLevelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PewsAdapter extends TypeAdapter<Pews> {
  @override
  final int typeId = 1;

  @override
  Pews read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pews()
      ..time = fields[0] as DateTime
      ..totalScore = fields[1] as int
      ..temp = fields[2] as double
      ..heartRate = fields[3] as int
      ..respiratoryRate = fields[4] as int
      ..respiratoryDistress = fields[5] as RespiratoryDistressLevels
      ..oxygenSaturation = fields[6] as double
      ..roomAir = fields[7] as bool
      ..oxygenDelivery = fields[8] as double
      ..capillaryRefill = fields[9] as double
      ..bloodPressureSystolic = fields[10] as int
      ..bloodPressureDiastolic = fields[11] as int
      ..pulsePressure = fields[12] as int
      ..AVPU = fields[13] as AVPULevels
      ..CNS = fields[14] as CNSLevels
      ..isCompleted = fields[15] as bool;
  }

  @override
  void write(BinaryWriter writer, Pews obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.totalScore)
      ..writeByte(2)
      ..write(obj.temp)
      ..writeByte(3)
      ..write(obj.heartRate)
      ..writeByte(4)
      ..write(obj.respiratoryRate)
      ..writeByte(5)
      ..write(obj.respiratoryDistress)
      ..writeByte(6)
      ..write(obj.oxygenSaturation)
      ..writeByte(7)
      ..write(obj.roomAir)
      ..writeByte(8)
      ..write(obj.oxygenDelivery)
      ..writeByte(9)
      ..write(obj.capillaryRefill)
      ..writeByte(10)
      ..write(obj.bloodPressureSystolic)
      ..writeByte(11)
      ..write(obj.bloodPressureDiastolic)
      ..writeByte(12)
      ..write(obj.pulsePressure)
      ..writeByte(13)
      ..write(obj.AVPU)
      ..writeByte(14)
      ..write(obj.CNS)
      ..writeByte(15)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PewsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
