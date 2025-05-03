import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:frontend/components/custom_textform_field.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/editProfileScreen';
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final ProfileController profileController = Get.put(ProfileController());
  String selectedImage = "";

  @override
  void initState() {
    nameController.text = widget.user.userName;
    selectedImage = widget.user.profilePic;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Edit profile"),
        backgroundColor: kBackColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            Map<String, dynamic> data = {
              "profile_pic": selectedImage,
              "user_name": nameController.text.trim(),
            };
            profileController.updateMyProfile(data);
            Navigator.of(context).pop();
          }
        },
        backgroundColor: kBackColor,
        child: const Icon(Icons.save),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            height: 150.0,
            decoration: BoxDecoration(color: kBackColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showBottomSheet(() {
                          setState(() {});
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: badges.Badge(
                          showBadge: true,
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.white,
                          ),
                          badgeContent: const Icon(Icons.edit, size: 14.0),
                          child: Container(
                            height: 75.0,
                            width: 70.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              image: DecorationImage(
                                image: AssetImage(
                                  "assets/images/avatars/$selectedImage",
                                ),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 20.0),
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: "Name",
                    inputType: TextInputType.name,
                    focusedColor: kBackColor,
                    enabledColor: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(Function callback) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder:
              ((context, setState) => SizedBox(
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 12.0),
                    Center(
                      child: Container(
                        width: 45.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        ),
                        const Expanded(
                          flex: 4,
                          child: Text(
                            "Set Profile Picture",
                            style: TextStyle(
                              fontFamily: "CircularStd",
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      height: 90.0,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 12.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImage = "avatar${index + 1}.jpg";
                                });
                              },
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Container(),
                                      badges.Badge(
                                        badgeStyle: badges.BadgeStyle(
                                          badgeColor: Colors.blue.shade900,
                                        ),
                                        badgeContent: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        showBadge:
                                            selectedImage ==
                                                    "avatar${index + 1}.jpg"
                                                ? true
                                                : false,
                                        child: Container(
                                          width: 60.0,
                                          height: 60.0,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                "assets/images/avatars/avatar${index + 1}.jpg",
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                            shape: BoxShape.rectangle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: 6,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Center(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kBackColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          callback();
                        },
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            fontFamily: "CircularStd",
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
