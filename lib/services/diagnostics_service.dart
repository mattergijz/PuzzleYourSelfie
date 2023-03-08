import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class DiagnosticsService {
  String finishedUrl = "http://192.168.178.251:5000/api/finished";
  String timeUpUrl = "http://localhost:5000/api/finished";
  final headers = {'Content-Type': 'application/json'};

  Future<bool> sendLevelFinished(String data) async {
    var response = await http.post(Uri.parse(finishedUrl), body: data, headers: headers);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      return true;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return false;
    }
  }

  String createPostMessage(String macAddress, int levelNumber,
      bool finished, int time, int piecesLeft) {
        print(macAddress);
    return jsonEncode({
      "mac_address": macAddress.toString(),
      "level_number": levelNumber.toString(),
      "finished": finished.toString(),
      "time": time.toString(),
      "pieces_left": piecesLeft.toString(),
      "timestamp": DateTime.now().toString()
    });
  }
}
