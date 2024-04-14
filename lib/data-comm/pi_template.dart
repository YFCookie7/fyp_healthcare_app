import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';

class PiTemplate extends StatefulWidget {
  const PiTemplate({Key? key}) : super(key: key);

  @override
  _PiTemplateState createState() => _PiTemplateState();
}

class _PiTemplateState extends State<PiTemplate> {
  late final String piAddress;
  static const String apiUrl = 'http://192.168.1.109:5000';
  String textbox = 'Hi';

  @override
  void initState() {
    super.initState();
    getPiAddress();
  }

  Future<void> getPiAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    piAddress = prefs.getString('piAddress') ?? '';
    developer.log('PI Address in PI screen: $piAddress', name: 'debug_pi');
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
              onPressed: () {
                setState(() {
                  makeGetRequest();
                  // makePostRequest();
                  // textbox = piAddress;
                });
              },
              child: const Text('Button'),
            ),
          ],
        ),
      ),
    );
  }

  // App request data from Pi
  Future<void> makeGetRequest() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        developer.log('GET request successful. Response: ${response.body}',
            name: 'debug_pi');
        setState(() {
          textbox = response.body;
        });
      } else {
        developer.log(
            'GET request failed with status code: ${response.statusCode}',
            name: 'debug_pi');
      }
    } catch (error) {
      developer.log('Error making GET request: $error', name: 'debug_pi');
    }
  }

  // App sends data to Pi
  Future<void> makePostRequest() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'key': 'value1'}),
      );

      if (response.statusCode == 200) {
        developer.log('POST request successful: ${response.body}',
            name: 'debug_pi');
      } else {
        developer.log('POST request failed with status: ${response.statusCode}',
            name: 'debug_pi');
      }
    } catch (error) {
      developer.log('Error making POST request: $error', name: 'debug_pi');
    }
  }
}
