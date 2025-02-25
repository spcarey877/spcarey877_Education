import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:main_app/Education/DocumentsPannel.dart';
import 'package:path_provider/path_provider.dart';
import 'mylib.dart';
import 'Education/VideosPannel.dart';
import 'Education/PlayListPannel.dart';


class EducationalVideos extends StatelessWidget {
  Database _db;
  EducationalVideos(this._db);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String name) async {
    final path = await _localPath;
    return File('$path$name');
  }

  Future<File> writedata(var data, String name ) async {
    final file = await _localFile(name);

    // Write the file.
    return file.writeAsString('$data');
  }


  @override
  Widget build(BuildContext context) {
      return DefaultTabController(
          length: 3,
          child: Scaffold(
          drawer: MyDrawerStateful(this._db),

            appBar: AppBar(
              automaticallyImplyLeading: true,
              leading: IconButton(icon:Icon(Icons.arrow_back), color: Colors.black,
                  onPressed: () {Navigator.pop(context);}),
              title: Text('Education Section'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.download_sharp),

                  onPressed: () async {
                    var url = Uri.https('echo.server.mrbbot.dev', '/videos/', {'q': '{http}'}).toString();

                      // Await the http get response, then decode the json-formatted response.
                      var response = await http.get(url);
                      if (response.statusCode == 200) {
                        writedata(response.body, "/AllVideos.json");
                      }
                      else {
                        print('Request failed with status: ${response.statusCode}.');

                      }

                    url = Uri.https('echo.server.mrbbot.dev', '/sections/', {'q': '{http}'}).toString();

                    // Await the http get response, then decode the json-formatted response.
                    response = await http.get(url);
                    if (response.statusCode == 200) {

                      writedata(response.body, "/AllDocs.json");
                    }
                    else {
                      print('Request failed with status: ${response.statusCode}.');
                    }


                  }

                ),
              ],
              bottom: TabBar(
                tabs: [

                  Tab(text: 'All Courses',),
                  Tab(text: 'All Videos',),
                  Tab(text: 'All Documents', ),
                ],
              ),

            ),
            body: TabBarView(
              children: [
                PlayListList(),
                VideoList(""),
                DocList(jsonName: "VideoAssets/AllDocs.json")
                ,
              ],
            ),
          ),
        );

  }


}