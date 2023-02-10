import 'dart:collection';

import 'package:flutter/material.dart';

import './piece.dart';

class PuzzlePiecesStack extends StatefulWidget {
  final List<PuzzlePiece> pieces;

  PuzzlePiecesStack(this.pieces);

  @override
  State<PuzzlePiecesStack> createState() => _PuzzlePiecesStackState();
}

class _PuzzlePiecesStackState extends State<PuzzlePiecesStack> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [...widget.pieces],
      ),
    );
  }
}
