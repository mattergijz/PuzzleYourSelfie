// TODO remove me
// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as ui;
import 'package:new_package_demo/main.dart';
import 'package:new_package_demo/services/level_service.dart';

import 'error.dart';
import 'screens/level_screen.dart';

class JigsawPuzzle extends StatefulWidget {
  const JigsawPuzzle({
    Key? key,
    required this.verticalAmount,
    required this.horizontalAmount,
    required this.image,
    required this.puzzleKey,
    required this.index,
    required this.aspectRatio,
    required this.puzzleGenerated,
    required this.time,
    this.onFinished,
    this.onBlockSuccess,
    this.outlineCanvas = true,
    this.autoStart = false,
    this.snapSensitivity = .5,
  }) : super(key: key);

  final int verticalAmount;
  final int horizontalAmount;
  final int time;
  final Function()? onFinished;
  final Function()? onBlockSuccess;
  final String image;
  final bool autoStart;
  final bool outlineCanvas;
  final bool puzzleGenerated;
  final double snapSensitivity;
  final GlobalKey<JigsawWidgetState> puzzleKey;
  final int? index;
  final double aspectRatio;

  @override
  _JigsawPuzzleState createState() => _JigsawPuzzleState();
}

class _JigsawPuzzleState extends State<JigsawPuzzle> {
  late Timer _timer;
  late int _start = widget.time;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (LevelService.timerActive) {
          if (mounted) {
            if (_start == 0) {
              setState(() {
                timer.cancel();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Time ran out!"),
                      content: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Column(
                          children: [
                            ElevatedButton(
                              child: const Text("Return to home"),
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                    (route) => false);
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              });
            } else {
              setState(() {
                _start--;
              });
            }
          }
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_start != widget.time || LevelService.timerActive) {
      _timer.cancel();
    }
  }

  //TODO: on timer end, show popup or something, game has to end

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Text("$_start",
            style: const TextStyle(fontSize: 30, color: Colors.red)),
        const SizedBox(height: 16),
        JigsawWidget(
          puzzleGenerated: widget.puzzleGenerated,
          startTimer: startTimer,
          aspectRatio: widget.aspectRatio,
          index: widget.index,
          callbackFinish: () {
            print("in callback finish");
            if (widget.onFinished != null && _start != 0) {
              print("in if");
              setState(() {
                _timer.cancel();
              });
              widget.onFinished!();
            }
          },
          callbackSuccess: () {
            if (widget.onBlockSuccess != null) {
              widget.onBlockSuccess!();
            }
          },
          key: widget.puzzleKey,
          verticalAmount: widget.verticalAmount,
          horizontalAmount: widget.horizontalAmount,
          snapSensitivity: widget.snapSensitivity,
          outlineCanvas: widget.outlineCanvas,
          child: Image.file(File(widget.image)),
        ),
      ],
    );
  }
}

class JigsawWidget extends StatefulWidget {
  JigsawWidget({
    Key? key,
    required this.verticalAmount,
    required this.horizontalAmount,
    required this.snapSensitivity,
    required this.child,
    required this.index,
    required this.aspectRatio,
    required this.startTimer,
    required this.puzzleGenerated,
    this.callbackFinish,
    this.callbackSuccess,
    this.outlineCanvas = true,
  }) : super(key: key);

  final Widget child;
  final Function()? callbackSuccess;
  final Function()? callbackFinish;
  final Function()? startTimer;
  final int verticalAmount;
  final int horizontalAmount;
  final bool outlineCanvas;
  bool puzzleGenerated;
  final double snapSensitivity;
  final int? index;
  final double aspectRatio;

  @override
  JigsawWidgetState createState() => JigsawWidgetState();
}

class JigsawWidgetState extends State<JigsawWidget> {
  final GlobalKey _globalKey = GlobalKey();
  ui.Image? fullImage;
  Size? size;
  int length = 0;

  List<List<BlockClass>> images = <List<BlockClass>>[];
  ValueNotifier<List<BlockClass>> blocksNotifier =
      ValueNotifier<List<BlockClass>>(<BlockClass>[]);

  Offset _pos = Offset.zero;
  int? _index;

  //TODO: current fix is not great: reducing the random by 1, reason is that the give list length isn't always correct.

  void blockWasSuccess(int listLength) {
    widget.callbackSuccess?.call();
    Future.delayed(
      const Duration(milliseconds: 450),
      () {
        setState(() {
          generateRandomNewIndex(listLength);
        });
      },
    );
  }

  void generateRandomNewIndex(int maxIndex) {
    int random = math.Random().nextInt(maxIndex);
    if (random == 0) {
      _index = random;
    } else {
      _index = random - 1;
    }
  }

  Future<ui.Image?> _getImageFromWidget() async {
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    size = boundary.size;
    final img = await boundary.toImage();
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();

    if (pngBytes == null) {
      throw InvalidImageException();
    }
    return ui.decodeImage(List<int>.from(pngBytes));
  }

  void reset() {
    images.clear();
    blocksNotifier = ValueNotifier<List<BlockClass>>(<BlockClass>[]);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  Future<void> generate() async {
    images = [[]];

    fullImage ??= await _getImageFromWidget();

    final int xSplitCount = widget.horizontalAmount;
    final int ySplitCount = widget.verticalAmount;

    final double widthPerBlock = fullImage!.width / xSplitCount;
    final double heightPerBlock = fullImage!.height / ySplitCount;

    for (var y = 0; y < ySplitCount; y++) {
      final tempImages = <BlockClass>[];

      images.add(tempImages);
      for (var x = 0; x < xSplitCount; x++) {
        final int randomPosRow = math.Random().nextInt(2).isEven ? 1 : -1;
        final int randomPosCol = math.Random().nextInt(2).isEven ? 1 : -1;

        Offset offsetCenter = Offset(widthPerBlock / 2, heightPerBlock / 2);

        final ClassJigsawPos jigsawPosSide = ClassJigsawPos(
          bottom: y == ySplitCount - 1 ? 0 : randomPosCol,
          left: x == 0
              ? 0
              : -images[y][x - 1].jigsawBlockWidget.imageBox.posSide.right,
          right: x == xSplitCount - 1 ? 0 : randomPosRow,
          top: y == 0
              ? 0
              : -images[y - 1][x].jigsawBlockWidget.imageBox.posSide.bottom,
        );

        double xAxis = widthPerBlock * x;
        double yAxis = heightPerBlock * y;

        final double minSize = math.min(widthPerBlock, heightPerBlock) / 15 * 4;

        offsetCenter = Offset(
          (widthPerBlock / 2) + (jigsawPosSide.left == 1 ? minSize : 0),
          (heightPerBlock / 2) + (jigsawPosSide.top == 1 ? minSize : 0),
        );

        xAxis -= jigsawPosSide.left == 1 ? minSize : 0;
        yAxis -= jigsawPosSide.top == 1 ? minSize : 0;

        final double widthPerBlockTemp = widthPerBlock +
            (jigsawPosSide.left == 1 ? minSize : 0) +
            (jigsawPosSide.right == 1 ? minSize : 0);
        final double heightPerBlockTemp = heightPerBlock +
            (jigsawPosSide.top == 1 ? minSize : 0) +
            (jigsawPosSide.bottom == 1 ? minSize : 0);

        final ui.Image temp = ui.copyCrop(
          fullImage!,
          xAxis.round(),
          yAxis.round(),
          widthPerBlockTemp.round(),
          heightPerBlockTemp.round(),
        );

        final Offset offset = Offset(size!.width / 2 - widthPerBlockTemp / 2,
            size!.height / 2 - heightPerBlockTemp / 2);

        final ImageBox imageBox = ImageBox(
          image: Image.memory(
            Uint8List.fromList(ui.encodePng(temp)),
            fit: BoxFit.contain,
          ),
          isDone: false,
          offsetCenter: offsetCenter,
          posSide: jigsawPosSide,
          radiusPoint: minSize,
          size: Size(widthPerBlockTemp, heightPerBlockTemp),
        );

        images[y].add(
          BlockClass(
              jigsawBlockWidget: JigsawBlockWidget(
                imageBox: imageBox,
              ),
              offset: offset,
              offsetDefault: Offset(xAxis, yAxis)),
        );
      }
    }
    _index = 0;

    blocksNotifier.value = images.expand((image) => image).toList();
    blocksNotifier.value.shuffle();
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    blocksNotifier.notifyListeners();
    widget.puzzleGenerated = true;
    LevelService.timerActive = true;
    widget.startTimer!();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: blocksNotifier,
          builder: (context, List<BlockClass> blocks, child) {
            final List<BlockClass> blockNotDone = blocks
                .where((block) => !block.jigsawBlockWidget.imageBox.isDone)
                .toList();
            final List<BlockClass> blockDone = blocks
                .where((block) => block.jigsawBlockWidget.imageBox.isDone)
                .toList();

            return GestureDetector(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: widget.aspectRatio,
                    child: SizedBox(
                      width: double.infinity,
                      child: Listener(
                        onPointerUp: (event) {
                          if (blockNotDone.isEmpty && blockDone.isNotEmpty) {
                            reset();
                            widget.callbackFinish?.call();
                          }
                        },
                        onPointerMove: (event) {
                          if (_index == null) {
                            return;
                          }
                          if (blockNotDone.isEmpty) {
                            return;
                          }

                          final Offset offset = event.localPosition - _pos;

                          blockNotDone[_index!].offset = offset;

                          const minSensitivity = 0;
                          const maxSensitivity = 1;
                          const maxDistanceThreshold = 20;
                          const minDistanceThreshold = 1;

                          final sensitivity = widget.snapSensitivity;
                          final distanceThreshold = sensitivity *
                                  (maxSensitivity - minSensitivity) *
                                  (maxDistanceThreshold -
                                      minDistanceThreshold) +
                              minDistanceThreshold;

                          if ((blockNotDone[_index!].offset -
                                      blockNotDone[_index!].offsetDefault)
                                  .distance <
                              distanceThreshold) {
                            blockNotDone[_index!]
                                .jigsawBlockWidget
                                .imageBox
                                .isDone = true;

                            blockNotDone[_index!].offset =
                                blockNotDone[_index!].offsetDefault;

                            _index = null;

                            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                            blocksNotifier.notifyListeners();
                            
                            setState(() {
                              blockWasSuccess(blockNotDone.length);
                            });
                            return;
                          }
                          setState(() {});
                        },
                        child: Stack(
                          children: [
                            if (blocks.isEmpty) ...[
                              RepaintBoundary(
                                key: _globalKey,
                                child: SizedBox(
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  child: widget.child,
                                ),
                              )
                            ],
                            Offstage(
                              offstage: blocks.isEmpty,
                              child: Container(
                                color: Colors.white,
                                width: size?.width,
                                height: size?.height,
                                child: CustomPaint(
                                  painter: JigsawPainterBackground(
                                    blocks,
                                    outlineCanvas: widget.outlineCanvas,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (blockDone.isNotEmpty)
                                        ...blockDone.map(
                                          (map) {
                                            return Positioned(
                                              left: map.offset.dx,
                                              top: map.offset.dy,
                                              child: Container(
                                                child: map.jigsawBlockWidget,
                                              ),
                                            );
                                          },
                                        ),
                                      if (blockNotDone.isNotEmpty)
                                        ...blockNotDone.asMap().entries.map(
                                          (map) {
                                            return Positioned(
                                              left: map.value.offset.dx,
                                              top: map.value.offset.dy,
                                              child: Offstage(
                                                offstage: !(_index == map.key),
                                                child: GestureDetector(
                                                  onTapDown: (details) {
                                                    if (map
                                                        .value
                                                        .jigsawBlockWidget
                                                        .imageBox
                                                        .isDone) {
                                                      return;
                                                    }
                                                    setState(() {
                                                      _pos =
                                                          details.localPosition;
                                                      _index = map.key;
                                                    });
                                                  },
                                                  child: Container(
                                                    child: map.value
                                                        .jigsawBlockWidget,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class JigsawPainterBackground extends CustomPainter {
  JigsawPainterBackground(this.blocks, {required this.outlineCanvas});

  List<BlockClass> blocks;
  bool outlineCanvas;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = outlineCanvas ? PaintingStyle.stroke : PaintingStyle.fill
      ..color = Colors.black12
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final Path path = Path();

    blocks.forEach((element) {
      final Path pathTemp = getPiecePath(
        element.jigsawBlockWidget.imageBox.size,
        element.jigsawBlockWidget.imageBox.radiusPoint,
        element.jigsawBlockWidget.imageBox.offsetCenter,
        element.jigsawBlockWidget.imageBox.posSide,
      );

      path.addPath(pathTemp, element.offsetDefault);
    });

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BlockClass {
  BlockClass({
    required this.offset,
    required this.jigsawBlockWidget,
    required this.offsetDefault,
  });

  Offset offset;
  Offset offsetDefault;
  JigsawBlockWidget jigsawBlockWidget;
}

class ImageBox {
  ImageBox({
    required this.image,
    required this.posSide,
    required this.isDone,
    required this.offsetCenter,
    required this.radiusPoint,
    required this.size,
  });

  Widget image;
  ClassJigsawPos posSide;
  Offset offsetCenter;
  Size size;
  double radiusPoint;
  bool isDone;
}

class ClassJigsawPos {
  ClassJigsawPos({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  int top, bottom, left, right;
}

class JigsawBlockWidget extends StatefulWidget {
  const JigsawBlockWidget({Key? key, required this.imageBox}) : super(key: key);

  final ImageBox imageBox;

  @override
  _JigsawBlockWidgetState createState() => _JigsawBlockWidgetState();
}

class _JigsawBlockWidgetState extends State<JigsawBlockWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: PuzzlePieceClipper(imageBox: widget.imageBox),
      child: CustomPaint(
        foregroundPainter: JigsawBlokPainter(imageBox: widget.imageBox),
        child: widget.imageBox.image,
      ),
    );
  }
}

class JigsawBlokPainter extends CustomPainter {
  JigsawBlokPainter({
    required this.imageBox,
  });

  ImageBox imageBox;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = imageBox.isDone ? Colors.white.withOpacity(0.2) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(
        getPiecePath(size, imageBox.radiusPoint, imageBox.offsetCenter,
            imageBox.posSide),
        paint);

    if (imageBox.isDone) {
      final Paint paintDone = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2;
      canvas.drawPath(
          getPiecePath(size, imageBox.radiusPoint, imageBox.offsetCenter,
              imageBox.posSide),
          paintDone);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PuzzlePieceClipper extends CustomClipper<Path> {
  PuzzlePieceClipper({
    required this.imageBox,
  });

  ImageBox imageBox;

  @override
  Path getClip(Size size) {
    return getPiecePath(
        size, imageBox.radiusPoint, imageBox.offsetCenter, imageBox.posSide);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

Path getPiecePath(
  Size size,
  double radiusPoint,
  Offset offsetCenter,
  ClassJigsawPos posSide,
) {
  final Path path = Path();

  Offset topLeft = const Offset(0, 0);
  Offset topRight = Offset(size.width, 0);
  Offset bottomLeft = Offset(0, size.height);
  Offset bottomRight = Offset(size.width, size.height);

  topLeft = Offset(posSide.left > 0 ? radiusPoint : 0,
          (posSide.top > 0) ? radiusPoint : 0) +
      topLeft;
  topRight = Offset(posSide.right > 0 ? -radiusPoint : 0,
          (posSide.top > 0) ? radiusPoint : 0) +
      topRight;
  bottomRight = Offset(posSide.right > 0 ? -radiusPoint : 0,
          (posSide.bottom > 0) ? -radiusPoint : 0) +
      bottomRight;
  bottomLeft = Offset(posSide.left > 0 ? radiusPoint : 0,
          (posSide.bottom > 0) ? -radiusPoint : 0) +
      bottomLeft;

  final double topMiddle = posSide.top == 0
      ? topRight.dy
      : (posSide.top > 0
          ? topRight.dy - radiusPoint
          : topRight.dy + radiusPoint);

  final double bottomMiddle = posSide.bottom == 0
      ? bottomRight.dy
      : (posSide.bottom > 0
          ? bottomRight.dy + radiusPoint
          : bottomRight.dy - radiusPoint);

  final double leftMiddle = posSide.left == 0
      ? topLeft.dx
      : (posSide.left > 0
          ? topLeft.dx - radiusPoint
          : topLeft.dx + radiusPoint);

  final double rightMiddle = posSide.right == 0
      ? topRight.dx
      : (posSide.right > 0
          ? topRight.dx + radiusPoint
          : topRight.dx - radiusPoint);

  path.moveTo(topLeft.dx, topLeft.dy);

  if (posSide.top != 0) {
    path.extendWithPath(
      calculatePoint(Axis.horizontal, topLeft.dy,
          Offset(offsetCenter.dx, topMiddle), radiusPoint),
      Offset.zero,
    );
  }
  path.lineTo(topRight.dx, topRight.dy);

  if (posSide.right != 0) {
    path.extendWithPath(
        calculatePoint(Axis.vertical, topRight.dx,
            Offset(rightMiddle, offsetCenter.dy), radiusPoint),
        Offset.zero);
  }
  path.lineTo(bottomRight.dx, bottomRight.dy);

  if (posSide.bottom != 0) {
    path.extendWithPath(
        calculatePoint(Axis.horizontal, bottomRight.dy,
            Offset(offsetCenter.dx, bottomMiddle), -radiusPoint),
        Offset.zero);
  }
  path.lineTo(bottomLeft.dx, bottomLeft.dy);

  if (posSide.left != 0) {
    path.extendWithPath(
        calculatePoint(Axis.vertical, bottomLeft.dx,
            Offset(leftMiddle, offsetCenter.dy), -radiusPoint),
        Offset.zero);
  }
  path.lineTo(topLeft.dx, topLeft.dy);

  path.close();

  return path;
}

Path calculatePoint(
  Axis axis,
  double fromPoint,
  Offset point,
  double radiusPoint,
) {
  final Path path = Path();

  if (axis == Axis.horizontal) {
    path.moveTo(point.dx - radiusPoint / 2, fromPoint);
    path.lineTo(point.dx - radiusPoint / 2, point.dy);
    path.lineTo(point.dx + radiusPoint / 2, point.dy);
    path.lineTo(point.dx + radiusPoint / 2, fromPoint);
  } else if (axis == Axis.vertical) {
    path.moveTo(fromPoint, point.dy - radiusPoint / 2);
    path.lineTo(point.dx, point.dy - radiusPoint / 2);
    path.lineTo(point.dx, point.dy + radiusPoint / 2);
    path.lineTo(fromPoint, point.dy + radiusPoint / 2);
  }

  return path;
}
