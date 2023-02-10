import 'package:flutter/material.dart';

class PuzzleTarget extends StatefulWidget {
  final int correctImageNumber;
  final Function removePieceFromPile;

  PuzzleTarget(
      {required this.correctImageNumber, required this.removePieceFromPile});

  @override
  State<PuzzleTarget> createState() => _PuzzleTargetState();
}

class _PuzzleTargetState extends State<PuzzleTarget> {
  bool isDropped = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return Container(
          child: isDropped
              ? Image.asset('assets/images/poep/test.png')
              : Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                ),
        );
      },
      onAccept: (data) {
        if (data.toString() == widget.correctImageNumber.toString()) {
          setState(() {
            isDropped = true;
          });
        }
      },
      onWillAccept: (data) {
        print(widget.correctImageNumber);
        print("data: $data");
        if (widget.correctImageNumber == int.parse(data.toString())) {
          setState(() {
            widget.removePieceFromPile(1);
          });
        }
        return widget.correctImageNumber == int.parse(data.toString());
      },
    );
  }
}
