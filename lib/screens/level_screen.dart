import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_package_demo/main.dart';

import '../jigsaw.dart';
import '../models/level_model.dart';
import '../services/level_service.dart';

class LevelScreen extends StatefulWidget {
  static const screenRoute = "/level";
  final Level currentLevel;
  final int imageWidth;
  final int imageHeight;
  final String imagePath;
  final bool puzzleGenerated;

  LevelScreen(
      {required this.currentLevel,
      required this.imageWidth,
      required this.imageHeight,
      required this.imagePath,
      required this.puzzleGenerated});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late Timer _timer;
  int _start = 10;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          if (mounted) {
            setState(() {
              timer.cancel();
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _start--;
            });
          }
        }
      },
    );
  }

  int? index;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzleKey = GlobalKey<JigsawWidgetState>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Level ${widget.currentLevel.number}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              setState(() {
                LevelService.timerActive = false;
              });
              showDialog(
                context: context,
                builder: (context) {
                  return PauseDialog(title: "title", content: "content");
                },
              ).then(
                (_) => {
                  setState(() {
                    LevelService.timerActive = true;
                  })
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await puzzleKey.currentState!.generate();
                    },
                    child: const Text('Generate'),
                  ),
                ],
              ),
              JigsawPuzzle(
                time: widget.currentLevel.time,
                puzzleGenerated: widget.puzzleGenerated,
                aspectRatio: widget.imageWidth / widget.imageHeight,
                index: index,
                verticalAmount: widget.currentLevel.verticalAmount,
                horizontalAmount: widget.currentLevel.horizontalAmount,
                image: widget.imagePath,
                onFinished: () {
                  LevelService.passLevel(widget.currentLevel);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ));
                },
                snapSensitivity: 0.5,
                puzzleKey: puzzleKey,
                onBlockSuccess: () {
                  print('block success!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PauseDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  PauseDialog({
    required this.title,
    required this.content,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Pause",
      ),
      actions: actions,
      elevation: 10,
      content: SizedBox(
        height: 350,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Are you sure?"),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: const Text("Yes"),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                  (route) => false);
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            child: const Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text("Home"),
            ),
          ],
        ),
      ),
    );
  }
}
