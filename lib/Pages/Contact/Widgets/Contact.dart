import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_up/Pages/Contact/Widgets/ContactTile.dart';
import 'package:whats_up/Pages/Group/Widget/CreateGroupChat.dart';

class ContactPopup extends StatelessWidget {
  const ContactPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:  [
            InkWell(child: Contacttile(iconContact: Icons.person_add_alt_1_outlined, nameContact: "Thêm bạn"), onTap: () {
              Get.to(CreateGroupChat());
            },),
            SizedBox(height: 10),
            InkWell(child: Contacttile(iconContact: Icons.person_add_alt_1_outlined, nameContact: "Tạo nhóm"), onTap: () {
              Get.to(CreateGroupChat());
            },),
            SizedBox(height: 10),
            Contacttile(iconContact: Icons.video_call_rounded, nameContact: "Tạo cuộc gọi nhóm"),
          ],
        ),
      ),
    );
  }
}

