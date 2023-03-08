import 'dart:collection';
import 'dart:io';
import 'package:flutter/services.dart' as service;
import 'package:yaml/yaml.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_package_demo/screens/level_screen.dart';
import 'package:path_provider/path_provider.dart';

import 'jigsaw.dart';
import 'models/level_model.dart';
import 'services/image_service.dart';
import 'services/level_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool dataLoaded = false;
  @override
  void initState() {
    LevelService.getVariablesFromEnvironment().then((_) {
      setState(() {
        dataLoaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jigsaw',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
          primaryColorDark: Colors.blueGrey.shade700,
          backgroundColor: Colors.blueGrey.shade100,
          cardColor: Colors.yellow,
          errorColor: Colors.orange,
        ),
        textTheme: Typography.englishLike2018,
      ).copyWith(
        splashFactory: InkRipple.splashFactory,
      ),
      home: dataLoaded ? HomeScreen() : LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Puzzle Your Selfie"),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(height: 80, width: 80, child: CircularProgressIndicator()),
          SizedBox(
            height: 20,
          ),
          Text(
            "Waiting for data to be loaded...",
            style: TextStyle(fontSize: 25),
          ),
        ],
      )),
    );
  }
}

class HomeScreen extends StatefulWidget {
  static const String screenRoute = "/home";

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int? index;
  late String imagePath = "";
  late int imageWidth;
  late int imageHeight;

  Future<void> getImage(bool fromGallery) async {
    final XFile? image;
    if (fromGallery) {
      image = await ImagePicker().pickImage(source: ImageSource.gallery
          // , maxHeight: MediaQuery.of(context).size.height * 0.65, maxWidth: MediaQuery.of(context).size.width
          );
    } else {
      image = await ImagePicker().pickImage(source: ImageSource.camera
          // , maxHeight: MediaQuery.of(context).size.height * 0.65, maxWidth: MediaQuery.of(context).size.width
          );
    }
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String path = appDocumentsDirectory.path;
    File newFile = File(image!.path);
    final bytes = newFile.readAsBytesSync();
    final imageTest = await decodeImageFromList(bytes);
    imageWidth = imageTest.width;
    imageHeight = imageTest.height;
    String newImagePath = "${path.toString()}/image1.jpeg";
    setState(() {
      ImageService.currentImagePath = newImagePath;
      ImageService.currentImageWidth = imageWidth;
      ImageService.currentImageHeight = imageHeight;
      imagePath = newImagePath;
    });
    final File newImage = await newFile.copy(newImagePath);
  }

  void checkIfImageWasPresent() {
    if (ImageService.currentImagePath != "") {
      setState(() {
        imagePath = ImageService.currentImagePath;
        imageWidth = ImageService.currentImageWidth;
        imageHeight = ImageService.currentImageHeight;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfImageWasPresent();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
              "Are you sure you want to reset all progress? (this can't be reversed)"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    LevelService.getVariablesFromEnvironment();
                    Navigator.of(context).pop();
                  });
                },
                child: const Text("Yes"),
              ),
              const SizedBox(
                width: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("No"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Puzzle Your Selfie"),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              showResetConfirmationDialog();
            },
            child: const Text("Reset"),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...LevelService.levels.map((level) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 50),
                      child: Column(
                        children: [
                          Text(
                            "Level: ${level.number}",
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(level.passed ? "✅" : "❌"),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            imagePath.isEmpty
                ? Column(
                    children: [
                      const Text("Select image"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: const Text("Gallery"),
                            onPressed: () {
                              getImage(true);
                            },
                          ),
                          const SizedBox(width: 20.0),
                          ElevatedButton(
                            child: const Text("Camera"),
                            onPressed: () {
                              getImage(false);
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : LevelService.allLevelsPassed
                    ? Column(
                        children: [
                          const Text(
                            "You completed all levels",
                            style: TextStyle(fontSize: 25, color: Colors.amber),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showResetConfirmationDialog();
                            },
                            child: const Text("Reset"),
                          )
                        ],
                      )
                    : Column(
                        children: [
                          ElevatedButton(
                            child: Text(
                                "Go to level ${LevelService.levelsNotDone[0].number}"),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return LevelScreen(
                                      currentLevel:
                                          LevelService.levelsNotDone[0],
                                      imageHeight: imageHeight,
                                      imageWidth: imageWidth,
                                      imagePath: imagePath,
                                      puzzleGenerated: false,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          imagePath.isNotEmpty
                              ? Image.file(
                                  File(imagePath),
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                )
                              : const Text("Nog geen image"),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                imagePath = "";
                              });
                            },
                            child: const Text("Delete photo"),
                          )
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}
