import 'package:flutter/material.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/utils/errFlushbar.dart';
import 'package:get/get.dart';

import '../../controllers/login_controller.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = '/otpScreen';
  const OtpScreen({super.key});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  const OtpInput(this.controller, this.autoFocus, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 50,
      child: TextFormField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: controller,
        maxLength: 1,
        cursorColor: const Color.fromRGBO(0, 10, 56, 1),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          counterText: '',
          hintStyle: TextStyle(color: Colors.black, fontSize: 20.0),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(0, 10, 56, 1),
              width: 2.0,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}

class _OtpScreenState extends State<OtpScreen> {
  int pinSize = 0;
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  final TextEditingController _fieldFive = TextEditingController();
  final TextEditingController _fieldSix = TextEditingController();

  late final LoginController _loginController;
  @override
  void initState() {
    _loginController = Get.put(LoginController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Align(
                child: Container(
                  alignment: Alignment.bottomLeft,
                  height: MediaQuery.of(context).size.height * 0.20,
                  width: double.infinity,
                  color: const Color.fromRGBO(0, 10, 56, 1),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 30.0),
                    child: Text(
                      "Enter OTP",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontFamily: "CircularStd",
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              Text(
                                "Please enter 6-digit OTP sent on +${_loginController.mobileNumberController.text} to continue",
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: "CircularStd",
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              Form(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    OtpInput(_fieldOne, true),
                                    OtpInput(_fieldTwo, false),
                                    OtpInput(_fieldThree, false),
                                    OtpInput(_fieldFour, false),
                                    OtpInput(_fieldFive, false),
                                    OtpInput(_fieldSix, false),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 45.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_fieldOne.text.isEmpty ||
                        _fieldTwo.text.isEmpty ||
                        _fieldThree.text.isEmpty ||
                        _fieldFour.text.isEmpty ||
                        _fieldFive.text.isEmpty ||
                        _fieldSix.text.isEmpty) {
                      showErrFlushBar(
                        context,
                        "Invalid OTP",
                        "Enter 6 digit OTP",
                      );
                    } else {
                      String finalOTP =
                          _fieldOne.text +
                          _fieldTwo.text +
                          _fieldThree.text +
                          _fieldFour.text +
                          _fieldFive.text +
                          _fieldSix.text;

                      showLoader(context);

                      var res = await _loginController.verifyOTP(
                        finalOTP,
                        context,
                      );
                    }

                    // Navigator.of(context).pushNamedAndRemoveUntil(
                    //   CreateProfileScreen.routeName,
                    //   (route) => false,
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 10, 56, 1),
                  ),
                  child: const Text(
                    "VERIFY",
                    style: TextStyle(
                      fontFamily: "CircularStd",
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
