import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:main_app/database.dart';
import 'package:main_app/util/channels.dart';

const String DATA_CHARACTERISTIC_STRING = "d615735f-203c-4c79-ba8f-557214dccc29";
final Guid DATA_CHARACTERISTIC = Guid(DATA_CHARACTERISTIC_STRING);
final Guid OFFSET_CHARACTERISTIC = Guid("93A7EFA3-8480-43DF-8C23-32E8622F39BE");
final Guid AUTH_CHARACTERISTIC = Guid("9A725712-F28E-4251-96EC-E20C09298AF3");


class SendDataPage extends StatefulWidget {
  final bool _isAuthorizing;

  SendDataPage(this._isAuthorizing);

  @override
  SendDataState createState() => SendDataState(_isAuthorizing);
}

class SendDataState extends State<SendDataPage> {
  var _serverClosed = false;
  bool _isAuthorizing;

  SendDataState(this._isAuthorizing) {
      registerOnAuth(() {
        setState(() {
          _serverClosed = true;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(padding: EdgeInsets.all(20), children: [
          SizedBox(height: 150),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: _serverClosed ? Colors.blue : Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  )
                ]),
            padding: EdgeInsets.all(20),
            child: Column(
              children: _serverClosed ? [
                Text("Successfully sent authorisation!")
              ] : [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                    _isAuthorizing ?
                    "You are sending the authorization. Please tell the registering nurse to scan for devices." :
                    "You are acting as a server.")
              ],
            ),
          ),
        ]));
  }

}

class ReceiveDataStartPage extends StatelessWidget {
  Database _db;

  ReceiveDataStartPage(this._db);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Senior Nurse"),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((r) {
                        //if (!r.advertisementData.serviceUuids.contains(DATA_CHARACTERISTIC_STRING))  return null;
                        return ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            // Platform.isIOS ? r.device.connect() :
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? r.device.connect()
                                : r.device.connect(autoConnect: false);
                            return SwapDataScreen(_db,
                                device: r.device);
                          })),
                        );
                    }).where((r) => r != null)
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

Future<int> exchangeData(List<BluetoothService> services, BluetoothDevice device, bool needsAuthorization, Database db) async {
  int _isSuccessful = 0;

  BluetoothCharacteristic data;
  BluetoothCharacteristic offset;
  if (needsAuthorization) {
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == AUTH_CHARACTERISTIC) {
          data = characteristic;
          break;
        }
      }
    }

    if (data == null) {
      device.disconnect();
      _isSuccessful = 1;
      return _isSuccessful;
    }
    List<int> bytes = await data.read();
    device.disconnect();
    print(utf8.decode(bytes));
    _isSuccessful = utf8.decode(bytes) == 'TEST' ? 0 : 1;
    return _isSuccessful;
  }

  int mtu = await device.mtu.first;
  print("Mtu is " + mtu.toString());
  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.uuid == DATA_CHARACTERISTIC) {
        data = characteristic;
      } else if (characteristic.uuid == OFFSET_CHARACTERISTIC) {
        offset = characteristic;
      }
    }
  }

  if (data == null && offset == null) {
    device.disconnect();
    return -1;
  }

  print("Committing any uncommitted patients...");
  await db.commitUncommittedPatients(data);

  int failures = 10;
  int currentChunkSize = mtu;
  int size = -1;
  int dataVer = -1;
  List<int> received = <int>[];
  int receivedVer = -1;
  while (true) {
    if (failures == 0) {
      _isSuccessful = -1;
      size = -1;
      break;
    }

    List<int> readBytes = await data.read();
    print("BLE read: Read ${readBytes.length} bytes (of expected $currentChunkSize) (${readBytes.take(16).toList()}, \"${utf8.decode(readBytes.skip(8).toList(), allowMalformed: true)}\")");
    if (readBytes.length < 8) {
      print("BLE read: Invalid number of bytes");
      _isSuccessful = -1;
      size = -1;
      break;
    }

    receivedVer = (readBytes[0] & 0x7F) | (readBytes[1] << 8) | (readBytes[2] << 16) | (readBytes[3] << 24);
    bool isFirst = receivedVer & ~2147483647 != 0;
    receivedVer &= 2147483647;
    if (isFirst) {
      received = [];
    }
    if (receivedVer != dataVer) {
      print("BLE read: Differing version (Was: $dataVer)");
      received = <int>[];
      dataVer = receivedVer;
      if (--failures == 0) continue;
    }

    int receivedSize = readBytes[4] | (readBytes[5] << 8) | (readBytes[6] << 16) | (readBytes[7] << 24);
    bool writeOffset = false;
    if (isFirst) {
      print("BLE read: Expecting $receivedSize bytes");
      size = receivedSize;
      received.addAll(readBytes.skip(8));
    } else {
      print("BLE read: Given offset $receivedSize");
      if (receivedSize != received.length) {
        print("BLE read: Invalid offset (Missing or repeated bytes)");
        // Sent for invalid offset. Write to offset characteristic to reset
        writeOffset = true;
        if (--failures == 0) continue;
      } else {
        received.addAll(readBytes.skip(8));
      }
    }

    if (received.length == size) {
      print("BLE read: Done");
      break;
    }

    if (writeOffset) {
      List<int> toSend = <int>[
        dataVer & 0xFF, (dataVer >> 8) & 0xFF,
        (dataVer >> 16) & 0xFF, (dataVer >> 24) & 0xFF,
        received.length & 0xFF, (received.length >> 8) & 0xFF,
        (received.length >> 16) & 0xFF, (received.length >> 24) & 0xFF
      ];
      print("BLE read: Writing offset ${toSend} (chunkSize: $currentChunkSize)");
      await offset.write(toSend);
    }
  }

  device.disconnect();

  if (received.length == size) {
    String decodedString = utf8.decode(received);
    print(decodedString);
    _isSuccessful = await db.updateWithJson(decodedString);
    if (receivedVer != -1) await db.setVersion(receivedVer);
  }

  return _isSuccessful;
}

class SwapDataScreen extends StatelessWidget {
  final Database _db;
  int _isSuccessful = 0;

  SwapDataScreen(this._db, {Key key, this.device})
      : super(key: key);

  final BluetoothDevice device;

  bool check(String parsedData) {
    return parsedData.isEmpty;
  }


  Future<List<Widget>> _buildServiceTiles(
      List<BluetoothService> services, BluetoothDevice device) async {
    _isSuccessful = await exchangeData(services, device, true, _db);
    if (_isSuccessful == 0) {
      _db.registerNewNurse(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool requestedData = false;
    //bool requestedMtu = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      appBar: AppBar(
        title: Text("Receiving Authorization",
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
                stream: device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (c, snapshot) {
                  if (snapshot.data == BluetoothDeviceState.connected &&
                      !requestedData) {
                    requestedData = true;
                    /*if (!requestedMtu)
                      {
                        device.requestMtu(512);
                        requestedMtu = true;
                      }*/
                    device.discoverServices().then((s) {
                      _buildServiceTiles(s, device);
                    });
                  }
                  if (snapshot.data == BluetoothDeviceState.disconnected && requestedData) {
                    return createAlertDialog(_isSuccessful, context, _db);
                  }
                  return ButtonBarTheme(
                          data: ButtonBarThemeData(
                              alignment: MainAxisAlignment.center),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data == BluetoothDeviceState.connecting
                                    ? "Connecting..."
                                    : "Receiving authorization..." ,
                                style: TextStyle(color: Colors.blueAccent),
                              )
                            ],
                          )
                      );
                })
          ],
        ),
      ),
    );
  }
}

Widget createAlertDialog(
    int isSuccesful, BuildContext context, Database db) {
  String textToDisplay = isSuccesful == 0
      ? "You were authorized, you can continue to use the app."
      : "There was an error receiving the authorization from the sender.";
  Color color = isSuccesful == 0 ? Colors.green : Colors.red;

  return WillPopScope(
      child: ButtonBarTheme(
          data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
          child: AlertDialog(
              title: SelectableText.rich(
                TextSpan(
                  text: textToDisplay,
                  style: TextStyle(color: color, fontSize: 25),
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('OK'),
                  onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      if (isSuccesful == 0) {
                        while(Navigator.of(context).canPop())
                          Navigator.of(context).pop();
                      }
                  },
                )
              ])),
      onWillPop: () async => false);
}

class ScanResultTile extends StatelessWidget {

  const ScanResultTile({Key key, this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: RaisedButton(
        child: Text("Receive Auth"),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: onTap //(result.advertisementData.connectable) ? onTap : null,
      ),
      children: <Widget>[
        _buildAdvRow(
            context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level',
            '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(
            context,
            'Manufacturer Data',
            getNiceManufacturerData(
                    result.advertisementData.manufacturerData) ??
                'N/A'),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data',
            getNiceServiceData(result.advertisementData.serviceData) ?? 'N/A'),
      ],
    );
  }
}
