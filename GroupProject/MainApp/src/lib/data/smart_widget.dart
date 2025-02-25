import 'package:flutter/cupertino.dart';
import 'package:main_app/database.dart';

abstract class SmartWidget extends StatelessWidget {
  Database _db;
  SmartWidget(this._db);

  Database getDb() {
    return this._db;
  }
}

