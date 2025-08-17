import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/GroupChatController.dart';
import 'package:whats_up/Model/ChatRoomModel.dart';
import 'package:whats_up/Model/ChatRoomWithCount.dart';
import 'package:whats_up/Model/GroupChatModel.dart';
import 'package:whats_up/Model/GroupChatRoomModel.dart';
import 'package:whats_up/Pages/HomePage/Widget/ChatTile.dart';
import 'package:whats_up/Pages/HomePage/Widget/GroupChatTile.dart';

class Groupchatlist extends StatefulWidget {
  const Groupchatlist({super.key});

  @override
  State<Groupchatlist> createState() => _GroupchatlistState();
}

class _GroupchatlistState extends State<Groupchatlist> {
   final GroupChatController groupChatController = Get.put(GroupChatController());
   
  @override
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<List<GroupChatModel>> (
      stream: groupChatController.getGroupRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return const Center(child: Text("Không nhóm nào"));
          }
          
          return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            //final otherUser = room.receiver!.id != uid ? room.receiver : room.sender;
            return StreamBuilder<int>(
            stream: groupChatController.getCountMgsNotSeenInGroupRoomId(room.id!, uid),
            builder: (context, countSnapshot) {
              final count = countSnapshot.data ?? 0;

              final lastChat = (count > 1  && room.lastMessageSenderId != uid)
                  ? "Bạn có $count tin nhắn mới"
                  : (room.lastMessageSenderId == uid
                      ? (room.draftMessages!.isNotEmpty && room.draftMessages![uid] != ""  ? "Bản nháp: ${room.draftMessages![uid]}" : "Bạn: ${room.lastMessage}")
                      : "${room.lastMessageSenderName} : ${room.lastMessage}");

              if (room.lastMessageSenderId == null ||

                    room.name == null ||
                    room.lastMessageSenderName == null) {
                  return SizedBox.shrink();
                }

                return Groupchattile(
                  groupChatModel: room,
                  lastChat: lastChat,
                  isUnSeen: count,
                );

            },
          );
          },
        );

      },
    );
  
  }
}
