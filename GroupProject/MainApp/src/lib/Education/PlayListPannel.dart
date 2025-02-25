import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'VideosPannel.dart';
class PlayList {
  String name;
  String filePath;

  PlayList(this.name, this.filePath);

}

class PlayListButton extends StatelessWidget {

  PlayList buttonPlaylist;

  PlayListButton (this.buttonPlaylist);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => MaterialApp(
                  home: Scaffold(
                      appBar: AppBar(

                          title: Text(buttonPlaylist.name),
                        automaticallyImplyLeading: true,
                          leading: IconButton(icon:Icon(Icons.arrow_back), color: Colors.black,
                            onPressed: () {Navigator.pop(context);}),

                      ),
                      body : VideoList(buttonPlaylist.name)

              )
          )
          ));
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return null; // Use the component's default.
            },
          ),
        ),
        child: Text(buttonPlaylist.name));
  }

}


class PlayListList extends StatefulWidget {

  PlayListList() :super();

    @override
    _PlayListListState createState() => _PlayListListState();
  }


  class _PlayListListState extends State<PlayListList> {
  String _jsonString;
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/AllVideos.json');
  }


  void readJson() async{
    try {
      final file =  await _localFile;

      // Read the file.
      String contents = await file.readAsString();
      setState(() {
        _jsonString = contents;
      });

    } catch (e) {
      // If encountering an error, return 0.

    }
  }
  @override
  Widget build(BuildContext context) {
    readJson();
    final ButtonList = <Widget>[];
    if (_jsonString != null) {
      List allCata = json.decode(_jsonString);

      for (int i = 0; i < allCata.length; i++) {
        ButtonList.add(new PlayListButton (
            new PlayList(allCata[i]["category"], allCata[i]["category"])));
      }
    }

    return new ListView(
      children: ButtonList,
    );
  }

}

