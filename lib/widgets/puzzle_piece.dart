import 'package:first_app/screens/puzzle_screen.dart';
import 'package:flutter/material.dart';

class PuzzlePiece extends StatefulWidget {
  final int number;
  // double width;
  // double height;
  // final double targetWidth;
  // final double targetHeight;
  final Image image;
  final Size imageSize;
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;


  PuzzlePiece(
      {required this.number,
      // required this.width,
      // required this.height,
      // required this.targetWidth,
      // required this.targetHeight,
      required this.image,
      required this.imageSize,
      required this.row,
      required this.col,
      required this.maxRow,
      required this.maxCol,
}) {
    // if (targetWidth > width && targetHeight > height) {
    //   width = targetWidth;
    //   height = targetHeight;
    // }
    // print("puzzlePiece - number: ${this.number}");
    // print("puzzlePiece - width: ${this.width}");
    // print("puzzlePiece - height: ${this.height}");
    // print("puzzlePiece - targetWidth: ${this.targetWidth}");
    // print("puzzlePiece - targetHeight: ${this.targetHeight}");
    // print("-------------------");
  }

  @override
  State<PuzzlePiece> createState() => _PuzzlePieceState();
}

class _PuzzlePieceState extends State<PuzzlePiece> {
  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width;
    final ClipPath clipPath = ClipPath(
      clipper: PuzzlePieceClipper(
        widget.row,
        widget.col,
        widget.maxRow,
        widget.maxCol,
      ),
      child: widget.image,
    );
    // String imagePath = 'assets/images/testpuzzel1/piece_$number.jpg';
    // print("----------${widget.imageSize}--------------");
    return Container(
      width: 411,
      height: MediaQuery.of(context).size.height,
      child: clipPath,
      // Draggable<String>(
      //   data: widget.number.toString(),
      //   child: clipPath,
      //   childWhenDragging: clipPath,
      //   feedback: clipPath,
      // ),
    );
  }
}
