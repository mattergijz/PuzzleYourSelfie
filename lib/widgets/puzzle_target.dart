import 'package:flutter/material.dart';

class PuzzleTarget extends StatefulWidget {
  final int correctImageNumber;
  final Function removePieceFromPile;
  final double width;
  final double height;
  double opacity = 0.5;

  PuzzleTarget({
    required this.correctImageNumber,
    required this.removePieceFromPile,
    required this.width,
    required this.height,
  });

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
          width: widget.width,
          height: widget.height,
          child: Container(
            width: widget.width,
            height: widget.height,
            child: isDropped
                ? Stack(
                    children: [
                      Image.asset(
                        'assets/images/poep/piece_${widget.correctImageNumber}.jpg',
                        color: Colors.white.withOpacity(1),
                        colorBlendMode: BlendMode.modulate,
                        width: widget.width,
                        height: widget.height,
                      ),
                      Center(
                        child: Text(
                          widget.correctImageNumber.toString(),
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ),
                    ],
                  )
                : Image.asset(
                    'assets/images/poep/piece_${widget.correctImageNumber}.jpg',
                    color: Colors.white.withOpacity(0.5),
                    colorBlendMode: BlendMode.modulate,
                    width: widget.width,
                    height: widget.height,
                  ),
          ),
        );
      },
      onAccept: (data) {
        setState(() {
          widget.removePieceFromPile(widget.correctImageNumber);
          isDropped = true;
          widget.opacity = 1;
        });
      },
      onWillAccept: (data) {
        return widget.correctImageNumber == int.parse(data.toString());
      },
    );
  }
}
