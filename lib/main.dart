import 'dart:math';

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';
import './puzzle_board.dart';
import './puzzle_target.dart';
import './puzzle_pieces_stack.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  List<PuzzlePiece> pieces = [];

  List<PuzzleTarget> targets = [];

  void removePieceFromPile(int pxNumber) {
    setState(() {
      pieces.removeWhere((element) {
        return element.number == pxNumber;
      });
    });
  }

  void createPuzzlePieces(
    int amount,
    double pieceWidth,
    double pieceHeight,
  ) {
    if (pieces.isEmpty) {
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

  int verticalAmount = 3;
  int horizontalAmount = 3;
  double imageWidth = 100;
  double imageHeight = 80;

  @override
  Widget build(BuildContext context) {
    createPuzzlePieces(
      verticalAmount * horizontalAmount,
      imageWidth,
      imageHeight,
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Puzzle Your Selfie'),
        ),
        body: Column(
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
    );
  }
}
