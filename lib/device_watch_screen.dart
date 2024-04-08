import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/data-comm/ble.dart';
import 'dart:math';
import 'package:fyp_healthcare_app/data-comm/bt2.dart';
import 'dart:developer' as developer;
import 'package:fyp_healthcare_app/device_panel_screen.dart';

class WearableDeviceScreen extends StatefulWidget {
  const WearableDeviceScreen({Key? key}) : super(key: key);

  @override
  _WearableDeviceScreenState createState() => _WearableDeviceScreenState();
}

class _WearableDeviceScreenState extends State<WearableDeviceScreen> {
  String receivedData = '';

  @override
  void initState() {
    super.initState();
    BluetoothBLE.onDataReceived = _handleDataReceived;
    BluetoothBLE.connectToDevice();
  }

  @override
  void dispose() {
    BluetoothBLE.disconnectedDevice();
    BluetoothBLE.onDataReceived = null;
    super.dispose();
  }

  void _handleDataReceived(String data) {
    setState(() {
      receivedData = data;
      developer.log(data, name: 'debug.device_watch');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wearable Device'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Wearable Device $receivedData ${Random().nextInt(1000)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => BluetoothBLE.connectToDevice(),
              child: const Text('Connect to device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => BluetoothBLE.getConnectedState(),
              child: const Text('Get connected device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => BluetoothBLE.disconnectedDevice(),
              child: const Text('Disonnected device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => BluetoothBLE.sendMessage(
                  "!Hi_${Random().nextInt(1000).toString()}_%;"),
              child: const Text('Write Sth to device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PanelDeviceScreen()),
                );
              },
              child: const Text('Next page'),
            ),
          ],
        ),
      ),
    );
  }
}
