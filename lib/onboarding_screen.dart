import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/menu.dart';
import 'package:fyp_healthcare_app/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int activePageIndex = 0;

  @override
  Widget build(BuildContext context) {
    setFirstLaunchFlag(true);

    final List<SubPages> pages = [
      SubPages(
        backgroundPath: 'assets/background/onboarding_p1.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_1.json',
        title: 'Monitor your biosignal',
        description:
            'By pairing with the wearable watch, you can monitor your real-time biosignal such as heart rate, body temperature, and spo2.',
        isLastPage: false,
      ),
      SubPages(
        backgroundPath: 'assets/background/onboarding_p2.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_3.json',
        title: 'Evaulate your sleep quality',
        description:
            'Evaluate your sleep quality by analysing your biosignals and sleep stages. Receive useful feedback with a detailed report and sleep score',
        isLastPage: false,
      ),
      SubPages(
        backgroundPath: 'assets/background/onboarding_p1.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_2.json',
        title: 'Smart alarm clock',
        description:
            'Sleep tracker can track your sleep cycle and wake you up at the optimal time so you feel refreshed and energized.',
        isLastPage: false,
      ),
      SubPages(
        backgroundPath: 'assets/background/onboarding_p2.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_5.json',
        title: 'Secured data management',
        description:
            'Your data is stored locally with highest security. You can safely import/export your data with encrypted file.',
        isLastPage: false,
      ),
      SubPages(
        backgroundPath: 'assets/background/onboarding_p1.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_6.json',
        title: 'Permission is required',
        description:
            'This app requires bluetooth permission to fully access the app features!',
        isLastPage: true,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: pages.map((page) => buildPage(context, page)).toList(),
            fullTransitionValue: 300,
            slideIconWidget: const Icon(Icons.arrow_forward_ios,
                size: 30, color: Colors.white),
            positionSlideIcon: 0.8,
            enableLoop: false,
            // waveType: WaveType.circularReveal,
            onPageChangeCallback: (page) {
              setState(() {
                activePageIndex = page;
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 55.0),
              child: AnimatedSmoothIndicator(
                activeIndex: activePageIndex,
                count: pages.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildPage(BuildContext context, SubPages page) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(page.backgroundPath),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () async {
                grantPermission();
                createProfile();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Menu()),
                  (route) => false,
                );
                ;
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Icon(Icons.skip_next, color: Colors.white),
                  SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Lottie.asset(
            page.lottiePath,
            height: 260,
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PatuaOne',
                fontSize: 34,
                color: Color.fromARGB(255, 69, 66, 204),
              ),
            ),
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: 300,
            child: Text(
              page.description,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 69, 66, 204),
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          if (page.isLastPage) const SizedBox(height: 45),
          if (page.isLastPage)
            Container(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              child: TextButton(
                onPressed: () {
                  grantPermission();
                  createProfile();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Menu()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Grant permission ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> setFirstLaunchFlag(bool flag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', flag);
  }

  Future<void> grantPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.accessMediaLocation,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
  }

  Future<void> createProfile() async {
    setFirstLaunchFlag(false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');
    if (username == null) {
      const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final random = Random();
      String randomLetter = '';
      for (int i = 0; i < 5; i++) {
        randomLetter += characters[random.nextInt(characters.length)];
      }
      await prefs.setString('username', "user_$randomLetter");
      developer.log("User user_$randomLetter created!",
          name: "debug.onboarding");
    }
  }
}

class SubPages {
  late final String backgroundPath;
  late final String lottiePath;
  late final String title;
  late final String description;
  late final bool isLastPage;

  SubPages({
    required this.backgroundPath,
    required this.lottiePath,
    required this.title,
    required this.description,
    required this.isLastPage,
  });
}
