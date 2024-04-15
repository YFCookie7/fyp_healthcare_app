import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'dart:developer' as developer;
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String textbox = 'Hi';

  @override
  void initState() {
    super.initState();
    BluetoothBLE.registerCallback(_handleDataReceived);
    BluetoothBLE.connectToDevice();
    // _checkBtStatus();
  }

  @override
  void dispose() {
    BluetoothBLE.unregisterCallback(_handleDataReceived);
    BluetoothBLE.disconnectedDevice();
    super.dispose();
  }

  void _handleDataReceived(String data) {
    developer.log(data, name: 'debug.home');
    setState(() {
      textbox = "$data home ${Random().nextInt(1000)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: Text(
                textbox,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  startAngle: 0,
                  endAngle: 180,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
