import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:developer' as developer;

class BT extends StatefulWidget {
  const BT({Key? key}) : super(key: key);

  @override
  _BTState createState() => _BTState();
}

// is bonded
// repeat scan without freezing
// connect
// is connected
// open read stream
// send data stream

class _BTState extends State<BT> {
  final String btAddress = "98:D3:B1:FD:6C:2B";
  String textbox = 'Hi';
  bool isDiscovering = false;
  late BluetoothConnection? _bluetoothConnection;

  @override
  void initState() {
    super.initState();

    _checkIsPaired().then((isPaired) {
      if (!isPaired) {
        developer.log("Not paired:", name: 'debug_bt');
        _connectToDevice();
      } else {
        developer.log("Paired", name: 'debug_bt');
      }
    });
  }

  Future<bool> _checkIsPaired() async {
    List<BluetoothDevice> devices = [];
    bool isPaired = false;
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      developer.log("Error getting paired devices: $e",
          error: e, name: 'debug_bt');
    }

    if (devices.isEmpty) {
      developer.log("Not paired with wearable device.", name: 'debug_bt');
      return false;
    } else {
      for (BluetoothDevice device in devices) {
        if (device.address == btAddress) {
          isPaired = true;
          developer.log(
              "Already paired with wearable device: ${device.name} (${device.address})",
              name: 'debug_bt');
          setState(() {
            textbox = "Already paired with wearable device.";
          });
          return true;
        }
      }
    }
    if (!isPaired) {
      developer.log("Not paired with wearable device.", name: 'debug_bt');
      setState(() {
        textbox = "Not paired with wearable device.";
      });
    }
    return false;
  }

  Future<void> _scanBluetoothDevices() async {
    FlutterBluetoothSerial.instance.cancelDiscovery();
    developer.log("$isDiscovering", name: 'debug_bt');
    if (isDiscovering) {
      developer.log("Cancelling previous discovery.", name: 'debug_bt');
      await FlutterBluetoothSerial.instance.cancelDiscovery();
    }
    try {
      isDiscovering = true;
      FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
        developer.log(
            "Discovered device: ${device.device.name}, ${device.device.address}");
        if (device.device.address == btAddress) {
          developer.log("Wearable device found.", name: 'debug_bt');
          setState(() {
            textbox = "Wearable device found.";
          });
          FlutterBluetoothSerial.instance.cancelDiscovery();
          isDiscovering = false;
          return;
        }
      }, onDone: () {
        developer.log("Discovery finished.", name: 'debug_bt');
      });
      developer.log("Wearable device not found.", name: 'debug_bt');
    } catch (e) {
      developer.log("Error during discovery: $e", error: e, name: 'debug_bt');
    } finally {
      FlutterBluetoothSerial.instance.cancelDiscovery();
      isDiscovering = false;
    }
  }

  Future<void> _connectToDevice() async {
    try {
      _bluetoothConnection = await BluetoothConnection.toAddress(btAddress);
      // await _bluetoothConnection!.close();
      developer.log("Connecting to wearable device... Successful",
          name: 'debug_bt');
    } catch (e) {
      developer.log("Error connecting to wearable device: $e",
          error: e, name: 'debug_bt');
    }
  }

  Future<void> _readFromStream() async {
    try {
      _bluetoothConnection = await BluetoothConnection.toAddress(btAddress);

      _bluetoothConnection!.input!.listen((data) {
        String receivedData = String.fromCharCodes(data);
        developer.log("Received data from wearable device: $receivedData",
            name: 'debug_bt');
      }, onError: (e) {
        developer.log("Error reading from stream: $e",
            error: e, name: 'debug_bt');
      }, onDone: () {
        developer.log("Stream closed", name: 'debug_bt');
      });

      developer.log("Connected to wearable device", name: 'debug_bt');
    } catch (e) {
      developer.log("Error connecting to wearable device: $e",
          error: e, name: 'debug_bt');
    }
  }

  Future<void> _setupBluetoothConnection() async {
    try {
      if (_bluetoothConnection != null && _bluetoothConnection!.isConnected) {
        developer.log('Already connected to the device');
        return;
      }

      _bluetoothConnection = await BluetoothConnection.toAddress(btAddress);
      developer.log('Connected to the device');

      Timer(const Duration(seconds: 5), () {
        if (_bluetoothConnection != null && _bluetoothConnection!.isConnected) {
          _bluetoothConnection!.finish();
          developer.log('Disconnected after 5 seconds');
        }
      });

      _bluetoothConnection?.input?.listen((Uint8List data) {
        developer.log('Data incoming: ${ascii.decode(data)}');
        _bluetoothConnection?.output.add(data);
      }).onDone(() {
        developer.log('Disconnected by remote request');
      });
    } catch (exception) {
      developer.log('Cannot connect, exception occurred $exception');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textbox,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _checkIsPaired(),
              child: const Text('Check paired device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _scanBluetoothDevices(),
              child: const Text('Scan Wearable Devices'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _connectToDevice(),
              child: const Text('Connect to device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _setupBluetoothConnection(),
              child: const Text('Read Bluetooth Serial'),
            ),
          ],
        ),
      ),
    );
  }
}
