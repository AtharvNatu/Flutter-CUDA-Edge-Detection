import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';
import "dart:io";
import "package:flutter_app/main.dart";

late String imageName, sobelCVPath, sobelCUDAPath, cannyCVPath, cannyCUDAPath;
late double maxTime;
String? selectedFileName;
String? dirPath;
Directory? rootPath = Directory("/home/atharv/Downloads/");

// Execution Time
late double sobelCVTime, sobelCUDATime, cannyCVTime, cannyCUDATime;

List<FlSpot> chartData = [
  FlSpot(0, sobelCUDATime),
  FlSpot(1, sobelCVTime),
  FlSpot(2, cannyCVTime),
  FlSpot(3, cannyCUDATime),
];

List<Color> gradientColors = [
  const Color(0xFF50E4FF),
  const Color(0xFF2196F3),
];

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
  double? getMaxY() {
    sobelCVTime > cannyCVTime
        ? maxTime = sobelCVTime + 2
        : maxTime = cannyCVTime + 2;
    return maxTime;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text("Sobel CUDA", style: style);
        break;
      case 1:
        text = const Text("Sobel OpenCV", style: style);
        break;
      case 2:
        text = const Text("Canny OpenCV", style: style);
        break;
      case 3:
        text = const Text("Canny CUDA", style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    if (value.toInt() % 5 == 0) {
      text = value.toInt().toString();
    } else {
      text = "";
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData lineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 3,
      minY: 0,
      maxY: getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, sobelCUDATime),
            FlSpot(1, sobelCVTime),
            FlSpot(2, cannyCVTime),
            FlSpot(3, cannyCUDATime),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
                child: const Text("Back"),
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
          body: TabBarView(
            children: [
              Image(
                  image: Image.file(File(sobelCVPath)).image,
                  height: 150,
                  width: 150,
                  fit: BoxFit.fitHeight),
              Image(
                  image: Image.file(File(sobelCUDAPath)).image,
                  height: 150,
                  width: 150,
                  fit: BoxFit.fitHeight),
              Image(
                  image: Image.file(File(cannyCVPath)).image,
                  height: 150,
                  width: 150,
                  fit: BoxFit.fitHeight),
              Image(
                  image: Image.file(File(cannyCUDAPath)).image,
                  height: 150,
                  width: 150,
                  fit: BoxFit.fitHeight),
              Padding(
                padding: const EdgeInsets.all(80.0),
                child: LineChart(lineChartData()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
