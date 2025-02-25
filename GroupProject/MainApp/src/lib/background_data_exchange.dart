import 'dart:async';

import 'package:main_app/util/background_bluetooth.dart';

import 'database.dart';

Timer timer;

const Duration _updateInterval = const Duration(minutes: 15);

void initializeTimer(Database db) {
  if (!db.isCentral() && timer == null) {
    timer = Timer.periodic(_updateInterval, (timer) {
      backgroundScan(db);
    });
  }
}

void cancelTimer() {
  timer = null;
}

void runImmediately(Database db) {
  if (timer != null) {
    timer.cancel();
    backgroundScan(db);
    timer = Timer.periodic(_updateInterval, (timer) {
      backgroundScan(db);
    });
  }
}
