import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';
import "dart:io";
import "package:flutter_app/main.dart";
import "colors.dart";

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

const Color cvBarColor = AppColors.contentColorRed;
const Color cudaBarColor = AppColors.contentColorGreen;

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
  // Class Members
  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedIndex = -1;

  // Code
  @override
  void initState() {
    super.initState();
    final bar1 = makeGroupData(0, sobelCVTime, cvBarColor);
    final bar2 = makeGroupData(1, sobelCUDATime, cudaBarColor);
    final bar3 = makeGroupData(2, cannyCVTime, cvBarColor);
    final bar4 = makeGroupData(3, cannyCUDATime, cudaBarColor);

    final items = [bar1, bar2, bar3, bar4];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  double? getMaxY() {
    sobelCVTime > cannyCVTime ? maxTime = sobelCVTime : maxTime = cannyCVTime;
    return maxTime + 5;
  }

  BarChartGroupData makeGroupData(
    int x,
    double y,
    Color? barColor, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: barColor,
          width: width,
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
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
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: Text(text, style: style, textAlign: TextAlign.left),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>[
      "Sobel OpenCV",
      "Sobel CUDA",
      "Canny OpenCV",
      "Canny CUDA"
    ];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 12, //margin top
      child: text,
    );
  }

  BarChartData barChartData() {
    return BarChartData(
      maxY: getMaxY(),
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
            getTitlesWidget: bottomTitles,
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: 1,
            getTitlesWidget: leftTitles,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          top: BorderSide.none,
          right: BorderSide.none,
          left: BorderSide(width: 1),
          bottom: BorderSide(width: 1),
        ),
      ),
      groupsSpace: 10,
      barGroups: showingBarGroups,
      gridData: const FlGridData(show: true),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          // tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String text;
            switch (group.x) {
              case 0:
                text = "Sobel OpenCV Time (ms)";
                break;
              case 1:
                text = "Sobel CUDA Time (ms)";
                break;
              case 2:
                text = "Canny OpenCV Time (ms)";
                break;
              case 3:
                text = "Canny CUDA Time (ms)";
                break;
              default:
                throw Error();
            }
            return BarTooltipItem(
              '$text\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY).toString(),
                  style: const TextStyle(
                    color: AppColors.contentColorBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
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
                padding: const EdgeInsets.all(60.0),
                // child: LineChart(lineChartData()),
                child: BarChart(barChartData()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
