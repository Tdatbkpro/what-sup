import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Model/ChatRoomModel.dart';
import 'package:whats_up/Model/ChatRoomWithCount.dart';
import 'package:whats_up/Pages/HomePage/Widget/ChatTile.dart';

class Chatlist extends StatefulWidget {
  const Chatlist({super.key});

  @override
  State<Chatlist> createState() => _ChatlistState();
}

class _ChatlistState extends State<Chatlist> {
   final ChatController chatController = ChatController();
   
  @override
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<List<ChatRoomModel>> (
      stream: chatController.getRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return const Center(child: Text("Không có cuộc trò chuyện nào."));
          }
          
          return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            final otherUser = room.receiver!.id != uid ? room.receiver : room.sender;
            return StreamBuilder<int>(
            stream: chatController.getCountMgsNotSeenInRoomId(room.id!, otherUser!.id!),
            builder: (context, countSnapshot) {
              final count = countSnapshot.data ?? 0;

              final lastChat = (count > 1 && room.sender!.id != uid)
                  ? "Bạn có $count tin nhắn mới"
                  :   room.draftMessages!.isNotEmpty && room.draftMessages![uid] != ""  ?  "Bản nháp: ${room.draftMessages![uid]}" : ( room.sender!.id == uid
                       ? "Bạn: ${room.lastMessage}"
                      : room.lastMessage! );

              return Chattile(
                imageUrl: otherUser.profileImage!,
                userName: otherUser.name!,
                lastChat: lastChat,
                lastTime: room.lastMessageTimestamp!,
                userInfo: otherUser,
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
