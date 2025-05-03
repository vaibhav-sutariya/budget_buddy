import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screens/profile/edit_profile_screen.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = '/profileScreen';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController profileController = Get.put(ProfileController());
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    check();
  }

  check() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      switchVal = prefs.getBool("isReminderAllowed") ?? true;
    });
  }

  late bool switchVal = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Profile"),
        backgroundColor: kBackColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            height: 150.0,
            decoration: BoxDecoration(color: kBackColor),
            child: Obx(
              () => Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      height: 75.0,
                      width: 70.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/avatars/${profileController.user.value.profilePic}",
                          ),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.white, width: 3.0),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            profileController.user.value.userName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            "+91 ${profileController.user.value.userMobile}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          EditProfileScreen.routeName,
                          arguments: profileController.user.value,
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_active, color: kBackColor),
                  title: const Text(
                    "Smart reminder",
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: const Text("Fire notification at 20:00"),
                  trailing: Switch(
                    onChanged: (val) async {
                      setState(() {
                        val == true
                            ? NotificationService()
                                .scheduleDailyEightPMNotification()
                            : NotificationService().cancelNotification();
                        switchVal = val;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool("isReminderAllowed", val);
                    },
                    value: switchVal,
                    activeColor: kBackColor,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  myCustomTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: kBackColor),
      title: Text(title, style: const TextStyle(color: Colors.black)),
    );
  }
}
