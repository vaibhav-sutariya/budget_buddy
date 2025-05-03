import 'package:flutter/material.dart';
import 'package:frontend/controllers/group_controller.dart';
import 'package:frontend/screens/groups/create_group_screen.dart';
import 'package:frontend/screens/groups/group_detail_screen.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../utils/custom_loader.dart';

class GroupsScreen extends StatefulWidget {
  static const String routeName = '/groupsScreen';
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  final GroupController _groupController = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var contacts = _profileController.contacts;
          Navigator.of(
            context,
          ).pushNamed(CreateGroupScreen.routeName, arguments: contacts);
        },
        backgroundColor: kBackColor,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("My Groups", style: TextStyle(color: Colors.white)),
        backgroundColor: kBackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Obx(
        () =>
            _groupController.loading.value
                ? showCustomLoader(kBackColor)
                : _groupController.groups.isEmpty
                ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No groups found",
                          style: TextStyle(
                            color: kErrorColor,
                            fontFamily: "CircularStd",
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const Text(
                        "Tap + to add one",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "CircularStd",
                        ),
                      ),
                    ],
                  ),
                )
                : RawScrollbar(
                  thumbColor: Colors.grey,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      Group g = _groupController.groups[index];
                      String membersName = "";
                      for (int i = 0; i < g.members.length; i++) {
                        User? u = g.members[i];
                        if (u.userID == _profileController.user.value.userID) {
                          i == g.members.length - 1
                              ? membersName = "${membersName}You"
                              : membersName = "${membersName}You,";
                        } else {
                          i == g.members.length - 1
                              ? membersName = membersName + u.userName
                              : membersName = "$membersName${u.userName},";
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          12.0,
                          6.0,
                          12.0,
                          6.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              GroupDetailScreen.routeName,
                              arguments: g,
                            );
                          },
                          child: Container(
                            height: 90.0,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CircleAvatar(
                                    backgroundImage: AssetImage(
                                      "assets/images/groups/${g.groupImgSrc}",
                                    ),
                                    radius: 50.0,
                                  ),
                                ),
                                const SizedBox(width: 18.0),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g.groupName,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 5.0,
                                        ),
                                        child: Text(
                                          membersName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _groupController.groups.length,
                  ),
                ),
      ),
    );
  }
}
