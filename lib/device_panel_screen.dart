import 'package:flutter/material.dart';

class PanelDeviceScreen extends StatelessWidget {
  const PanelDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel'),
      ),
      body: const Center(
        child: Text('Panel'),
      ),
    );
  }
}
