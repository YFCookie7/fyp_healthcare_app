import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/menu.dart';
import 'package:fyp_healthcare_app/onboarding_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1500), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool? firstLaunch = prefs.getBool('first_launch');
      if (firstLaunch == null || firstLaunch == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Menu()),
          (route) => false,
        );
      }
    });

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background/splash_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80.0),
            const Text(
              'Health Tracker',
              style: TextStyle(
                  fontFamily: 'ProtestRiot', fontSize: 44, color: Colors.white),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Lottie.asset(
                'assets/lottie/loading_lottie2.json',
                // width: 200,
                // height: 200,
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    ));
  }
}
