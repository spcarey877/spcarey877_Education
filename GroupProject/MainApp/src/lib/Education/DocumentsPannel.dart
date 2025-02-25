import 'package:flutter/material.dart';
import 'package:main_app/Education/documentViewer.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Document {
  String name;
  String id;

  Document(this.name, this.id);

}

class DocsButton extends StatelessWidget {

  Document butttonDoc;

  DocsButton (Document myVid) {
    butttonDoc = myVid;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => docuementViewer(docObj: butttonDoc) ));
          },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return null; // Use the component's default.
            },
          ),
        ),
        child: Text(butttonDoc.name));
  }

}

class DocList extends StatefulWidget {
  String jsonName;

  DocList({this.jsonName}) : super();

  @override
  _DocListState createState() => _DocListState();

}

class _DocListState extends State<DocList> {
  String _jsonString;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/AllDocs.json');
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
  build(BuildContext context){


    List DocList = <Widget>[];
    readJson();
    if (_jsonString != null) {
      List allCata = json.decode(_jsonString);

      for (int i = 0; i < allCata.length; i++) {
        List cataDocs = allCata[i]["sections"];

        for (int j = 0; j < cataDocs.length; j++) {
          DocList.add(new DocsButton(new Document(
              cataDocs[j]["title"], cataDocs[j]["id"].toString())));
        }
      }
    }

    return new ListView(children: DocList);
  }


}


