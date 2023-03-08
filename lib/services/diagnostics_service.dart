import 'dart:convert';

import 'package:http/http.dart' as http;

class DiagnosticsService {
  String finishedUrl = "localhost:5000/api/finished";
  String timeUpUrl = "localhost:5000/api/finished";

  Future<bool> sendLevelFinished(Map<String, dynamic> data) async {
    var response = await http.post(Uri.parse(finishedUrl), body: data);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return true;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return false;
    }
  }

  Map<String, dynamic> createPostMessage(
      String macAddress, int levelNumber, bool finished, int time) {
    return {
      "macAddress": macAddress,
      "levelNumber":levelNumber,
      "finished": finished,
      "time": time,
      "timestamp": DateTime.now()
    };
  }
}
