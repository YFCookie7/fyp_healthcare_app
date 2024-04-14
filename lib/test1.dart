import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'dart:math';
import 'package:fyp_healthcare_app/data-comm/bt_template.dart';
import 'dart:developer' as developer;
import 'package:fyp_healthcare_app/device_panel_screen.dart';
import 'package:fyp_healthcare_app/device_wearable_screen.dart';

class Test1 extends StatefulWidget {
  const Test1({Key? key}) : super(key: key);

  @override
  _Test1State createState() => _Test1State();
}

class _Test1State extends State<Test1> {
  String receivedData = '';

  @override
  void initState() {
    super.initState();
    BluetoothBLE.registerCallback(_handleDataReceived);
    //BluetoothBLE.connectToDevice();
  }

  @override
  void dispose() {
    BluetoothBLE.unregisterCallback(_handleDataReceived);
    //BluetoothBLE.disconnectedDevice();
    super.dispose();
  }

  void _handleDataReceived(String data) {
    setState(() {
      receivedData = data;
      developer.log(data, name: 'debug.test1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test 1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Wearable Device $receivedData ${Random().nextInt(1000)}'),
            // const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () => BluetoothBLE.connectToDevice(),
            //   child: const Text('Connect to device'),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, //=> BluetoothBLE.isConnected(),
              //onPressed: () => BluetoothBLE.readDataStream(),
              child: const Text('Get connected device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, //BluetoothBLE.disconnectedDevice(),
              child: const Text('Disconnected device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WearableDeviceScreen()),
                );
              },
              child: const Text('Plot'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => BluetoothBLE.sendMessage(
                  "!Hi_${Random().nextInt(1000).toString()}_%;"),
              child: const Text('Send Data'),
            ),
          ],
        ),
      ),
    );
  }
}
