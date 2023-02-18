import 'package:flutter/material.dart';

import './puzzle_target.dart';

class PuzzleBoard extends StatelessWidget {
  final int verticalSpaces;
  final int horizontalSpaces;
  final double availableWidth;

  final Function removeFromPile;

  PuzzleBoard(
      {required this.verticalSpaces,
      required this.horizontalSpaces,
      required this.removeFromPile,
      required this.availableWidth
      });

  List<PuzzleTarget> createTargets() {
    List<PuzzleTarget> targets = [];
    int totalSpaces = horizontalSpaces * verticalSpaces;
    for (int i = 0; i < totalSpaces; i++) {
      targets.add(
        PuzzleTarget(
          width: availableWidth / horizontalSpaces,
          height: availableWidth / verticalSpaces,
          correctImageNumber: i,
          removePieceFromPile: removeFromPile,
        ),
      );
    }
    return targets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: availableWidth,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: horizontalSpaces,
        shrinkWrap: true,
        children: [...createTargets()],
      ),
    );
  }
}
