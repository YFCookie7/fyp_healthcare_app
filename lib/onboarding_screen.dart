import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';

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

// Wearable Sleep Tracker: Seamless sleep tracking with our Wearable Sleep Tracker! Actively monitor your sleep on the go, ensuring you get the most accurate insights wherever life takes you.
// Sleep Cycles: Tracks your sleep cycles, monitor and improves your sleeping habits
// Sleep Score: Receive a personalized Sleep Score, tailored insights for optimal rest.
// Smart Alarm: Wake up gently during your light sleep phase, ensuring you start your day feeling refreshed and ready to conquer your goals.
// Handle your data: Store your sleep data safely..??

    final List<SubPages> pages = [
      SubPages(
        backgroundPath: 'assets/background/onboarding_p1.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_3.json',
        title: 'Sleep Cycle',
        description:
            'Dive into the realm of improved sleep habits as we meticulously track your sleep cycles. Understand, monitor, and elevate your nightly rejuvenation.',
        isLastPage: false,
      ),
      SubPages(
        backgroundPath: 'assets/background/onboarding_p2.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_1.json',
        title: 'Wearable Sleep Tracker',
        description:
            'Seamlessly track your sleep with our Wearable Sleep Tracker. Effortlessly monitor your sleep on the go, ensuring precise insights no matter where life takes you.',
        isLastPage: false,
      ),
      SubPages(
        backgroundPath: 'assets/background/onboarding_p1.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_4.json',
        title: 'Sleep Score',
        description:
            'Experience a tailored journey with your very own Sleep Score. Receive personalized insights for optimal rest, guiding you towards a world of peaceful slumber.',
        isLastPage: false,
      ),
      SubPages(
        backgroundPath: 'assets/background/onboarding_p2.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_2.json',
        title: 'Smart Alarm',
        description:
            'Awaken gently during your light sleep phase, ensuring you start each day refreshed and prepared to conquer your goals. Say goodbye to groggy mornings!',
        isLastPage: false,
      ),
      SubPages(
        backgroundPath: 'assets/background/onboarding_p1.jpg',
        lottiePath: 'assets/lottie/onboarding_lottie_5.json',
        title: 'Handle your data',
        description:
            'Your data is encrypted and stored safely. We ensure that your sleep data is secure and private. No network connection required.',
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
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                  (route) => false,
                );
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
          Text(
            page.title,
            style: const TextStyle(
              fontFamily: 'PatuaOne',
              fontSize: 34,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: 300,
            child: Text(
              page.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          if (page.isLastPage) const SizedBox(height: 55),
          if (page.isLastPage)
            Container(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Get Started',
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
