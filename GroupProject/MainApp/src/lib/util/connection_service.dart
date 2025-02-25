import 'dart:io';
import 'package:http/http.dart' as http;

class ConnectionService {
  static String getRequestUrl(String url, String token) {
    String requestUrl = url;
    if (requestUrl.endsWith("/hospitals") ||
        requestUrl.endsWith("/hospitals/")) {
      if (requestUrl[requestUrl.length - 1] != '/')
        requestUrl += '/' + token;
      else
        requestUrl += token;
      return requestUrl;
    }

    if (requestUrl[requestUrl.length - 1] != '/')
      requestUrl += '/hospitals/' + token;
    else
      requestUrl += 'hospitals/' + token;

    return requestUrl;
  }

  static Future<bool> tryToRegisterSenior(String url, String token) async {
    String requestUrl = getRequestUrl(url, token);
    try {
      var resp = await http.get(requestUrl,
          headers: {HttpHeaders.acceptHeader: "application/json"});
      return resp.statusCode == 200;
    } catch (e) {
      return Future.value(false);
    }
  }
}
