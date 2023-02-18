import 'package:flutter/material.dart';

class PuzzlePiece extends StatelessWidget {
  final int number;
  double width;
  double height;
  final double targetWidth;
  final double targetHeight;

  PuzzlePiece({
    required this.number,
    required this.width,
    required this.height,
    required this.targetWidth,
    required this.targetHeight,
  }){
    if(targetWidth > width && targetHeight > height) {
      width = targetWidth;
      height = targetHeight;
    }
    // print("puzzlePiece - number: ${this.number}");
    // print("puzzlePiece - width: ${this.width}");  
    // print("puzzlePiece - height: ${this.height}");
    // print("puzzlePiece - targetWidth: ${this.targetWidth}");
    // print("puzzlePiece - targetHeight: ${this.targetHeight}");
    // print("-------------------");
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/images/testpuzzel1/piece_$number.jpg';
    print("----------$height--------------");
    return Container(
      width: width,
      height: height,
      child: Draggable<String>(
        data: number.toString(),
        child: Image.asset(
          imagePath,
          width: width,
          fit: BoxFit.cover,
        ),
        childWhenDragging: Image.asset(
          imagePath,
          color: Colors.red.withOpacity(0.8),
          colorBlendMode: BlendMode.modulate,
        ),
        feedback: Image.asset(
          imagePath,
          width: targetWidth,
          color: Colors.blue.withOpacity(0.8),
          colorBlendMode: BlendMode.modulate,
        ),
      ),
    );
  }
}
