import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:math';

typedef DataReceivedCallback = void Function(String data);

class BluetoothBLE {
  static const String deviceName = "HMSoft";
  static const String deviceAddress = "C8:FD:19:91:1B:65";
  static late BluetoothDevice _device;
  static late StreamSubscription<BluetoothConnectionState>?
      _connectionSubscription;
  static List<StreamSubscription<List<int>>> _characteristicSubscriptions = [];

  static DataReceivedCallback? onDataReceived;

  // Check connection state
  static Future<void> getConnectedState() async {
    List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
    if (devs.isEmpty) {
      developer.log("Not connected to wearable device", name: 'debug_bt2');
      return;
    } else {
      developer.log("Already connected to wearable device", name: 'debug_bt2');
    }
  }

  // Connect to the device
  static Future<void> connectToDevice() async {
    bool found = false;
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) async {
        if (results.isNotEmpty) {
          ScanResult r = results.last;

          if (r.device.remoteId.toString() == deviceAddress) {
            found = true;
            developer.log(
                '${r.device.remoteId}: "${r.advertisementData.advName}" found!',
                name: 'debug_bt2');

            _device = r.device;
            FlutterBluePlus.stopScan();

            _connectionSubscription = _device.connectionState
                .listen((BluetoothConnectionState state) async {
              developer.log("Connection state: $state", name: 'debug_bt2');
              if (state == BluetoothConnectionState.connected) {
                developer.log("Connected. Start reading data.",
                    name: 'debug_bt2');
                await readDataStream();
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
  static Future<void> disconnectedDevice() async {
    _connectionSubscription?.cancel();
    for (var subscription in _characteristicSubscriptions) {
      subscription.cancel();
    }
    _characteristicSubscriptions.clear();
    _device.disconnect();
    developer.log("Connection closed", name: 'debug_bt2');
  }

  // Read data from the device
  static Future<void> readDataStream() async {
    List<BluetoothService> services = await _device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.read) {
          final subscription = characteristic.onValueReceived.listen((value) {
            String stringValue = String.fromCharCodes(value);
            developer.log(
                "Received data: $stringValue ${Random().nextInt(1000)}",
                name: 'debug_bt2');
            // invoke data callback
            onDataReceived?.call(stringValue);
          });

          _device.cancelWhenDisconnected(subscription);

          await characteristic.setNotifyValue(true);
          _characteristicSubscriptions.add(subscription);
        }
      }
    }
  }

  // Send data to the device
  static Future<void> sendMessage(String message) async {
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
}
