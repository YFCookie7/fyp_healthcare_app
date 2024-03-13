import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/background/registration_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80.0),
                    const Text(
                      'Sleep Tracker',
                      style: TextStyle(
                          fontFamily: 'ProtestRiot',
                          fontSize: 44,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10.0),
                  ]),
            )));
  }
}
