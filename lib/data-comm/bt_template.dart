import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BtTemplate extends StatefulWidget {
  const BtTemplate({Key? key}) : super(key: key);

  @override
  _BtTemplateState createState() => _BtTemplateState();
}

class _BtTemplateState extends State<BtTemplate> {
  final String deviceName = "HMSoft";
  final String deviceAddress = "C8:FD:19:91:1B:65";
  String textbox = 'Hi';
  late BluetoothDevice _device;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  List<StreamSubscription<List<int>>> _characteristicSubscriptions = [];

  @override
  void initState() {
    super.initState();

    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  }

  @override
  void dispose() {
    // 1. connect, disconnect, repeat
    // 2. connect, pop back, repeat
    // 3. connect, disconnect, pop back, repeat

    _disconnectedDevice();
    super.dispose();
  }

  // Check connection state
  Future<void> _getConnectedState() async {
    List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
    if (devs.isEmpty) {
      setState(() {
        textbox = "Not connected to wearable device ${Random().nextInt(1000)}";
      });
      developer.log("Not connected to wearable device", name: 'debug_bt2');
      return;
    } else {
      setState(() {
        textbox =
            "Already connected to wearable device ${Random().nextInt(1000)}";
      });
      developer.log("Already connected to wearable device", name: 'debug_bt2');
    }
  }

  // Connect to the device
  Future<void> _connectToDevice() async {
    bool found = false;
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) async {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device

          if (r.device.remoteId.toString() == deviceAddress) {
            found = true;
            developer.log(
                '${r.device.remoteId}: "${r.advertisementData.advName}" found!',
                name: 'debug_bt2');

            setState(() {
              textbox = "Device found! ${Random().nextInt(1000)}";
            });
            _device = r.device;
            FlutterBluePlus.stopScan();

            _connectionSubscription = _device.connectionState
                .listen((BluetoothConnectionState state) async {
              developer.log("Connection state: $state", name: 'debug_bt2');
              if (state == BluetoothConnectionState.connected) {
                developer.log("Connected. Start reading data.",
                    name: 'debug_bt2');
                await _readDataStream();
              } else if (state == BluetoothConnectionState.disconnected) {
                developer.log("Disconnected, reconnecting", name: 'debug_bt2');
                await _device.connect();
              }
            });
          }
        }
      },
      onError: (e) => developer.log(e.toString(), name: 'debug_bt2'),
    );
    if (!found) {
      setState(() {
        textbox = "Device not found! ${Random().nextInt(1000)}";
      });
      developer.log("Device not found", name: 'debug_bt2');
    }

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(
        withServices: [Guid("180D")],
        withNames: ["HMSoft"],
        timeout: const Duration(seconds: 5));

    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  // Disconnect from the device
  Future<void> _disconnectedDevice() async {
    _connectionSubscription?.cancel();
    for (var subscription in _characteristicSubscriptions) {
      subscription.cancel();
    }
    _characteristicSubscriptions.clear();
    _device.disconnect();
    developer.log("Connection closed", name: 'debug_bt2');
  }

  // Read data from the device
  Future<void> _readDataStream() async {
    List<BluetoothService> services = await _device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.read) {
          final subscription = characteristic.onValueReceived.listen((value) {
            String stringValue = String.fromCharCodes(value);
            setState(() {
              textbox = "$stringValue  ${Random().nextInt(1000)}";
            });
            developer.log(
                "Received data: $stringValue ${Random().nextInt(1000)}",
                name: 'debug_bt2');
          });

          _device.cancelWhenDisconnected(subscription);

          await characteristic.setNotifyValue(true);
          _characteristicSubscriptions.add(subscription);
        }
      }
    }
  }

  // Send data to the device
  Future<void> _sendMessage(String message) async {
    // uuid: 0000ffe1-0000-1000-8000-00805f9b34fb
    List<BluetoothService> services = await _device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.writeWithoutResponse &&
            characteristic.properties.write) {
          List<int> bytes = utf8.encode(message);
          developer.log("Sending data: $message", name: 'debug_bt2');

          await characteristic.write(bytes);
        }
      }
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
              onPressed: () => _connectToDevice(),
              child: const Text('Connect to device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _getConnectedState(),
              child: const Text('Get connected device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _disconnectedDevice(),
              child: const Text('Disonnected device'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  _sendMessage("!Hi_${Random().nextInt(1000).toString()}_%;"),
              child: const Text('Write Sth to device'),
            ),
          ],
        ),
      ),
    );
  }
}
