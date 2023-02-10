import 'package:flutter/material.dart';

import './puzzle_target.dart';

class PuzzleBoard extends StatelessWidget {
  final int verticalSpaces;
  final int horizontalSpaces;
  // final List<PuzzleTarget> targets;
  final Function removeFromPile;

  PuzzleBoard(
      {required this.verticalSpaces,
      required this.horizontalSpaces,
      required this.removeFromPile});

  List<PuzzleTarget> createTargets() {
    List<PuzzleTarget> targets = [];
    int totalSpaces = horizontalSpaces * verticalSpaces;
    for (int i = 0; i < totalSpaces; i++) {
      targets.add(
        PuzzleTarget(
          correctImageNumber: i + 1,
          removePieceFromPile: removeFromPile,
        ),
      );
    }
    return targets;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: horizontalSpaces,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: List.generate((verticalSpaces * horizontalSpaces), (index) {
        return PuzzleTarget(
            correctImageNumber: index + 1, removePieceFromPile: removeFromPile);
      }),
    );
  }
}
