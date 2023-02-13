import 'package:flutter/material.dart';

import './puzzle_target.dart';

class PuzzleBoard extends StatelessWidget {
  final int verticalSpaces;
  final int horizontalSpaces;

  final double width;
  final double height;

  final Function removeFromPile;

  PuzzleBoard(
      {required this.verticalSpaces,
      required this.horizontalSpaces,
      required this.removeFromPile,
      required this.width,
      required this.height});

  List<PuzzleTarget> createTargets() {
    List<PuzzleTarget> targets = [];
    int totalSpaces = horizontalSpaces * verticalSpaces;
    for (int i = 0; i < totalSpaces; i++) {
      targets.add(
        PuzzleTarget(
          width: width,
          height: height,
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
      width: width * horizontalSpaces,
      height: height * verticalSpaces,
      child: GridView.count(
        childAspectRatio: width / height,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: horizontalSpaces,
        shrinkWrap: true,
        children: [...createTargets()],
      ),
    );
  }
}
