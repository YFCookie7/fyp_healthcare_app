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
  static List<DataReceivedCallback> callbacks_list = [];

  static void registerCallback(DataReceivedCallback callback) {
    callbacks_list.add(callback);
  }

  static void unregisterCallback(DataReceivedCallback callback) {
    callbacks_list.remove(callback);
  }

  // Check connection state
  static Future<void> getConnectedState() async {
    List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
    if (devs.isEmpty) {
      developer.log("Not connected to wearable device", name: 'debug.ble');
      return;
    } else {
      developer.log("Already connected to wearable device", name: 'debug.ble');
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
                name: 'debug.ble');

            _device = r.device;
            FlutterBluePlus.stopScan();

            _connectionSubscription = _device.connectionState
                .listen((BluetoothConnectionState state) async {
              developer.log("Connection state: $state", name: 'debug.ble');
              if (state == BluetoothConnectionState.connected) {
                developer.log("Connected. Start reading data.",
                    name: 'debug.ble');
                await readDataStream();
              } else if (state == BluetoothConnectionState.disconnected) {
                developer.log("Disconnected, reconnecting", name: 'debug.ble');
                await _device.connect();
              }
            });
          }
        }
      },
      onError: (e) => developer.log(e.toString(), name: 'debug.ble'),
    );
    if (!found) {
      developer.log("Device not found", name: 'debug.ble');
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
    developer.log("Connection closed", name: 'debug.ble');
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
                name: 'debug.ble');
            // invoke data callback
            // onDataReceived?.call(stringValue);
            for (var callback in callbacks_list) {
              callback(stringValue);
            }
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
          developer.log("Sending data: $message", name: 'debug.ble');

          await characteristic.write(bytes);
        }
      }
    }
  }
}
