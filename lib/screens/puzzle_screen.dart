import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:cross_file_image/cross_file_image.dart';
import 'package:first_app/widgets/puzzle_piece.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as service;
import 'package:image_picker/image_picker.dart';
import 'package:yaml/yaml.dart';

import '../models/level.dart';
import '../widgets/puzzle_board.dart';

class PuzzleScreen extends StatefulWidget {
  static final screenRoute = "/puzzle";

  final int level;
  final String folderPath;
  final int rows = 4;
  final int cols = 4;

  PuzzleScreen(this.level, this.folderPath);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  bool puzzleWasInitialized = false;
  late XFile _image;

  List<Widget> pieces = [];

  late Level currentLevel;

  void createNextLevel(Queue levels) {
    if (levels.isNotEmpty) {
      Level nextLevel = levels.last;
      // createPuzzlePieces(nextLevel);
      levels.removeFirst();
    }
  }

  void removePieceFromPile(int pxNumber) {
    setState(() {
      pieces.removeWhere((element) {
        return (element as PuzzlePiece).number == pxNumber;
      });
    });
  }

  Future getImage(ImageSource source) async {
    XFile? image = await ImagePicker().pickImage(source: source);

    if (image != null) {
      setState(() {
        this._image = image;
        pieces.clear();
      });

      splitImage(Image(image: XFileImage(image)));
    }
  }

  Future<Size> getImageSize(Image image) async {
    final Completer<Size> completer = Completer<Size>();

    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
    ));

    final Size imageSize = await completer.future;

    return imageSize;
  }

  void splitImage(Image image) async {
    Size imageSize = await getImageSize(image);

    for (int x = 0; x < widget.rows; x++) {
      for (int y = 0; y < widget.cols; y++) {
        setState(() {
          pieces.add(
            PuzzlePiece(
              number: x,
              image: image,
              imageSize: imageSize,
              row: x,
              col: y,
              maxRow: widget.rows,
              maxCol: widget.cols,
            ),
          );
        });
      }
    }
  }

  void bringToTop(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.add(widget);
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.insert(0, widget);
    });
  }

  // double imageHeight = 100;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, Object>;
    // splitImage(arguments['image'] as Image);
    currentLevel = arguments['level'] as Level;
    // createPuzzlePieces(arguments['level'] as Level);
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              "Puzzle level ${widget.level}: ${currentLevel.amountOfTiles} pieces"),
        ),
        body: Container(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    },
                    child: const Text("Pick image"),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [...pieces],
                    ),
                    // sizing: StackFit.loose,
                  ),
                  Visibility(
                    child: Text("No more pieces left"),
                    visible: pieces.isEmpty,
                  ),
                  // PuzzleBoard(
                  //   availableWidth: (MediaQuery.of(context).size.width * 0.95)
                  //       .floorToDouble(),
                  //   verticalSpaces: sqrt(currentLevel.amountOfTiles).toInt(),
                  //   horizontalSpaces: sqrt(currentLevel.amountOfTiles).toInt(),
                  //   removeFromPile: removePieceFromPile,
                  // ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class PuzzlePieceClipper extends CustomClipper<Path> {
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;

  PuzzlePieceClipper(this.row, this.col, this.maxRow, this.maxCol);

  @override
  Path getClip(Size size) {
    return getPiecePath(size, row, col, maxRow, maxCol);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Path getPiecePath(Size size, int row, int col, int maxRow, int maxCol) {
  final width = size.width / maxCol;
  final height = size.height / maxRow;
  final offsetX = col * width;
  final offsetY = row * height;
  final bumpSize = height / 4;

  var path = Path();
  path.moveTo(offsetX, offsetY);

  if (row == 0) {
    // top side piece
    path.lineTo(offsetX + width, offsetY);
  } else {
    // top bump
    path.lineTo(offsetX + width / 3, offsetY);
    path.cubicTo(
        offsetX + width / 6,
        offsetY - bumpSize,
        offsetX + width / 6 * 5,
        offsetY - bumpSize,
        offsetX + width / 3 * 2,
        offsetY);
    path.lineTo(offsetX + width, offsetY);
  }

  if (col == maxCol - 1) {
    // right side piece
    path.lineTo(offsetX + width, offsetY + height);
  } else {
    // right bump
    path.lineTo(offsetX + width, offsetY + height / 3);
    path.cubicTo(
        offsetX + width - bumpSize,
        offsetY + height / 6,
        offsetX + width - bumpSize,
        offsetY + height / 6 * 5,
        offsetX + width,
        offsetY + height / 3 * 2);
    path.lineTo(offsetX + width, offsetY + height);
  }

  if (row == maxRow - 1) {
    // bottom side piece
    path.lineTo(offsetX, offsetY + height);
  } else {
    // bottom bump
    path.lineTo(offsetX + width / 3 * 2, offsetY + height);
    path.cubicTo(
        offsetX + width / 6 * 5,
        offsetY + height - bumpSize,
        offsetX + width / 6,
        offsetY + height - bumpSize,
        offsetX + width / 3,
        offsetY + height);
    path.lineTo(offsetX, offsetY + height);
  }

  if (col == 0) {
    // left side piece
    path.close();
  } else {
    // left bump
    path.lineTo(offsetX, offsetY + height / 3 * 2);
    path.cubicTo(
        offsetX - bumpSize,
        offsetY + height / 6 * 5,
        offsetX - bumpSize,
        offsetY + height / 6,
        offsetX,
        offsetY + height / 3);
    path.close();
  }

  return path;
}
