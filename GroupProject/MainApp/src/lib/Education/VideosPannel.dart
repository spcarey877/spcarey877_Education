import 'package:flutter/material.dart';
import 'VideoPlayer.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Video {
  String name;
  String url;

  Video(this.name, this.url);

}

class VideoButton extends StatelessWidget {

  Video buttonVid;

  VideoButton (Video myVid) {
    buttonVid = myVid;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => VideoPlayerApp(VideoObject: buttonVid) ));
          },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return null; // Use the component's default.
            },
          ),
        ),
        child: Text(buttonVid.name));
  }

}

class VideoList extends StatefulWidget {
  String cata;

  VideoList(this.cata) : super();

  @override
  _VideoListState createState() => _VideoListState();

}

class _VideoListState extends State<VideoList> {
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
  void initState(){
    super.initState();
  }

  @override
  build(BuildContext context){
    String cata = widget.cata;
    readJson();
    List VideoList = <Widget>[];
    if(_jsonString != null) {
      List allCata = json.decode(_jsonString);


      for (int i = 0; i < allCata.length; i++) {
        List cataVids = allCata[i]["videos"];

        if (cata == "" || cata == allCata[i]["category"]) {
          for (int j = 0; j < cataVids.length; j++) {
            VideoList.add(new VideoButton(
                new Video(cataVids[j]["title"], cataVids[j]["url"])));
          }
        }
      }
    }

    /*for (var i = 0; i < _items.length ; i++) {
      VideoList.add(new VideoButton(new Video( _items[i]["name"], _items[i]["path"])));
    }*/
    return new ListView(children: VideoList);
  }

}


