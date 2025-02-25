import 'package:flutter/services.dart';
import 'package:main_app/database.dart';

const MethodChannel bleDataSend = const MethodChannel('ble-data/send');

void initMethodCallHandler(Database db) {
  bleDataSend.setMethodCallHandler((call) {
    print('${call.method} has been invoked on ble-data/send');
    if (call.method == 'closeAuth') {
      if (_onAuth != null) _onAuth();
      _onAuth = null;
      return Future.value();
    } else if (call.method == 'dataRead') {
      return db.onChannelRead(call);
    }

    return Future.value();
  });
}

typedef onAuthCallback = void Function();
onAuthCallback _onAuth;

void registerOnAuth(onAuthCallback f) {
  if (f == null) return;
  if (_onAuth != null) {
    var next = _onAuth;
    _onAuth = () {
      f();
      next();
    };
  } else _onAuth = f;
}

