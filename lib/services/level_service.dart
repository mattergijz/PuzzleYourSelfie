import 'package:flutter/services.dart' as service;
import 'package:yaml/yaml.dart';

import '../models/level_model.dart';

class LevelService {
  static List<Level> levels = [];
  static List<Level> levelsNotDone = [];
  static List<Level> levelsDone = [];
  static bool allLevelsPassed = false;
  static bool timerActive = true;

  static removeFromLevels(Level level) {
    levels.remove(level);
  }

  static passLevel(Level level) {
    int levelNumber = level.number;
    int index = levels.indexWhere((level) => level.number == levelNumber);
    levels[index].passed = true;
    levelsDone.add(level);
    levelsNotDone.remove(level);
    print(levels);
    for (Level level in LevelService.levels) {
      if (!level.passed) {
        return;
      }
    }
    allLevelsPassed = true;
  }
  static Future<void> getVariablesFromEnvironment() async {
    levels = [];
    levelsDone = [];
    levelsNotDone = [];
    allLevelsPassed = false;
    final String data =
        await service.rootBundle.loadString('assets/levels.yaml');
    final YamlMap yamlData = loadYaml(data);
    List<dynamic> yamlDataList = yamlData['levels'];
    Map<int, dynamic> yamlMap = yamlDataList.asMap();
    yamlMap.forEach(
      (key, value) {
        Level tempLevel = Level(
              value['level ${key + 1}'][0]['number'],
              value['level ${key + 1}'][1]['verticalAmount'] as int,
              value['level ${key + 1}'][2]['horizontalAmount'] as int,
              value['level ${key + 1}'][3]['time'],
              value['level ${key + 1}'][4]['passed'] as bool);
        levels.add(tempLevel);
        tempLevel.passed ? levelsDone.add(tempLevel) : levelsNotDone.add(tempLevel);
      },
    );
  }
}
