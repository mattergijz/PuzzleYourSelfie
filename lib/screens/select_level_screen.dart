import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/level.dart';
import 'puzzle_screen.dart';

class SelectLevelScreen extends StatefulWidget {
  static final screenRoute = "/level-select";

  @override
  State<SelectLevelScreen> createState() => _SelectLevelScreenState();
}

class _SelectLevelScreenState extends State<SelectLevelScreen> {
  String? dropDownValue = "1";

  Future<XFile?> waitForImageToBeSelected() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    List<Level> levels = arguments['levels'] as List<Level>;
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Your Selfie'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Select level:",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    elevation: 20,
                    value: dropDownValue,
                    items: levels.map<DropdownMenuItem<String>>((Level level) {
                      return DropdownMenuItem<String>(
                        value: level.number.toString(),
                        child: Text("${level.number}"),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        dropDownValue = value.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: waitForImageToBeSelected,
              child: Text('Select image'),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              child: Text("Go to puzzle!"),
              onPressed: () {
                int index = levels.indexWhere((Level level) {
                  return level.number.toString() == dropDownValue;
                });
                arguments['level'] = levels[index];
                Navigator.pushNamed(
                  context,
                  PuzzleScreen.screenRoute,
                  arguments: arguments,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
