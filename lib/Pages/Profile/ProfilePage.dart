import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/UserAvarta.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Profile/Widget/UserProfile.dart';

class Profilepage extends StatelessWidget {
  final User userInfo;
  const Profilepage({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    Profilecontroller profilecontroller = Get.put(Profilecontroller());

    return Scaffold(
      appBar: AppBar(title: Text("Profile"),
        actions: [
          if (userInfo.id == profilecontroller.currentUser.value.id)...[
            IconButton(onPressed: () {
            Get.toNamed("/updateProfilePath");
          }, icon: Icon(Icons.edit))
          ]
        ],
      ),
      body: Userprofile(userInfo: userInfo,)
    );
  }
}
