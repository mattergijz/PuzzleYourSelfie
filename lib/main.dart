import 'package:flutter/material.dart';

import 'package:first_app/screens/puzzle_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        // '/': (context) => HomeScreen(),
        '/puzzle': (context) => PuzzleScreen(1, "assets/images/poep"),
      },
      initialRoute: "/",
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Your Selfie'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Go to puzzle!"),
          onPressed: () {
            Navigator.pushNamed(context, PuzzleScreen.screenRoute);
          },
        ),
      ),
    );
  }
}
