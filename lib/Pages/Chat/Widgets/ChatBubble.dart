

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_up/Controller/CallController.dart';
import 'package:whats_up/Controller/ChatController.dart';

import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Call/AudioCall.dart';
import 'package:whats_up/Pages/Chat/ChatPage.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';
import 'package:whats_up/Pages/Chat/Widgets/ChatMess.dart';
import 'package:whats_up/Pages/Chat/Widgets/DecorationText.dart';

class Chatbubble extends StatefulWidget {
  // final String message;
   final bool isComming;
   
   final bool showTimeAndStatus;
  // final String time;
  // final String status;
  // final String? imageUrl;
  //final String? userAvarta;
  final User user;
  final RxBool? onTapDelete;
  final ChatModel chatModel;
  final VoidCallback onTap;
  final Function(String)? onTapReplyMess;
  
  const Chatbubble({
    super.key,
    required this.user, required this.chatModel, required this.isComming,this.showTimeAndStatus = true, required this.onTap, this.onTapReplyMess, this.onTapDelete,
  });

  @override
  State<Chatbubble> createState() => _ChatbubbleState();
}

class _ChatbubbleState extends State<Chatbubble> {

 

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: widget.isComming ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        widget.isComming ? 
        Row(
          children: [
            // UserAvatar(imageUrl: NetworkImage(user.profileImage!), backGroundAvar: Tuple2(24, 24)),
            if (widget.onTapDelete == null || widget.onTapDelete!.value == false)
                if (widget.showTimeAndStatus) ...[
                  Avatarprofile(radius: 18, width: 0, ImgaeUrl: widget.user.profileImage),
                  SizedBox(width: 3),
                ]
                else ...[
                  SizedBox(width: 42),
                ],
            buildChatWidgetNotIsComming(widget.chatModel, widget.isComming, widget.user)
          ],
        )
        :buildChatContentIsComming(widget.chatModel,widget.isComming,widget.user) ,
        
        Row(
          mainAxisAlignment: widget.isComming ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
                 if (widget.isComming) ...[
                    if(widget.showTimeAndStatus)...[
                      SizedBox(width: 40),
                      DecorationText(text: formatHourMinute(widget.chatModel.timestamp!), onTap: widget.onTap,)
                    ]
                 ]
                 else ...[
                    _buildStatusRow(formatHourMinute(widget.chatModel.timestamp!), widget.chatModel.readStatus == null ? "sent" : widget.chatModel.readStatus!, context)
                 ]
          ],
        ),
        if (widget.showTimeAndStatus) ...[
          SizedBox(height: 20,)
        ]
      ],
    );
  }

  String formatHourMinute(String timestamp) {
  final dateTime = DateTime.parse(timestamp); // parse String sang DateTime
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final merdieum = int.parse(hour) < 12 ? "AM" : "PM"; 
  return '$hour:$minute $merdieum';
}

  Widget _buildStatusRow(String time, String status, BuildContext context) {
  if (!widget.showTimeAndStatus) {
    return const SizedBox.shrink(); // ❗ return widget rỗng nếu không cần hiển thị
  }

  switch (status) {
    case 'sending':
      return Row(
        children: [
          //DecorationText(text: time,onTap: onTap,),
          Text(time, style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.wifi_off, size: 15, color: Colors.grey,),
          const SizedBox(width: 4, ),
        ],
      );
    case 'sent':
      return Row(
        children: [
          Text(time, style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.check_circle_outline_outlined, size: 15, color: Colors.grey,),
          const SizedBox(width: 4, ),
        ],
      );
    case 'received':
      return Row(
        children: [
          Text(time, style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.check_circle_rounded, size: 15, color: Colors.grey,),
          const SizedBox(width: 4, ),
        ],
      );
    case 'seen':
      return Row(
        children: [
          Text(time, style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.remove_red_eye_rounded, size: 15, color: Colors.grey,),
          const SizedBox(width: 4, ),
        ],
      );
    default:
      return Text(time, style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14));
  }
}

  Widget buildChatContentIsComming(ChatModel chatModel, bool isComming, User user) {
        final Profilecontroller profilecontroller = Get.put(Profilecontroller());
            CallController callController = Get.find();
  // Trường hợp có ảnh
  if (chatModel.imageUrls != null && chatModel.imageUrls!.isNotEmpty) {
    return ChatImg(
      isComming: isComming,
      message: chatModel.message,
      imageUrls: chatModel.imageUrls!,
      user: user,
    );
  }

  // Trường hợp chia sẻ người dùng (businessId)
  if (chatModel.businessId != null) {
    return FutureBuilder<User>(
      future: profilecontroller.getUserById(chatModel.businessId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            width: 200,
            child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Lỗi tải người dùng');
        }

        final userShared = snapshot.data!;
        return  CardMessage(
          avatarUrl: userShared.profileImage!,
          isComming: isComming,
          name: userShared.name!,
          onCall: () async {
            final callId = await  callController.callAction(userShared, profilecontroller.currentUser.value, "audio");
            Get.to(AudioCallPage
            (callId: callId,));
          },
          onMessage: () {
          print("→ Nhấn vào user: ${userShared.name}");
          Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              print("→ Chuyển bằng Navigator tới Chatpage(${userShared.id})");
              return Chatpage(key: UniqueKey(), user: userShared);
            }
          )
        );

        }


        );

      },
    );
  }

  // Trường hợp có map
  if (chatModel.mapUrl != null) {
    return ChatMapUrl(
      mapUrl: chatModel.mapUrl!,
      isComming: isComming,
      sender: chatModel,
    );
  }

  // Trường hợp có message
  
  if (chatModel.document != null) {
    final doc = chatModel.document;
    return ChatFile(fileUrl: doc!.fileUrl, fileName: doc.fileName, isComming: isComming, sender: chatModel);
  }

  if (chatModel.audioUrl != null) {
    return ChatRecord(fileUrl: chatModel.audioUrl!, isComming: isComming);
  }
  if (chatModel.message != null && chatModel.message!.trim().isNotEmpty) {
    return Chatmess(
      isComming: isComming,
      message: chatModel.message!,
      replyMessage: chatModel.replies?.content,
      replyMessageId: chatModel.replies?.id,
      onTapReplyMess: (p0) {
        widget.onTapReplyMess?.call(p0);
      },
    );
  }
  return const SizedBox.shrink();
}
}

Widget buildChatWidgetNotIsComming(ChatModel chatModel, bool isComming, User user) {
  final Profilecontroller profilecontroller = Get.put(Profilecontroller());
   CallController callController = Get.find();
  if (chatModel.mapUrl != null) {
    return ChatMapUrl(
      mapUrl: chatModel.mapUrl!,
      isComming: isComming,
      sender: chatModel,
    );
  } else if (chatModel.imageUrls != null && chatModel.imageUrls!.isNotEmpty) {
    return ChatImg(
      isComming: isComming,
      message: chatModel.message,
      imageUrls: chatModel.imageUrls!,
      user: user,
    );
  }  
  else if (chatModel.businessId != null) {
    return FutureBuilder<User>(
      future: profilecontroller.getUserById(chatModel.businessId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            width: 200,
            child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Lỗi tải người dùng');
        }

        final userShared = snapshot.data!;
        return  CardMessage(
          avatarUrl: userShared.profileImage!,
          isComming: isComming,
          name: userShared.name!,
          onCall: () async {
          
            final callId = await  callController.callAction(userShared, profilecontroller.currentUser.value, "audio");
            Get.to(AudioCallPage
            (callId: callId,));
          },
          onMessage: () {
          print("→ Nhấn vào user: ${userShared.name}");
          Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              print("→ Chuyển bằng Navigator tới Chatpage(${userShared.id})");
              return Chatpage(key: UniqueKey(), user: userShared);
            }
          )
        );

        }


        );

      },
    );
  }else if (chatModel.document != null) {
    final doc = chatModel.document;
    return ChatFile(fileUrl: doc!.fileUrl, fileName: doc.fileName, isComming: isComming, sender: chatModel);
  } else  if (chatModel.audioUrl != null) {
    return ChatRecord(fileUrl: chatModel.audioUrl!, isComming: isComming);
  } else if (chatModel.message != null && chatModel.message!.trim().isNotEmpty) {
    return Chatmess(
      isComming: isComming,
      message: chatModel.message!,
      replyMessage: chatModel.replies?.content,
      replyMessageId: chatModel.replies?.id,
    );
  } else{
    return const SizedBox.shrink();
  }
}
