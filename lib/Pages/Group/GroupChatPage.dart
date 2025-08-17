import 'dart:async';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuple/tuple.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/UserAvarta.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Controller/CallController.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/ContactController.dart';
import 'package:whats_up/Controller/FileController.dart';
import 'package:whats_up/Controller/GroupChatController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/ChatRoomModel.dart';
import 'package:whats_up/Model/ContactModel.dart';
import 'package:whats_up/Model/GroupChatModel.dart';
import 'package:whats_up/Model/GroupChatRoomModel.dart';
import 'package:whats_up/Model/GroupMessageModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Call/AudioCall.dart';
import 'package:whats_up/Pages/Call/VideoCall.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';
import 'package:whats_up/Pages/Chat/Widgets/ChatBottomBarPage.dart';
import 'package:whats_up/Pages/Chat/Widgets/ChatBubble.dart';
import 'package:whats_up/Pages/Chat/Widgets/ReactionEmojiBuilder.dart';
import 'package:whats_up/Pages/Chat/Widgets/ShareCardPage.dart';
import 'package:whats_up/Pages/Profile/ProfilePage.dart';
import 'package:whats_up/Controller/GoogleMapController.dart';
import 'package:whats_up/Pages/Profile/Widget/UserProfile.dart';
import 'package:whats_up/Pages/Group/Widget/DefaultAvatarGroup.dart';
import 'package:whats_up/Pages/Group/Widget/GroupChatBubble.dart';

class Groupchatpage extends StatefulWidget {
  //final User user;
 // final String groupId;
  final GroupChatModel groupChatModel;
  //final ChatModel chatModel;
  //const Groupchatpage({super.key, required this.user})  : super(key: key);
  const Groupchatpage({super.key, required this.groupChatModel, }); // ✅ thêm key
  @override
  State<Groupchatpage> createState() => _GroupchatpageState();
}

class _GroupchatpageState extends State<Groupchatpage> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ChatController chatController = Get.put(ChatController());
  final GroupChatController GroupchatController = Get.put(GroupChatController());
  final FileController fileController = Get.put(FileController());
  final Profilecontroller profilecontroller = Get.put(Profilecontroller());
  final GoogleMapController googleMapController = GoogleMapController();
  final CallController callController = Get.put(CallController());
  final ScrollController _scrollController = ScrollController();
  ContactController contactController = Get.put(ContactController());

  final auth = FirebaseAuth.instance.currentUser;
  
  final Authcontroller authcontroller = Authcontroller();
  final RxList<XFile> _selectedImages = <XFile>[].obs;
  final RxBool _hasDataImg = false.obs;
  late String mapUrl ="";
  Future<GroupChatRoomModel?> _futureGroupChatRoomModel = Future.value();
  late String fileRecord = "";

  Timer? _refreshTimer;
  RxString lastOnlineText = ''.obs;
  //User? _userInfo;
  late BuildContext _rootContext;
  final Map<String, LayerLink> _messageLinks = {}; 
  @override
  void initState() {
      super.initState();
    _scrollToBottom(100);
    //_userInfo = widget.user;
    _fetchUserInfo(); // Tải lần đầu
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchUserInfo(); // Cập nhật mỗi 30 giây
    });
    GroupchatController.maskSeen(widget.groupChatModel.id!);
    _futureGroupChatRoomModel = GroupchatController.getGroupRoomByID(widget.groupChatModel.id!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _rootContext = context;

  });
    }


  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageLinks.clear();
    super.dispose();
  }

 Future<void> _fetchUserInfo() async {
  int onlineCount = 0;

  for (var entry in widget.groupChatModel.memberRoles!.entries) {
    final userInfo = await profilecontroller.getUserById(entry.key);
    print("${userInfo.name} + ${userInfo.lastOnlineStatus}");

    final status = authcontroller.getUserStatusText(userInfo.lastOnlineStatus);
    if (status == "Đang hoạt động") {
      onlineCount++;
    }
  }

  lastOnlineText.value = "$onlineCount đang hoạt động";
}



  void _handleSendMessage() async {
  final message = _messageController.text.trim();

  if (message.isNotEmpty) {
    await GroupchatController.sendMessageToGroup(groupChat: widget.groupChatModel, message: message, userSender: profilecontroller.currentUser.value);
    _messageController.clear();
    _selectedImages.clear(); // ✅ Xoá sau khi upload xong
    _hasDataImg.value = false;
    _scrollToBottom(10);
  } else if (_selectedImages.isNotEmpty) {
  // Chờ upload hết ảnh
  final imageUrlConverted = await Future.wait(
    _selectedImages.map((value) async {
      return await fileController.uploadFileToSupabase(File(value.path));
    }),
  );

  await GroupchatController.sendMessageToGroup(
    groupChat: widget.groupChatModel,
    message: message,
    userSender: profilecontroller.currentUser.value,
    imageUrls: imageUrlConverted.whereType<String>().toList(),
    type: "image", // hoặc "text", "mixed", tùy cách bạn xử lý
  );
}

  
   else if (fileRecord != "") {
    GroupchatController.sendMessageToGroup(groupChat: widget.groupChatModel, message: message, userSender: profilecontroller.currentUser.value, audioUrl: await fileController.uploadToCloudinaryUrl(fileRecord));
          
        }
}

  void _scrollToBottom(double offset) {
  Future.delayed(const Duration(milliseconds: 300), () {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}

  void _handleIconAction(String action) async {
    switch (action) {
      case 'camera':
        final picker = ImagePicker();
        _selectedImages.removeRange(0, _selectedImages.length);
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null)
      {
        _selectedImages.add(image);
      }
       _hasDataImg.value = _selectedImages.isNotEmpty;
        break;
      case 'gallery':
        final picker = ImagePicker();
       // _selectedImages.removeRange(0, _selectedImages.length);
      final List<XFile>? images = await picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        _selectedImages.addAll(images);
         _hasDataImg.value = _selectedImages.isNotEmpty;
      }
        break;
      case 'mic':
        print('Record voice');
        break;
      case 'emoji':
        print('Show emoji picker');
        break;
      case 'location':
        try {
        mapUrl = await googleMapController.getCurrentLocationLink();
        GroupchatController.sendMessageToGroup(groupChat: widget.groupChatModel, userSender: profilecontroller.currentUser.value);
         Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 200,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      
          //_messageController.text = mapUrl;
          //widget.onSend(); // gửi như tin nhắn
        } catch (e) {
          print(e);
          Get.snackbar("Lỗi", e.toString());
        }
      case 'contact':
        //Get.to(ShareCardChat(sharedUser: _userInfo!,),curve: Curves.easeInBack);
      case 'file':
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: LottieAnimation(size: Size(100,100), type: "wave_loading")),
      );

      final file = File(result.files.first.path!);
      final fileName = result.files.first.name;
      final fileExt = result.files.first.extension;
      final fileSize = result.files.first.size;

      // 👇 Gọi upload có thể mất vài giây
      final secureUrl = await fileController.uploadFileToSupabase(file);

      final fileInfor = FileInfo(
        fileName: fileName,
        fileSize: fileSize,
        fileUrl: secureUrl!,
      );
      GroupchatController.sendMessageToGroup(groupChat: widget.groupChatModel, message: "", userSender: profilecontroller.currentUser.value, document: fileInfor);

      
    } catch (e) {
      print('❌ Lỗi upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload thất bại: $e')),
      );
    } finally {
      // 👇 Dù thành công hay lỗi cũng tắt loading
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
  break;

      case 'record':
        
        
      default:
        await GroupchatController.sendMessageToGroup(groupChat: widget.groupChatModel, userSender: profilecontroller.currentUser.value,message: action);
    }
  }
  final Set<String> _tappedMessages = {};
  
  OverlayEntry? _chatBubbleOverlay;

  _chatBubbleMenu(BuildContext context, String messageId) {
    if(_chatBubbleOverlay != null) {
      _chatBubbleOverlay?.remove();
      _chatBubbleOverlay = null;
      return;
    }
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final link = _messageLinks[messageId];
  if (link == null) return;
    _chatBubbleOverlay = OverlayEntry(builder: (context) => 
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _chatBubbleOverlay?.remove();
          _chatBubbleOverlay = null;
        },
        child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.black.withOpacity(0.3))),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.7,
                child: CompositedTransformFollower(link: link,
                showWhenUnlinked: false,
                targetAnchor: Alignment.topCenter,
                followerAnchor: Alignment.topCenter,
                offset: const Offset(0, 15),
                child: Transform.translate(
                  offset: Offset(
                    MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width * 0.7 / 2, // Đẩy overlay ra giữa màn hình
                    0,),
                                child: Material(
                    animationDuration: Duration(milliseconds: 300),
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: ConstrainedBox(
                      
                      constraints: BoxConstraints(
                      
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      child: IntrinsicHeight(
                      
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                  _buildReactionEmoji("❤️", messageId),
                                  _buildReactionEmoji("😂",messageId),
                                  _buildReactionEmoji("😮",messageId),
                                  _buildReactionEmoji("😢",messageId),
                                  _buildReactionEmoji("😡",messageId),
                                  _buildReactionEmoji("👍",messageId),
                                  _buildAddEmojiIcon(context,messageId)
                            ],
                        ),
                      ),
                      ),
                  ),
                ),
          
                ),
              )
            ],
        ),
      )
    );
    Navigator.of(_rootContext).overlay!.insert(_chatBubbleOverlay!);

  }

  Widget _buildReactionEmoji(String emoji, String messageId) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10),
    child: GestureDetector(
      onTap: () async {
       await GroupchatController.updateMessage("reactions", emoji,widget.groupChatModel.id!, messageId, "add");
        _chatBubbleOverlay?.remove();
        _chatBubbleOverlay = null;
        // TODO: handle emoji reaction
      },
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    ),
  );
}

Widget _buildAddEmojiIcon(BuildContext context, String messageId) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: GestureDetector(
      onTap: () async {
        _chatBubbleOverlay?.remove();
        _chatBubbleOverlay = null;

        // Hiện Emoji Picker bằng modal_bottom_sheet
        showMaterialModalBottomSheet(
          context: context,
          animationCurve: Curves.fastLinearToSlowEaseIn,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          bounce: true,
          elevation: 6,
          closeProgressThreshold: 0.5,
          isDismissible: true,
          
          enableDrag: true,
          shape: RoundedRectangleBorder(),

          builder: (context) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: EmojiPicker(

            scrollController: ScrollController(
              keepScrollOffset: true,

              )
              ,
            onEmojiSelected: (category, emoji) async {
              await GroupchatController.updateMessage("reactions", emoji.emoji,widget.groupChatModel.id!, messageId, "add");
              Navigator.of(context).pop();
              // TODO: handle emoji picked from modal
            },
            onBackspacePressed: () {
              Navigator.pop(context);
            },
            config: Config(
            emojiViewConfig: EmojiViewConfig(
              emojiSizeMax: 32,
              loadingIndicator: LottieAnimation(size: Size(100,100), type: "wave_loading"),
              columns: 7,
            ),
            bottomActionBarConfig: BottomActionBarConfig(
              enabled: true,
              showBackspaceButton: true,
              
            ),
            categoryViewConfig: CategoryViewConfig(

            ),
            skinToneConfig: SkinToneConfig(
              enabled: true,
              indicatorColor: Colors.blueAccent
            ),
            searchViewConfig: SearchViewConfig(

              hintText: "Tìm kiếm emoji",
              inputTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
              hintTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey
              ),
            ),
            ),

          ),
            );
          }
        );
      },
      child: const Icon(Icons.add, size: 24),
    ),
  );
}
  Widget _buildMessageBubble(ChatModel currentMessage, String messageId, LayerLink layerLink, RxBool showMeta, List<String> seenBy) {
  return CompositedTransformTarget(
    link: layerLink,
    child: GestureDetector(
      onTap: () => GroupchatController.toggleMessage(currentMessage.id!),
      onLongPress: () => _chatBubbleMenu(context, messageId),
      child: Groupchatbubble(
        user: widget.groupChatModel.members!.firstWhere(
            (value) => value.id == currentMessage.senderId
          ),
        chatModel: currentMessage, 
        showTimeAndStatus: showMeta.value,
        isComming: currentMessage.senderId != profilecontroller.currentUser.value.id, 
        seenBy: seenBy,
        onTap: () => GroupchatController.toggleMessage(messageId),
        ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () => Get.toNamed("/homePath")),
        titleSpacing: 0,
        title: Row(
          children: [
            InkWell(
              //onTap: () => Get.to(Profilepage(userInfo: widget.user)),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: widget.groupChatModel.profileUrl != null ? Avatarprofile(
                  radius: 18,
                  width: 2,
                  ImgaeUrl: widget.groupChatModel.profileUrl,
                ) : DefaultGroupAvatar(members: widget.groupChatModel.members!,)
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.groupChatModel.name ?? "",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.online_prediction_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Obx(() => Text(
                          lastOnlineText.value,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, size: 24),
            color: Colors.greenAccent,
            tooltip: 'Gọi thoại',
            onPressed: () async {
              // final receiver = widget.user;
              // final caller = profilecontroller.currentUser.value;

              // if (caller.id != receiver.id) {
              //   final callId = await callController.callAction(receiver, caller, "audio");
              //   Get.to(AudioCallPage(callId: callId));
              // } else {
              //   Get.snackbar("Lỗi", "Không thể gọi cho chính mình");
              // }
            },
          ),
          IconButton(
            icon: const Icon(Icons.video_call_sharp, size: 24),
            color: Colors.redAccent,
            tooltip: 'Gọi video',
            onPressed: () async {
              // final receiver = widget.user;
              // final caller = profilecontroller.currentUser.value;

              // if (caller.id != receiver.id) {
              //   final callId = await callController.callAction(receiver, caller, "video");
              //   Get.to(VideoCallPage(callId: callId));
              // } else {
              //   Get.snackbar("Lỗi", "Không thể gọi cho chính mình");
              // }
            },
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info, size: 24),
          ),
          const SizedBox(width: 3),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 19, 19, 19),
                padding: const EdgeInsets.all(10),
                child: StreamBuilder<List<GroupMessageModel>>(
                stream: GroupchatController.getGroupMessages(widget.groupChatModel.id!),
                builder: (context, snapshot)  {
                    if (snapshot.hasData) {
                  final messages = snapshot.data!;
                  if (messages.isNotEmpty)  {
                    //chatController.markAsSeen(_userInfo!.id!);
                  }
                  return ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final currentMessage = messages[index];
                              final previousMessage = index > 0 ? messages[index - 1] : null;

                              final groupTitle = chatController.getFormattedDateGroup(
                                currentMessage.timestamp,
                                previousMessage?.timestamp,
                              );

                              return 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (groupTitle.isNotEmpty) ...[
                                    Padding(
                                      padding:const EdgeInsets.symmetric(vertical: 4),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[800],
                                                borderRadius: BorderRadius.circular(13),
                                              ),
                                              child: Text(
                                                groupTitle,
                                                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                                  fontSize: 14
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10,)
                                          ],
                                        ),
                                      ), 
                                  )
                                  ],
                                  Obx(() {
                                        RxBool showMeta = GroupchatController.isTapped(currentMessage.id!).obs;

                                        if (!showMeta.value && index < messages.length - 1 ) {
                                          final nextMessage = messages[index + 1];

                                            final currentTime = DateTime.tryParse(currentMessage.timestamp ?? '');
                                          final nextTime = DateTime.tryParse(nextMessage.timestamp ?? '');
                                          final sameSender = currentMessage.senderId == nextMessage.senderId;

                                          if (currentTime != null && nextTime != null) {
                                            final diff = nextTime.difference(currentTime).inMinutes;
                                            showMeta.value = !(diff <= 5 && sameSender);
                                          }
                          
                                        } else {
                                          showMeta.value = true;
                                        }

                                        final messageId = currentMessage.id!;
                                        final layerLink = _messageLinks.putIfAbsent(messageId, () => LayerLink());
                                       final  currentMessageConvertToCharModel = currentMessage.convertGroupMessageToChatModel(currentMessage);
                                        return Stack(
                                          children: [
                                            _buildMessageBubble(currentMessageConvertToCharModel, messageId, layerLink, showMeta, currentMessage.seenBy!),
                                            Positioned(
                                                bottom: 35,
                                                right: currentMessageConvertToCharModel.senderId == widget.groupChatModel.members!.firstWhere(
                                                                                        (value) => value.id == auth!.uid
                                                                                      ).id!
                                                    ? 0
                                                    : null,
                                                left: currentMessageConvertToCharModel.senderId != widget.groupChatModel.members!.firstWhere(
                                                                              (value) => value.id == auth!.uid
                                                                            ).id!  ? 45 : null,
                                                child: ReactionEmojiBuilder(
                                                  messageId: currentMessage.id!,
                                                  roomId: widget.groupChatModel.id!,
                                                ),
                                              )

                                          ],
                                        );
                                      }),

                                ],
                              );
                            },
                          );

                } else if (snapshot.hasError) {
                  return Text("Lỗi: ${snapshot.error}");
                } 
                return const Center(
                    child:  LottieAnimation(size: Size(100,100), type: "wave_loading"),
                );
                }),
              ),
            ),
            FutureBuilder<GroupChatRoomModel?>(
            future: _futureGroupChatRoomModel,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LottieAnimation(size: Size(100,100), type: "wave_loading"),
                );
              }

              return 
                 Chatbottombarpage(
                  controller: _messageController,
                  //chatRoomModel: snapshot.data,
                  groupChatRoomModel: snapshot.data,
                  onSend: _handleSendMessage,
                  hasDataImage: _hasDataImg,
                  onIconTap: _handleIconAction,
                  recordFile: (fileStringRecord) {
                    fileRecord = fileStringRecord;
                  },
                );
            },
          ),

            Obx(() {
            if (_selectedImages.isNotEmpty) {
              return Container(
                height: 300,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_selectedImages[index].path),
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _selectedImages.removeAt(index);
                              _hasDataImg.value = _selectedImages.isNotEmpty;
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0, 
                            child:  CircleAvatar(
                              radius: 13,
                              backgroundColor: Colors.black54,
                              child: Text(
                                '${index+1}',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255), 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900
                                  ),
                              ),

                            ),
                          
                        ),
                      ],
                    );
                  },
                ),
              );
            } else {
              return const SizedBox(); // không hiện gì nếu không có ảnh
            }
        })

          ],
        ),
      ),
    );
  }

}
