import 'package:flutter/material.dart';
import 'package:frontend/screens/login/splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/pageview.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class ItemData {
  final String title;
  final String subtitle;
  final ImageProvider image;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Widget background;

  ItemData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.background,
  });
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final data = [
    ItemData(
      title: "ONE CLICK TRACKING",
      subtitle: "Track your income and expenses.",
      image: const AssetImage("assets/images/onboarding/image-1.gif"),
      backgroundColor: const Color.fromRGBO(0, 10, 56, 1),
      titleColor: Colors.amber,
      subtitleColor: Colors.white,
      background: Lottie.network(
        'https://assets2.lottiefiles.com/packages/lf20_bq485nmk.json',
      ),
    ),
    ItemData(
      title: "INTUITIVE GRAPHS",
      subtitle: "Know where your money goes.",
      image: const AssetImage("assets/images/onboarding/image-2.gif"),
      backgroundColor: Colors.white,
      titleColor: const Color.fromRGBO(0, 10, 56, 1),
      subtitleColor: Colors.black,
      background: Lottie.network(
        'https://assets2.lottiefiles.com/packages/lf20_bq485nmk.json',
      ),
    ),
    ItemData(
      title: "TRACK YOUR GOALS",
      subtitle: "Achieve your financial goals.",
      image: const AssetImage("assets/images/onboarding/image-3.png"),
      backgroundColor: const Color.fromRGBO(0, 10, 56, 1),
      titleColor: Colors.orange.shade600,
      subtitleColor: Colors.white,
      background: Lottie.network(
        'https://assets2.lottiefiles.com/packages/lf20_bq485nmk.json',
      ),
    ),
    ItemData(
      title: "SPLIT BILLS",
      subtitle: "Split bills with your family, friends.",
      image: const AssetImage("assets/images/onboarding/image-4.png"),
      backgroundColor: Colors.white,
      titleColor: const Color.fromRGBO(0, 10, 56, 1),
      subtitleColor: Colors.black,
      background: Lottie.network(
        'https://assets2.lottiefiles.com/packages/lf20_bq485nmk.json',
      ),
    ),
  ];

  int currentPageNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
        radius: 40,
        colors: data.map((e) => e.backgroundColor).toList(),
        itemCount: data.length,
        direction: Axis.vertical,
        onFinish: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool("isOnBoardingVisited", true);
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(SplashScreen.routeName, (route) => false);
        },
        onChange: (page) {
          setState(() {
            currentPageNumber = page + 1;
          });
        },
        itemBuilder: (int index, double value) {
          return SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0, top: 20.0),
                    child: Text(
                      "$currentPageNumber/4",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(child: ItemWidget(data: data[index])),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({required this.data, super.key});

  final ItemData data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 1, child: Image(image: data.image)),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          color: data.titleColor,
                          fontSize: 22,
                          fontFamily: "CircularStd",
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        data.subtitle,
                        style: TextStyle(
                          color: data.subtitleColor,
                          fontSize: 20,
                          fontFamily: "CircularStd",
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
