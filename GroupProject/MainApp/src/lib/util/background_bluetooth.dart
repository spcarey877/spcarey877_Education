import 'package:flutter_blue/flutter_blue.dart';
import 'package:main_app/database.dart';
import 'package:main_app/exchange_data.dart';
import 'package:main_app/main.dart';

void backgroundScan(Database db) async {
  String serverName = "Central Server"; // db.getMacAddress

    for (ScanResult scanResult in await FlutterBlue.instance.startScan(timeout: Duration(seconds: 4))) {
      print(scanResult.device.name);
      if (scanResult.device.name == serverName) {
        try {
          print(isIos);
          await (isIos
              ? scanResult.device.connect(timeout: Duration(seconds: 30))
              : scanResult.device
                  .connect(autoConnect: false, timeout: Duration(seconds: 30)));
          print("Finished connecting");
          var s = await scanResult.device.discoverServices();
          print(s);
          await exchangeData(s, scanResult.device, false, db);
          return;
        } catch (e) {
          //Someone else is connected try again later
          return;
        }
      }
  }
}
