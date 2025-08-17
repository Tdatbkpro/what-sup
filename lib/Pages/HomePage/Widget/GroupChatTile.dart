import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Model/GroupChatModel.dart';
import 'package:whats_up/Model/GroupChatRoomModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';
import 'package:whats_up/Pages/Group/GroupChatPage.dart';
import 'package:whats_up/Pages/Group/Widget/DefaultAvatarGroup.dart';

class Groupchattile extends StatefulWidget {
  final GroupChatModel groupChatModel;
  final String? lastChat;
  final int isUnSeen;

  const Groupchattile({
    super.key,
   this.lastChat,
    required this.isUnSeen, required this.groupChatModel,

  });

  @override
  State<Groupchattile> createState() => _GroupchattileState();
}

class _GroupchattileState extends State<Groupchattile> {
  final Authcontroller authcontroller = Authcontroller();
  final ChatController chatController = ChatController();
  final RxString lastSeenText = ''.obs;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    updateLastSeen();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) updateLastSeen();
    });
  }

  void updateLastSeen() {
    final parsedTime = DateTime.tryParse(widget.groupChatModel.lastMessageTimestamp!);
    lastSeenText.value = authcontroller.getUserStatusText(parsedTime);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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
          onTap: () {
            //Get.to(Chatpage(group: widget.groupChatInfo));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT: Avatar + Info
              Expanded(
                child: Row(
                  children: [
                    widget.groupChatModel.profileUrl != null  ?
                    Avatarprofile(
                      radius: 20,
                      width: 2,
                      ImgaeUrl: widget.groupChatModel.profileUrl,
                    ) : DefaultGroupAvatar(members: widget.groupChatModel.members!, size: 50,),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => Get.to(Groupchatpage(groupChatModel: widget.groupChatModel)),
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FaIcon(FontAwesomeIcons.userGroup, size: 16,),
                                SizedBox(width: 10,),
                                Text(
                                  widget.groupChatModel.name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 18),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.lastChat == null ? "" : widget.lastChat!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize:
                                        widget.isUnSeen > 0 ? 16 : 14,
                                    fontWeight: widget.isUnSeen > 0
                                        ? FontWeight.w800
                                        : FontWeight.w200,
                                    color: widget.isUnSeen > 0
                                        ? Theme.of(context).colorScheme.secondary
                                        : Colors.grey,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // RIGHT: time
              const SizedBox(width: 10),
              Obx(
                () => Text(
                  lastSeenText.value == "Đang hoạt động"
                      ? "Vừa xong"
                      : lastSeenText.value,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
