import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  String textbox = 'Hi';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              onPressed: () async {
                final alarmSettings = AlarmSettings(
                  id: 42,
                  dateTime: DateTime.now().add(const Duration(seconds: 20)),
                  assetAudioPath: 'assets/audio/alarm.mp3',
                  loopAudio: false,
                  vibrate: true,
                  volume: 0.8,
                  fadeDuration: 3.0,
                  notificationTitle: 'This is the title',
                  notificationBody: 'This is the body',
                  enableNotificationOnKill: true,
                  androidFullScreenIntent: true,
                );
                await Alarm.set(alarmSettings: alarmSettings);
              },
              child: const Text('Button'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Alarm.stop(42);
              },
              child: const Text('Button'),
            ),
          ],
        ),
      ),
    );
  }
}
