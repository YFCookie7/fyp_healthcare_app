import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'dart:math';
import 'package:fyp_healthcare_app/data-comm/bt_template.dart';
import 'dart:developer' as developer;

class WearableDeviceScreen extends StatefulWidget {
  const WearableDeviceScreen({Key? key}) : super(key: key);

  @override
  _WearableDeviceScreenState createState() => _WearableDeviceScreenState();
}

class _WearableDeviceScreenState extends State<WearableDeviceScreen> {
  String receivedData = '';
  String textbox = 'Hi';
  double tempValue = 37.0;

  String titleText = "Connecting to device";
  String redText = "redText";
  String irText = "irText";
  String tempAText = "tempAText";
  String tempOText = "tempOText";
  String gyroXText = "gyroXText";
  String gyroYText = "gyroYText";
  String gyroZText = "gyroZText";

  @override
  void initState() {
    super.initState();
    BluetoothBLE.registerCallback(_handleDataReceived);
    BluetoothBLE.connectToDevice();
    // titleText = await BluetoothBLE.connectToDevice();

    // if(await BluetoothBLE.isConnected())
    // {
    //   await BluetoothBLE.readDataStream();
    // }

    // const oneSec = Duration(seconds: 1);
    // Timer.periodic(oneSec, (Timer t) async {
    //   if (await BluetoothBLE.isConnected()) {
    //     BluetoothBLE.registerCallback(_handleDataReceived);
    //   } else {
    //     BluetoothBLE.unregisterCallback(_handleDataReceived);
    //     // titleText = await BluetoothBLE.connectToDevice();
    //   }
    // });
  }

  @override
  void dispose() {
    BluetoothBLE.unregisterCallback(_handleDataReceived);
    BluetoothBLE.disconnectedDevice();
    super.dispose();
  }

  void _handleDataReceived(String data) {
    setState(() {
      // List<int> datum = data.codeUnits;
      // var value = datum[1] * 256 + datum[0];
      // redText = "$value";
      // value = datum[3] * 256 + datum[2];
      // irText = "$value";
      // value = datum[5] * 256 + datum[4];
      // tempAText = "$value";
      // value = datum[7] * 256 + datum[6];
      // tempOText = "$value";
      // value = datum[9] * 256 + datum[8];
      // gyroXText = "$value";
      // value = datum[11] * 256 + datum[10];
      // gyroYText = "$value";
      // value = datum[13] * 256 + datum[12];
      // gyroZText = "$value";
      textbox = "$data ${Random().nextInt(1000)}";
      developer.log(data, name: 'debug.device_watch');
      tempValue = 34 + Random().nextDouble() * (40 - 34);
      //BluetoothBLE.sendMessage("OK\n");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              textbox,
              style: const TextStyle(fontSize: 20),
            ),
            SfRadialGauge(axes: <RadialAxis>[
              RadialAxis(minimum: 34, maximum: 40, ranges: <GaugeRange>[
                GaugeRange(startValue: 34, endValue: 36, color: Colors.green),
                GaugeRange(startValue: 36, endValue: 38, color: Colors.orange),
                GaugeRange(startValue: 38, endValue: 40, color: Colors.red)
              ], pointers: <GaugePointer>[
                NeedlePointer(value: tempValue, enableAnimation: true)
              ], annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    widget: Container(
                        child: Text(tempValue.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold))),
                    angle: 90,
                    positionFactor: 0.5)
              ])
            ])
          ],
        ),
      ),
    );
  }
}
