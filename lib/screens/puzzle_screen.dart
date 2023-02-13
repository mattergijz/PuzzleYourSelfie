import 'package:first_app/widgets/puzzle_piece.dart';
import 'package:flutter/material.dart';
import "package:flutter/services.dart" as service;
import "package:yaml/yaml.dart";

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

  Future<void> createNextLevel(int nextLevel) async {
    final data = await service.rootBundle.loadString('assets/levels.yaml');
    final List<Map<String, Object>> levelData = loadYaml(data);
    print(levelData[0]);
    // print(levelData['level${widget.level.toString()}']);
    // if (widget.level == 1) {
    //   createPuzzlePieces(levelData['level${widget.level}']);
    //   return;
    // }
    // if (levelData['level$nextLevel'] != null) {

    // }
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
    createNextLevel(1);
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
