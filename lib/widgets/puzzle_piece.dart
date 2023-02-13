import 'package:flutter/material.dart';

class PuzzlePiece extends StatelessWidget {
  final int number;
  final double width;
  final double height;
  final double targetWidth;
  final double targetHeight;

  PuzzlePiece({
    required this.number,
    required this.width,
    required this.height,
    required this.targetWidth,
    required this.targetHeight,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/images/poep/piece_$number.jpg';
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(0),
      child: Draggable<String>(
        data: number.toString(),
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.fill,
            ),
            Text(number.toString())
          ],
        ),
        childWhenDragging: Image.asset(
          imagePath,
          fit: BoxFit.fill,
          color: Colors.red.withOpacity(0.8),
          colorBlendMode: BlendMode.modulate,
        ),
        feedback: Image.asset(
          imagePath,
          fit: BoxFit.fill,
          width: targetWidth,
          height: targetHeight,
          color: Colors.blue.withOpacity(0.8),
          colorBlendMode: BlendMode.modulate,
        ),
      ),
    );
  }
}
