import "package:flutter/material.dart";
import "dart:io";

late String imageName, imagePath;

class Results extends StatelessWidget {
  const Results({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ResultsScreen());
  }
}

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // Code
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Results"),
            backgroundColor: const Color.fromARGB(255, 118, 185, 0),
            actions: <Widget>[
              TextButton(
                style: style,
                onPressed: () {
                  exit(0);
                },
                child: const Text("Exit"),
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: "Sobel OpenCV",
                ),
                Tab(
                  text: "Sobel CUDA",
                ),
                Tab(
                  text: "Canny OpenCV",
                ),
                Tab(
                  text: "Canny CUDA",
                ),
                Tab(
                  text: "Summary",
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
              Icon(Icons.directions_bike),
              Icon(Icons.home),
              Icon(Icons.home),
            ],
          ),
        ),
      ),
    );
  }
}
