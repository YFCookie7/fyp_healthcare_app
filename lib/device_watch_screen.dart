import 'dart:async';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:developer' as developer;
import 'package:fyp_healthcare_app/globals.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:fyp_healthcare_app/database.dart';

class WatchDeviceScreen extends StatefulWidget {
  const WatchDeviceScreen({Key? key}) : super(key: key);

  @override
  _WatchDeviceScreenState createState() => _WatchDeviceScreenState();
}

class _WatchDeviceScreenState extends State<WatchDeviceScreen> {
  Timer? _refreshBioDataTimer;
  String tb_spo2 = '-';
  String tb_hr = '-';
  String tb_tempO = '-';
  String tb_tempA = '-';
  double y_minimum = 50;
  double y_maximum = 100;
  double y_minimum_spo2 = 50;
  double y_maximum_spo2 = 100;
  double y_minimum_hr = 50;
  double y_maximum_hr = 150;
  double y_minimum_tempO = 32;
  double y_maximum_tempO = 45;
  double y_minimum_tempA = 10;
  double y_maximum_tempA = 40;
  String currMode = "SPO2";
  List<DataHistory> dataHistory = [];

  Timer? timer;
  ChartSeriesController? _chartSeriesController;
  int count = 0;

  List<_ChartData> chartData = <_ChartData>[];

  @override
  void initState() {
    super.initState();
    _refreshBioData();
    refreshDataHistory();
  }

  @override
  void dispose() {
    _refreshBioDataTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshDataHistory() async {
    dataHistory = await readRealTimeData();

    setState(() {});
  }

  void _refreshBioData() {
    _refreshBioDataTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      developer.log(spo22.toString(), name: 'debug.watch');
      developer.log(tb_spo22, name: 'debug.watch');
      setState(() {
        if (chartData.length == 20) {
          chartData.removeAt(0);
          _chartSeriesController?.updateDataSource(
              addedDataIndexes: <int>[chartData.length - 1],
              removedDataIndexes: <int>[0]);
        }
        count = count + 1;
        // spo2
        if (spo22 > 100) {
          tb_spo2 = "-";
        } else if (spo22 < 50) {
          tb_spo2 = "-";
        } else {
          tb_spo2 = spo22.round().toString();
        }

        // pr
        if (heartbeatValue_double2 > 200) {
          tb_hr = "-";
        } else if (heartbeatValue_double2 < 50) {
          tb_hr = "-";
        } else {
          tb_hr = heartbeatValue_double2.round().toString();
        }

        // body temp
        if (tempValue > 45) {
          tb_tempO = "-";
        } else if (tempValue < 32) {
          tb_tempO = "-";
        } else {
          tb_tempO = tempValue.toStringAsFixed(1);
        }

        // room temp
        if (roomtempValue > 40) {
          tb_tempA = "-";
        } else if (roomtempValue < 10) {
          tb_tempA = "-";
        } else {
          tb_tempA = roomtempValue.toStringAsFixed(1);
        }
        switch (currMode) {
          case "SPO2":
            chartData.add(_ChartData(count, spo22.round()));
            break;
          case "HR":
            chartData.add(_ChartData(count, heartbeatValue_double2.round()));
            break;
          case "TEMP_O":
            chartData.add(_ChartData(count, tempValue.round()));
            break;
          case "TEMP_A":
            chartData.add(_ChartData(count, roomtempValue.round()));
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.blue),
        backgroundColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0, left: 5.0),
          child: Text(
            'Health Tracker',
            style: TextStyle(
                fontFamily: 'PatuaOne', fontSize: 24, color: Colors.black),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Center(
              child: GlassmorphicContainer(
                  height: double.infinity,
                  width: double.infinity,
                  borderRadius: 0,
                  blur: 10,
                  alignment: Alignment.topCenter,
                  border: 0,
                  linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.1),
                        const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.05),
                      ],
                      stops: const [
                        0.1,
                        1,
                      ]),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFffffff).withOpacity(0.5),
                      const Color((0xFFFFFFFF)).withOpacity(0.5),
                    ],
                  ),
                  // start screen
                  //
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 130),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  currMode = "SPO2";
                                  y_minimum = y_minimum_spo2;
                                  y_maximum = y_maximum_spo2;
                                  chartData.clear();
                                });
                              },
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 72, 146, 243),
                                        Color.fromARGB(255, 31, 241, 241)
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            showFlexibleBottomSheet(
                                              minHeight: 0,
                                              initHeight: 0.8,
                                              maxHeight: 0.8,
                                              context: context,
                                              builder: _buildBottomSheet1,
                                              isExpand: false,
                                            );
                                          },
                                          icon: const Icon(Icons.info_outline,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Positioned(
                                          top: 10,
                                          left: 13,
                                          child: Text(
                                            "SpO2",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 25,
                                          left: 15,
                                          child: SizedBox(
                                            width: 80,
                                            child: Text(
                                              tb_spo2,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 44,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                      const Positioned(
                                          bottom: 28,
                                          right: 32,
                                          child: Text(
                                            "%",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  currMode = "HR";
                                  y_minimum = y_minimum_hr;
                                  y_maximum = y_maximum_hr;
                                  chartData.clear();
                                });
                              },
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 198, 95, 245),
                                        Color.fromARGB(255, 253, 151, 253)
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            showFlexibleBottomSheet(
                                              minHeight: 0,
                                              initHeight: 0.8,
                                              maxHeight: 0.8,
                                              context: context,
                                              builder: _buildBottomSheet2,
                                              isExpand: false,
                                            );
                                          },
                                          icon: const Icon(Icons.info_outline,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Positioned(
                                          top: 10,
                                          left: 13,
                                          child: Text(
                                            "HR",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 25,
                                          left: 15,
                                          child: SizedBox(
                                            width: 80,
                                            child: Text(
                                              tb_hr,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 44,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                      const Positioned(
                                          bottom: 35,
                                          right: 20,
                                          child: Text(
                                            "bpm",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                currMode = "TEMP_O";
                                y_minimum = y_minimum_tempO;
                                y_maximum = y_maximum_tempO;
                                chartData.clear();
                              },
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 32, 248, 61),
                                        Color.fromARGB(255, 189, 252, 43)
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            showFlexibleBottomSheet(
                                              minHeight: 0,
                                              initHeight: 0.8,
                                              maxHeight: 0.8,
                                              context: context,
                                              builder: _buildBottomSheet3,
                                              isExpand: false,
                                            );
                                          },
                                          icon: const Icon(Icons.info_outline,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Positioned(
                                          top: 10,
                                          left: 13,
                                          child: Text(
                                            "Body temp.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 30,
                                          left: 20,
                                          child: Text(
                                            tb_tempO,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 42,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      const Positioned(
                                          bottom: 35,
                                          right: 15,
                                          child: Text(
                                            "°C",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                currMode = "TEMP_A";
                                y_minimum = y_minimum_tempA;
                                y_maximum = y_maximum_tempA;
                                chartData.clear();
                              },
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 255, 191, 52),
                                        Color.fromARGB(255, 250, 198, 42)
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Positioned(
                                          top: 10,
                                          left: 13,
                                          child: Text(
                                            "Room temp.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Positioned(
                                          bottom: 30,
                                          left: 20,
                                          child: Text(
                                            tb_tempA,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 42,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      const Positioned(
                                          bottom: 35,
                                          right: 15,
                                          child: Text(
                                            "°C",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        // graphs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 250,
                              width: 280,
                              child: SfCartesianChart(
                                primaryYAxis: NumericAxis(
                                  minimum: y_minimum,
                                  maximum: y_maximum,
                                ),
                                series: <LineSeries<_ChartData, int>>[
                                  LineSeries<_ChartData, int>(
                                    name: currMode,
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      _chartSeriesController = controller;
                                    },
                                    dataSource: chartData,
                                    xValueMapper: (_ChartData data, _) =>
                                        data.time,
                                    yValueMapper: (_ChartData data, _) =>
                                        data.value,
                                  )
                                ],
                                legend: const Legend(isVisible: true),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        String inputText = '';
                                        return AlertDialog(
                                          title:
                                              Text('Save a $currMode record'),
                                          content: TextField(
                                            onChanged: (text) {
                                              inputText = text;
                                            },
                                            decoration: const InputDecoration(
                                                hintText: 'Enter description'),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                String mode = "SpO2";
                                                double value = 200;
                                                switch (currMode) {
                                                  case "SPO2":
                                                    mode = "SpO2";
                                                    value = spo22;
                                                    break;
                                                  case "HR":
                                                    mode = "Heart Rate";
                                                    value =
                                                        heartbeatValue_double2;
                                                    break;
                                                  case "TEMP_O":
                                                    mode = "Body Temperature";
                                                    value = tempValue;
                                                    break;
                                                  case "TEMP_A":
                                                    mode = "Room Temperature";
                                                    value = roomtempValue;
                                                    break;
                                                }
                                                String formattedDateTime =
                                                    DateFormat(
                                                            'dd/MM/yyyy HH:mm')
                                                        .format(DateTime.now());

                                                insertRealTimeData(
                                                    formattedDateTime,
                                                    mode,
                                                    double.parse(value
                                                        .toStringAsFixed(1)),
                                                    inputText);
                                                refreshDataHistory();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.save,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    refreshDataHistory();
                                  },
                                  icon: const Icon(Icons.sync,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        DataTable(
                          columnSpacing: 15,
                          columns: const [
                            DataColumn(label: Text('Timestamp')),
                            DataColumn(label: Text('Biosignal')),
                            DataColumn(label: Text('Value')),
                            DataColumn(label: Text('Description')),
                          ],
                          rows: dataHistory
                              .map(
                                (data) => DataRow(
                                  cells: [
                                    DataCell(Text(data.timestamp)),
                                    DataCell(Text(data.bio)),
                                    DataCell(Text(data.value.toString())),
                                    DataCell(Text(data.description)),
                                  ],
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(
                          height: 50,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              readRealTimeData();
                            },
                            child: Text("qwe"))
                      ],
                    ),
                  )
                  // end screen
                  ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildBottomSheet1(
  BuildContext context,
  ScrollController scrollController,
  double bottomSheetOffset,
) {
  return Material(
      child: Container(
          height: 500,
          decoration: const BoxDecoration(
            color: Color.fromARGB(161, 226, 251, 255),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.5),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 112, 245, 130),
                            ),
                            height: 50,
                            child: const Center(child: Text('95 - 100%')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 154, 247, 167),
                            ),
                            height: 50,
                            child: const Center(
                                child: Text('Normal Blood Oxygen Level')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 238, 83),
                            ),
                            height: 50,
                            child: const Center(child: Text('91 - 95%')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 248, 235, 115),
                            ),
                            height: 50,
                            child: const Center(child: Text('Below standard')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 153, 70),
                            ),
                            height: 50,
                            child: const Center(child: Text('≤90%')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 250, 173, 128)),
                            height: 50,
                            child: const Center(child: Text('Too low')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 52, 2),
                            ),
                            height: 50,
                            child: const Center(child: Text('<67%')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 129, 97),
                            ),
                            height: 50,
                            child: const Center(child: Text('Cyanosis')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          )));
}

Widget _buildBottomSheet2(
  BuildContext context,
  ScrollController scrollController,
  double bottomSheetOffset,
) {
  return Material(
    child: Container(
        height: 800,
        decoration: const BoxDecoration(
          color: Color.fromARGB(161, 226, 251, 255),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text("Male resting heart rate",
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('AGE'))),
                        TableCell(child: Center(child: Text('Athlete'))),
                        TableCell(child: Center(child: Text('Excellent'))),
                        TableCell(child: Center(child: Text('Good'))),
                        TableCell(child: Center(child: Text('Average'))),
                        TableCell(child: Center(child: Text('Below average'))),
                        TableCell(child: Center(child: Text('Poor'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('18-25'))),
                        TableCell(child: Center(child: Text('49-55'))),
                        TableCell(child: Center(child: Text('56-61'))),
                        TableCell(child: Center(child: Text('62-65'))),
                        TableCell(child: Center(child: Text('70-73'))),
                        TableCell(child: Center(child: Text('74-81'))),
                        TableCell(child: Center(child: Text('82+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('26-35'))),
                        TableCell(child: Center(child: Text('49-54'))),
                        TableCell(child: Center(child: Text('55-61'))),
                        TableCell(child: Center(child: Text('62-65'))),
                        TableCell(child: Center(child: Text('71-74'))),
                        TableCell(child: Center(child: Text('75-81'))),
                        TableCell(child: Center(child: Text('82+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('36-45'))),
                        TableCell(child: Center(child: Text('50-56'))),
                        TableCell(child: Center(child: Text('57-62'))),
                        TableCell(child: Center(child: Text('63-66'))),
                        TableCell(child: Center(child: Text('71-75'))),
                        TableCell(child: Center(child: Text('76-82'))),
                        TableCell(child: Center(child: Text('83+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('46-55'))),
                        TableCell(child: Center(child: Text('50-57'))),
                        TableCell(child: Center(child: Text('58-63'))),
                        TableCell(child: Center(child: Text('64-67'))),
                        TableCell(child: Center(child: Text('72-76'))),
                        TableCell(child: Center(child: Text('77-83'))),
                        TableCell(child: Center(child: Text('84+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('56-65'))),
                        TableCell(child: Center(child: Text('51-56'))),
                        TableCell(child: Center(child: Text('57-61'))),
                        TableCell(child: Center(child: Text('62-67'))),
                        TableCell(child: Center(child: Text('72-75'))),
                        TableCell(child: Center(child: Text('76-81'))),
                        TableCell(child: Center(child: Text('82+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('>65'))),
                        TableCell(child: Center(child: Text('50-55'))),
                        TableCell(child: Center(child: Text('56-61'))),
                        TableCell(child: Center(child: Text('62-65'))),
                        TableCell(child: Center(child: Text('70-73'))),
                        TableCell(child: Center(child: Text('74-79'))),
                        TableCell(child: Center(child: Text('80+'))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Female resting heart rate",
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('AGE'))),
                        TableCell(child: Center(child: Text('Athlete'))),
                        TableCell(child: Center(child: Text('Excellent'))),
                        TableCell(child: Center(child: Text('Good'))),
                        TableCell(child: Center(child: Text('Average'))),
                        TableCell(child: Center(child: Text('Below average'))),
                        TableCell(child: Center(child: Text('Poor'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('18-25'))),
                        TableCell(child: Center(child: Text('54-70'))),
                        TableCell(child: Center(child: Text('61-65'))),
                        TableCell(child: Center(child: Text('66-69'))),
                        TableCell(child: Center(child: Text('74-78'))),
                        TableCell(child: Center(child: Text('79-84'))),
                        TableCell(child: Center(child: Text('85+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('26-35'))),
                        TableCell(child: Center(child: Text('54-59'))),
                        TableCell(child: Center(child: Text('60-64'))),
                        TableCell(child: Center(child: Text('65-68'))),
                        TableCell(child: Center(child: Text('73-76'))),
                        TableCell(child: Center(child: Text('77-82'))),
                        TableCell(child: Center(child: Text('83+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('36-45'))),
                        TableCell(child: Center(child: Text('54-59'))),
                        TableCell(child: Center(child: Text('60-64'))),
                        TableCell(child: Center(child: Text('65-69'))),
                        TableCell(child: Center(child: Text('74-78'))),
                        TableCell(child: Center(child: Text('79-84'))),
                        TableCell(child: Center(child: Text('85+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('46-55'))),
                        TableCell(child: Center(child: Text('54-60'))),
                        TableCell(child: Center(child: Text('61-65'))),
                        TableCell(child: Center(child: Text('66-69'))),
                        TableCell(child: Center(child: Text('74-77'))),
                        TableCell(child: Center(child: Text('78-83'))),
                        TableCell(child: Center(child: Text('84+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('56-65'))),
                        TableCell(child: Center(child: Text('54-59'))),
                        TableCell(child: Center(child: Text('60-64'))),
                        TableCell(child: Center(child: Text('65-68'))),
                        TableCell(child: Center(child: Text('74-77'))),
                        TableCell(child: Center(child: Text('78-83'))),
                        TableCell(child: Center(child: Text('84+'))),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('>65'))),
                        TableCell(child: Center(child: Text('54-59'))),
                        TableCell(child: Center(child: Text('60-64'))),
                        TableCell(child: Center(child: Text('65-68'))),
                        TableCell(child: Center(child: Text('73-76'))),
                        TableCell(child: Center(child: Text('77-84'))),
                        TableCell(child: Center(child: Text('84+'))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        )),
  );
}

Widget _buildBottomSheet3(
  BuildContext context,
  ScrollController scrollController,
  double bottomSheetOffset,
) {
  return Material(
      child: Container(
          height: 500,
          decoration: const BoxDecoration(
            color: Color.fromARGB(161, 226, 251, 255),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.5),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 240, 255, 29),
                            ),
                            height: 50,
                            child: const Center(child: Text('≤35.9°C')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 226, 241, 83),
                            ),
                            height: 50,
                            child:
                                const Center(child: Text('Lower than average')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 9, 253, 1),
                            ),
                            height: 50,
                            child: const Center(child: Text('36.0°C - 37.0°C')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 94, 255, 0),
                            ),
                            height: 50,
                            child: const Center(child: Text('Normal')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 153, 70),
                            ),
                            height: 50,
                            child: const Center(child: Text('37.1°C - 38.0°C')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 250, 173, 128)),
                            height: 50,
                            child: const Center(
                                child: Text('Higher than average')),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 52, 2),
                            ),
                            height: 50,
                            child: const Center(child: Text('38.1°C - 42.2°C')),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 129, 97),
                            ),
                            height: 50,
                            child: const Center(child: Text('Fever')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          )));
}

class _ChartData {
  _ChartData(this.time, this.value);
  final int time;
  final num value;
}
