import 'dart:collection';
import 'dart:io';
import 'dart:math';

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

  late Level currentLevel;

  void createNextLevel(Queue levels) {
    if (levels.isNotEmpty) {
      Level nextLevel = levels.last;
      createPuzzlePieces(nextLevel);
      levels.removeFirst();
    }
  }

  void createPuzzlePieces(Level level) {
    int amount = level.amountOfTiles;
    double pieceHeight = MediaQuery.of(context).size.height * 0.10;
    // double pieceWidth = MediaQuery.of(context).size.width / 3;
    double pieceWidth = pieceHeight;
    double targetWidth =
        (MediaQuery.of(context).size.width * 0.95) / sqrt(amount);
    double targetHeight = MediaQuery.of(context).size.height / sqrt(amount);
    print("____________");
    print(pieceWidth);
    print(targetWidth);
    if (pieces.isEmpty && !puzzleWasInitialized) {
      puzzleWasInitialized = true;
      for (int i = 0; i < amount; i++) {
        setState(() {
          pieces.add(PuzzlePiece(
            width: pieceWidth,
            height: pieceHeight,
            targetWidth: targetWidth,
            targetHeight: targetWidth,
            number: i,
          ));
        });
      }
    }
    pieces.shuffle();
  }

  void removePieceFromPile(int pxNumber) {
    setState(() {
      pieces.removeWhere((element) {
        return element.number == pxNumber;
      });
    });
  }

  double imageHeight = 100;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, Object>;
    currentLevel = arguments['level'] as Level;
    createPuzzlePieces(arguments['level'] as Level);
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              "Puzzle level ${widget.level}: ${currentLevel.amountOfTiles} pieces"),
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IndexedStack(
                  children: [...pieces],
                  sizing: StackFit.loose,
                ),
                Visibility(
                  child: Text("No more pieces left"),
                  visible: pieces.isEmpty,
                ),
                PuzzleBoard(
                  availableWidth: (MediaQuery.of(context).size.width * 0.95)
                      .floorToDouble(),
                  verticalSpaces: sqrt(currentLevel.amountOfTiles).toInt(),
                  horizontalSpaces: sqrt(currentLevel.amountOfTiles).toInt(),
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
