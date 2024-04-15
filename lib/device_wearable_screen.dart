import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
  int heartbeatValue = 60;
  double heartbeatValue_double = 0.0;

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
      textbox = "$data ${Random().nextInt(1000)}";
      developer.log(data, name: 'debug.device_watch');

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
      tempValue = 34 + Random().nextDouble() * (40 - 34);
      heartbeatValue = 60 + Random().nextInt(40);
      heartbeatValue_double = ((heartbeatValue) * (90) / (160));
      developer.log(heartbeatValue_double.toString(),
          name: 'debug.device_watch');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                textbox,
                style: const TextStyle(fontSize: 20),
              ),
              SizedBox(
                width: 250,
                height: 250,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(minimum: 34, maximum: 40, ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 34, endValue: 36, color: Colors.green),
                    GaugeRange(
                        startValue: 36, endValue: 38, color: Colors.orange),
                    GaugeRange(startValue: 38, endValue: 40, color: Colors.red)
                  ], pointers: <GaugePointer>[
                    NeedlePointer(value: tempValue, enableAnimation: true)
                  ], annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        widget: Container(
                          width: 140.00,
                          height: 50.00,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Image(
                                image: ExactAssetImage(
                                    'assets/icon/body_temperature.png'),
                                fit: BoxFit.fitHeight,
                                height: 35,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${tempValue.toStringAsFixed(1)}°C",
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.5)
                  ]),
                ]),
              ),
              SizedBox(
                width: 250,
                height: 250,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(
                      interval: 10,
                      startAngle: 270,
                      endAngle: 270,
                      showTicks: false,
                      showLabels: false,
                      axisLineStyle: AxisLineStyle(thickness: 20),
                      pointers: <GaugePointer>[
                        RangePointer(
                            value: heartbeatValue_double,
                            width: 20,
                            color: Color(0xFFFFCD60),
                            enableAnimation: true,
                            cornerStyle: CornerStyle.bothCurve)
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Column(
                              children: <Widget>[
                                Container(
                                  width: 200.00,
                                  height: 80.00,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        'assets/lottie/heartbeat_lottie.json',
                                        width: 90,
                                        height: 90,
                                        // fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${heartbeatValue.toStringAsFixed(0)} bpm',
                                        style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            angle: 270,
                            positionFactor: 0)
                      ])
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
