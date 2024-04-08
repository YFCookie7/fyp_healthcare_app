import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SfRadialGauge(axes: <RadialAxis>[
          RadialAxis(
            startAngle: 0,
            endAngle: 180,
          )
        ]),
      ),
    );
  }
}
