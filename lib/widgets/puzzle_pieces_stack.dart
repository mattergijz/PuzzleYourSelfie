// import 'package:flutter/material.dart';

// import 'puzzle_piece.dart';

// class PuzzlePiecesStack extends StatefulWidget {
//   final int amountOfPieces;

//   PuzzlePiecesStack(this.amountOfPieces);

//   @override
//   State<PuzzlePiecesStack> createState() => _PuzzlePiecesStackState();
// }

// class _PuzzlePiecesStackState extends State<PuzzlePiecesStack> {
//   List<PuzzlePiece> createPuzzlePieces(
//       int amount, double pieceWidth, double pieceHeight) {
//     List<PuzzlePiece> pieces = [];
//     for (int i = 0; i < amount; i++) {
//       pieces.add(PuzzlePiece(
//         width: pieceWidth,
//         height: pieceHeight,
//         targetWidth: pieceWidth,
//         targetHeight: pieceHeight,
//         number: i,
//       ));
//     }
//     return pieces;
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(widget.amountOfPieces);
//     return Container(
//       child: Stack(
//         // children: [],
//         children: [
//           ...createPuzzlePieces(widget.amountOfPieces, 150, 80),
//         ],
//       ),
//     );
//   }
// }
