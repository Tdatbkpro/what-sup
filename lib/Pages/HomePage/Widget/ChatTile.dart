import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_up/Config/UserAvarta.dart';
import 'package:tuple/tuple.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/ChatPage.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';
import 'package:whats_up/Pages/Profile/ProfilePage.dart';

class Chattile extends StatefulWidget {
  final String imageUrl;
  final String userName;
  final String lastChat;
  final String lastTime;
  final User userInfo;
  final int isUnSeen;
  
  
  const Chattile({
    super.key,
    required this.imageUrl,
    required this.userName,
    required this.lastChat,
    required this.lastTime, required this.userInfo, required this.isUnSeen,
  });

  @override
  State<Chattile> createState() => _ChattileState();
}

class _ChattileState extends State<Chattile> {
      final Authcontroller authcontroller = Authcontroller();
      ChatController chatController = ChatController();
  final RxString lastSeenText = ''.obs;
  Timer? _refreshTimer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatController.markAsReceived(widget.userInfo.id!);
    updateLastSeen();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if(mounted) {
          updateLastSeen();
      }
    });
  }
  void updateLastSeen() {
  final parsedTime = DateTime.tryParse(widget.lastTime);
  lastSeenText.value = authcontroller.getUserStatusText(parsedTime);
}
  @override
  Widget build(BuildContext context) {

    final widthContext = MediaQuery.of(context).size.width - 20;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.all(5),
        width: widthContext,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT: Avatar + Text
              Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        child: Avatarprofile(radius: 20, width: 2,ImgaeUrl: widget.imageUrl,),
                        onTap: () {
                          Get.to(Profilepage(userInfo: widget.userInfo,),);
                        },
                        ),
                      const SizedBox(width: 10),
                      // CHÍNH Ở ĐÂY: Dùng Expanded để ép chiều ngang phần Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.lastChat,
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                fontSize: widget.isUnSeen > 0? 16 :14,
                                fontWeight: widget.isUnSeen > 0 ? FontWeight.w800 : FontWeight.w200,
                                color: widget.isUnSeen > 0 ? Theme.of(context).colorScheme.secondary: Colors.grey

                                
                                ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                 
                ),
              
              // RIGHT: Thời gian
              const SizedBox(width: 10),
              Obx( () =>
                Text(
                  lastSeenText.value == "Đang hoạt động" ? "Vừa xong" : lastSeenText.value,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        onTap: () {
              Get.to(Chatpage(user: widget.userInfo));
            },
        ),
      ),
    );
  }
}
