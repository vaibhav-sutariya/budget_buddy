import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../profile/create_profile_screen.dart';
import 'mobile_number_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splashScreen';
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    check();
    super.initState();
  }

  void check() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");
    bool? isProfileCreated = prefs.getBool("isProfileCreated");

    Duration d = const Duration(milliseconds: 1200);

    if (token != null) {
      //check user has created his profile or not
      if (isProfileCreated == true) {
        Timer(d, () {
          //user has already logged in and profile is created
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
        });
      } else {
        Timer(d, () {
          //user has already logged in but not created profile
          Navigator.of(context).pushNamedAndRemoveUntil(
            CreateProfileScreen.routeName,
            (route) => false,
          );
        });
      }
    } else {
      //new user
      Timer(d, () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          MobileNumberScreen.routeName,
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: const SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  "Budget Buddy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40.0,
                    fontFamily: "CircularStd",
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                ),
                AutoSizeText(
                  "Your Personal Finance Manager...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontFamily: "CircularStd",
                    fontWeight: FontWeight.w200,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: 8.0),
              ],
            ),
            Center(child: FlutterLogo(size: 200.0)),
            Text(
              "Version 1.0",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontFamily: "CircularStd",
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
