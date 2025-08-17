import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:tuple/tuple.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/UserAvarta.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/ChatPage.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';
import 'package:whats_up/Pages/Chat/Widgets/ChatMess.dart';
import 'package:whats_up/Pages/Chat/Widgets/DecorationText.dart';
import 'package:avatar_stack/animated_avatar_stack.dart';

class Groupchatbubble extends StatefulWidget {
  // final String message;
   final bool isComming;
   
   final bool showTimeAndStatus;
  // final String time;
  // final String status;
  // final String? imageUrl;
  //final String? userAvarta;
  final User user;
  final ChatModel chatModel;
  final VoidCallback onTap;
  final List<String> seenBy;
  
  const Groupchatbubble({
    super.key,
    required this.user, required this.chatModel, required this.isComming,this.showTimeAndStatus = true, required this.onTap, required this.seenBy,
  });

  @override
  State<Groupchatbubble> createState() => _GroupchatbubbleState();
}

class _GroupchatbubbleState extends State<Groupchatbubble> {

  void showUserSeenBy(BuildContext context, List<User> users) {
  showMaterialModalBottomSheet(
    context: context,
    animationCurve: Curves.easeInExpo,
    // barrierColor: Colors.blueAccent,
    closeProgressThreshold: 0.5,

    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    bounce: true,
    elevation: 5,

    enableDrag: true,
    //expand: true,

    isDismissible: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) {
      
      return Container(
        height: 300,
        child: Column(
          children: [
            SizedBox(height: 20,),
            Divider(
              indent: MediaQuery.of(context).size.width/2.5,
              endIndent: MediaQuery.of(context).size.width/2.5,
              height: 4,
              radius: BorderRadius.circular(20),
              color: Colors.blue,
              thickness: 5,
            ),
            Expanded(
              child: ListView(
                controller: ScrollController(),
                children: users.map((value) {
                  return ListTile(
                    autofocus: true,
                    focusColor: Colors.blueAccent,
                    leading: Avatarprofile(
                      radius: 20,
                      width: 0,
                      ImgaeUrl: value.profileImage,
                    ),
                    title: Text(value.name!, style: TextStyle(color: Colors.white, fontSize: 18),),
                    trailing: Icon(Icons.remove_red_eye_outlined)
                  );
                }).toList(), // <-- quan trọng
              ),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: widget.isComming ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        widget.isComming ? 
        Row(
          children: [
            // UserAvatar(imageUrl: NetworkImage(user.profileImage!), backGroundAvar: Tuple2(24, 24)),
            if(widget.showTimeAndStatus)...
            [
              Avatarprofile(radius: 18, width: 0, ImgaeUrl: widget.user.profileImage,),
            SizedBox(width: 3,),
            ]
            else ...[
              SizedBox(width: 42,),
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
                     _buildStatusRow(formatHourMinute(widget.chatModel.timestamp!), context)
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
Future<(List<ImageProvider>, List<User>)> _loadAvatars(List<String> userIds) async {
  final controller = Get.find<Profilecontroller>();
  final images = <ImageProvider>[];
  final users = <User>[];

  for (final id in userIds) {
    try {
      final user = await controller.getUserById(id);
      users.add(user);
      if (user.profileImage != null && user.profileImage!.isNotEmpty) {
        images.add(CachedNetworkImageProvider(user.profileImage!));
      } else {
        images.add(const AssetImage("assets/images/man.png"));
      }
    } catch (e) {
      print("⚠️ Lỗi khi load avatar userId=$id: $e");
      images.add(const AssetImage("assets/images/man.png"));
    }
  }

  return (images, users); // sử dụng Dart 3 Tuple
}


  Widget _buildStatusRow(String time, BuildContext context) {
  if (!widget.showTimeAndStatus) return const SizedBox.shrink();

  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      FutureBuilder<(List<ImageProvider>, List<User>)>(
              future: _loadAvatars(widget.seenBy),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LottieAnimation(size: const Size(20, 20), type: "circle_loading");
                }

                if (!snapshot.hasData || snapshot.data!.$1.isEmpty) {
                  return const SizedBox.shrink();
                }

                final images = snapshot.data!.$1;
                final users = snapshot.data!.$2;

                return GestureDetector(
                  onTap: () {
                    showUserSeenBy(context, users); // 🟢 truyền được users ở đây
                  },
                  child: AnimatedAvatarStack(
                    height: 20,
                    width: 60.0,
                    borderColor: Colors.transparent,
                    avatars: images,
                  ),
                );
              },
            ),

      const SizedBox(width: 6),
      Text(
        time,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14),
      ),
    ],
  );
}


}

  Widget buildChatContentIsComming(ChatModel chatModel, bool isComming, User user) {
        final Profilecontroller profilecontroller = Get.put(Profilecontroller());

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
  if (chatModel.message != null && chatModel.message!.trim().isNotEmpty) {
    return Chatmess(
      isComming: isComming,
      message: chatModel.message!,
    );
  }
  if (chatModel.document != null) {
    final doc = chatModel.document;
    return ChatFile(fileUrl: doc!.fileUrl, fileName: doc.fileName, isComming: isComming, sender: chatModel);
  }

  if (chatModel.audioUrl != null) {
    return ChatRecord(fileUrl: chatModel.audioUrl!, isComming: isComming);
  }

  return const SizedBox.shrink();
}


Widget buildChatWidgetNotIsComming(ChatModel chatModel, bool isComming, User user) {
  final Profilecontroller profilecontroller = Get.put(Profilecontroller());

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
  } else if (chatModel.message != null && chatModel.message!.trim().isNotEmpty) {
    return Chatmess(
      isComming: isComming,
      message: chatModel.message!,
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
  } else 
  if (chatModel.audioUrl != null) {
    return ChatRecord(fileUrl: chatModel.audioUrl!, isComming: isComming);
  }
   else {
    return const SizedBox.shrink();
  }
}
