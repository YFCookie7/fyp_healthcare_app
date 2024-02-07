import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/menu_screen.dart';
import 'package:fyp_healthcare_app/onboarding_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool? firstLaunch = prefs.getBool('first_launch');
      if (firstLaunch == null || firstLaunch == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuScreen()),
        );
      }
    });

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/splash_background.jpg'),
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
                  fontFamily: 'ProtestRiot', fontSize: 44, color: Colors.white),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Lottie.asset(
                'assets/loading_lottie.json',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    ));
  }
}