import 'package:flutter/material.dart';

import './piece.dart';
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
  List<PuzzlePiece> pieces = [
    PuzzlePiece(width: 150, height: 100, number: 1),
    PuzzlePiece(width: 150, height: 100, number: 2),
    PuzzlePiece(width: 150, height: 100, number: 3),
    PuzzlePiece(width: 150, height: 100, number: 4)
  ];

  List<PuzzleTarget> targets = [];

  void removePieceFromPile(int pxNumber) {
    print("removing");
    setState(() {
      pieces.removeWhere((element) {
        return element.number == pxNumber;
      });
    });
    print("Length: ${pieces.length}");
  }

  void showModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Text('Modal bottom sheet', style: TextStyle(fontSize: 30));
      },
    );
  }
  //TODO when placing pieces, stack only gets updated the first time

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Puzzle Your Selfie'),
        ),
        body: Column(
          children: [
            IndexedStack(
              //TODO Make sure item gets removed from stack as well
              children: pieces,
            ),
            Visibility(
              child: Text("No more pieces left"),
              visible: pieces.isEmpty,
            ),
            PuzzleBoard(
                verticalSpaces: 2,
                horizontalSpaces: 2,
                removeFromPile: removePieceFromPile)
          ],
        ),
      ),
    );
  }
}
