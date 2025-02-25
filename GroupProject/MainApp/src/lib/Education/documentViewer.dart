import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/image_properties.dart';
import 'dart:convert';
import 'DocumentsPannel.dart';
import 'package:http/http.dart' as http;

class docuementViewer extends StatefulWidget {
  Document docObj;

  docuementViewer( {Key key, @required this.docObj}) : super(key: key);
  @override
  _docuementViewerState createState() {
    return _docuementViewerState();
  }

}

class _docuementViewerState extends State<docuementViewer> {
  var _jsonString;


  void getjson(var url) async {
    var temp = await http.get(url);
    setState(() {
      _jsonString = temp;
    });

  }


  @override
  void initState(){
    super.initState();

    var url = Uri.https('echo.server.mrbbot.dev', '/sections/' + widget.docObj.id , {'q': '{http}'}).toString();
    getjson(url);
    // Await the http get response, then decode the json-formatted response.

  }

  @override
  Widget build(BuildContext context) {

      if (_jsonString != null && _jsonString.statusCode == 200) {
        var jsonResponse = json.decode(_jsonString.body);
        return Scaffold(
            appBar: AppBar(title: Text(jsonResponse["title"])),
            body: InteractiveViewer(
              child: SingleChildScrollView (
                child : Html(

                  data: "<!DOCTYPE html><html><body>" +
                      jsonResponse["body"].replaceAllMapped(
                          new RegExp("/uploads/", caseSensitive: true),
                              (
                              Match m) => "https://echo.server.mrbbot.dev/uploads/") +
                      " </body></html> ",
                  useRichText: true,

                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  defaultTextStyle: TextStyle(fontSize: 14),
                  imageProperties: ImageProperties(
                    //formatting images in html content


                  ),
                ),
              ),
            ),
        );
      }
      else {

        return Scaffold(
            appBar: AppBar(title: Text('Loading'))
        );
      }

  }


}