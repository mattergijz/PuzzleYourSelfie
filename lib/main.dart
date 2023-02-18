import 'dart:collection';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as service;
import 'package:image_picker/image_picker.dart';

import '../screens/puzzle_screen.dart';
import '../screens/select_level_screen.dart';

import 'package:yaml/yaml.dart';

import 'models/level.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        PuzzleScreen.screenRoute: (context) =>
            PuzzleScreen(1, "assets/images/poep"),
        SelectLevelScreen.screenRoute: (context) => SelectLevelScreen(),
      },
      initialRoute: "/",
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Level> levels = [];

  bool dataLoading = true;

  Map<String, Object> arguments = new Map();

  Future<void> getVariablesFromEnvironment() async {
    final String data =
        await service.rootBundle.loadString('assets/levels.yaml');
    final YamlList yamlData = loadYaml(data);
    List<dynamic> yamlDataList = yamlData[0]['levels'];
    Map<int, dynamic> yamlMap = yamlDataList.asMap();
    yamlMap.forEach(
      (key, value) {
        levels.add(Level(
            value['level${key + 1}'][0]['number'],
            value['level${key + 1}'][1]['amountOfPieces'],
            value['level${key + 1}'][2]['levelPassed'] as bool));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getVariablesFromEnvironment().then((_) {
      arguments['levels'] = levels;
      setState(() {
        dataLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Your Selfie'),
      ),
      body: Center(
        child: dataLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        SelectLevelScreen.screenRoute,
                        arguments: arguments,
                      );
                    },
                    child: Text("Go to level selector"),
                  ),
                ],
              ),
      ),
    );
  }
}
