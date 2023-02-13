import 'dart:io';

import 'package:first_app/widgets/puzzle_piece.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as service;
import 'package:yaml/yaml.dart';

import '../models/level.dart';
import '../widgets/puzzle_board.dart';

class PuzzleScreen extends StatefulWidget {
  static final screenRoute = "/puzzle";

  final int level;
  final String folderPath;

  PuzzleScreen(this.level, this.folderPath);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  bool puzzleWasInitialized = false;

  List<PuzzlePiece> pieces = [];
  List<Level> levels = [];

  void createNextLevel(int nextLevel) {}

  Future<void> getVariablesFromEnvironment() async {
    final String data =
        await service.rootBundle.loadString('assets/levels.yaml');
    final YamlList yamlData = loadYaml(data);
    List<dynamic> yamlDataList = yamlData[0]['levels'];
    Map<int, dynamic> yamlMap = yamlDataList.asMap();
    yamlMap.forEach(
      (key, value) {
        levels.add(Level(value['level${key + 1}'][0]['amountOfPieces'],
            value['level${key + 1}'][1]['levelPassed'] as bool));
      },
    );
    print(levels.toString());
  }

  void createPuzzlePieces(
    int amount,
  ) {
    double pieceWidth = MediaQuery.of(context).size.width / (amount / 2);
    double pieceHeight = MediaQuery.of(context).size.height / (amount / 2);
    if (pieces.isEmpty && !puzzleWasInitialized) {
      puzzleWasInitialized = true;
      for (int i = 0; i < amount; i++) {
        pieces.add(PuzzlePiece(
          width: pieceWidth,
          height: pieceHeight,
          targetWidth: pieceWidth,
          targetHeight: pieceHeight,
          number: i,
        ));
      }
    }
  }

  void removePieceFromPile(int pxNumber) {
    setState(() {
      pieces.removeWhere((element) {
        return element.number == pxNumber;
      });
    });
  }

  int verticalAmount = 3;
  int horizontalAmount = 3;
  double imageWidth = 100;
  double imageHeight = 80;

  @override
  Widget build(BuildContext context) {
    getVariablesFromEnvironment();
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Puzzle level ${widget.level}"),
        ),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IndexedStack(
                  children: [...pieces],
                ),
                Visibility(
                  child: Text("No more pieces left"),
                  visible: pieces.isEmpty,
                ),
                PuzzleBoard(
                  width: imageWidth,
                  height: imageHeight,
                  verticalSpaces: verticalAmount,
                  horizontalSpaces: horizontalAmount,
                  removeFromPile: removePieceFromPile,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
