import 'package:flutter/material.dart';

class PuzzlePiece extends StatelessWidget {
  final int number;
  final double height;
  final double width;

  PuzzlePiece(
      {required this.width, required this.height, required this.number}) {}
  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/images/poep/test$number.jpg';
    return Container(
      width: height,
      height: width,
      padding: EdgeInsets.all(0),
      child: LongPressDraggable<String>(
        data: number.toString(),
        child: RotatedBox(
          quarterTurns: 1,
          child: Image.asset(
            imagePath,
            fit: BoxFit.fill,
          ),
        ),
        childWhenDragging: Image.asset(
          imagePath,
          fit: BoxFit.fill,
          color: Colors.white.withOpacity(0.8),
          colorBlendMode: BlendMode.modulate,
        ),
        feedback: Image.asset(
          imagePath,
          fit: BoxFit.fill,
          color: Colors.white.withOpacity(0.8),
          colorBlendMode: BlendMode.modulate,
        ),
      ),
    );
  }
}
