import 'dart:async';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tuple/tuple.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/UserAvarta.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Controller/CallController.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/ContactController.dart';
import 'package:whats_up/Controller/FileController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/ChatRoomModel.dart';
import 'package:whats_up/Model/ContactModel.dart';
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

class Chatpage extends StatefulWidget {
  final User user;
  //final ChatModel chatModel;
  //const Chatpage({super.key, required this.user})  : super(key: key);
  const Chatpage({super.key, required this.user}); // ✅ thêm key
  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ChatController chatController = Get.put(ChatController());
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
  Future<ChatRoomModel?> _futureChatRoomModel = Future.value();
  late String fileRecord = "";


  final ItemScrollController _itemScrollController = ItemScrollController();
final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
final Map<String, int> _messageIndexMap = {}; // Map messageId -> index
int messagesLenght = 0;
final RxSet<String> _highlightedMessages = <String>{}.obs;


RxMap<String, String> maskMessDelete = <String, String>{}.obs;

RxBool onTapDelete = false.obs;



  Timer? _refreshTimer;
  RxString lastOnlineText = ''.obs;
  User? _userInfo;
  late BuildContext _rootContext;
  final Map<String, LayerLink> _messageLinks = {}; 
  @override
  void initState() {
      super.initState();
    
    _userInfo = widget.user;
    _fetchUserInfo(); // Tải lần đầu
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchUserInfo(); // Cập nhật mỗi 30 giây
    });
    _futureChatRoomModel = chatController.getRoomByUserId(widget.user.id!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _rootContext = context;
    _scrollToBottom(100);

  });
    }


  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageLinks.clear();
    chatController.clearReply();
    super.dispose();
  }

  Future<void> _fetchUserInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.user.id)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        
          _userInfo = _userInfo?.copyWith(
            lastOnlineStatus: data["lastOnlineStatus"] != null
                ? DateTime.tryParse(data["lastOnlineStatus"].toString())
                : null,
          );
          lastOnlineText.value = authcontroller.getUserStatusText(_userInfo?.lastOnlineStatus);
      }
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
  void _handleSendMessage() async {
  final message = _messageController.text.trim();

  if (message.isNotEmpty) {
    await chatController.send(_userInfo!.id!, message, _selectedImages, _userInfo!, null, null,null,null);
    _messageController.clear();
    _selectedImages.clear(); // ✅ Xoá sau khi upload xong
    _hasDataImg.value = false;
    _scrollToBottom(10);
    chatController.clearReply();
  } else if (_selectedImages.isNotEmpty) {
    await chatController.send(_userInfo!.id!, "${_selectedImages.length} hình ảnh", _selectedImages, _userInfo!, null, null,null,null);
    _messageController.clear();
    _selectedImages.clear(); // ✅ Xoá sau khi upload xong
    _hasDataImg.value = false;
    _scrollToBottom(200);
    chatController.clearReply();
  } else if (fileRecord != "") {
          chatController.send(
        widget.user.id!,
        "File ghi âm của ${profilecontroller.currentUser.value.name}",
        null,
        widget.user,
        null,
        null,
        null,
         await fileController.uploadToCloudinaryUrl(fileRecord)
      );
       _scrollToBottom(10);
       chatController.clearReply();
        }

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
        chatController.send(_userInfo!.id!, "Vị trí của của ${profilecontroller.currentUser.value.name}",null, _userInfo!, mapUrl, null,null,null);
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
        Get.to(ShareCardChat(sharedUser: _userInfo!,),curve: Curves.easeInBack);
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
      final secureUrl = await fileController.uploadFileToCloudinarySigned(file);

      final fileInfor = FileInfo(
        fileName: fileName,
        fileSize: fileSize,
        fileUrl: secureUrl!,
      );

      chatController.send(
        widget.user.id!,
        "File đính kèm của ${profilecontroller.currentUser.value.name}",
        null,
        widget.user,
        null,
        null,
        fileInfor,
        null
      );
      _scrollToBottom(10);
    } catch (e) {
      print('❌ Lỗi upload: $e');
      if (!mounted) return;
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
      break;
      case 'forward':
      break;
        
      default:
        await chatController.send(widget.user.id!, action, null, widget.user, null, null, null, null);
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
                targetAnchor: Alignment.topCenter ,
                followerAnchor: Alignment.topCenter,
                offset: const Offset(0, -50),
                child: Transform.translate(
                  offset: Offset(
                    MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width * 0.8 / 2, // Đẩy overlay ra giữa màn hình
                    0,
                  ),
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
              ),

              
            ],
        ),
      )
    );
    Navigator.of(_rootContext).overlay!.insert(_chatBubbleOverlay!);

  }
  // Trong nơi bạn muốn hiện menu hành động (action)
void _showActionBottomSheet(BuildContext context, ChatModel currentMessage) {
  showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(Icons.reply_rounded, "Trả lời", () {
            chatController.setReplyMessage(
              ReplyMessage(content:  currentMessage.message!,imageUrl:  currentMessage.imageUrls!.isNotEmpty ? currentMessage.imageUrls![0] : null, targetUser: 
            currentMessage.senderId == auth!.uid ? profilecontroller.currentUser.value : widget.user,
            id:currentMessage.id!
            )
            );
            Navigator.pop(context);
            // Xử lý reply
          }),
            _buildActionItem(Icons.copy, "Sao chép", () {
               Clipboard.setData(ClipboardData(text: currentMessage.message!, ));

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã sao chép'),
                  duration: Duration(seconds: 1),
                ),
              );
              // Xử lý sao chép
            }),
          _buildActionItem(Icons.delete, "Xóa", () {
            onTapDelete.value = true;
            maskMessDelete.putIfAbsent(currentMessage.id!, () => currentMessage.senderId!);

            Navigator.pop(context);
            // Xử lý xóa
          }),
          _buildActionItem(Icons.menu, "Xem thêm", () {
            Navigator.pop(context);
            // Xử lý xem thêm
          }),
        ],
      ),
    ),
  );
}

void _showActionDeleteBottom(BuildContext context){
  showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    expand: false,
    closeProgressThreshold: 0.4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    builder: (context) {
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  indent: MediaQuery.of(context).size.width * 0.4,
                  endIndent: MediaQuery.of(context).size.width * 0.4,
                  height: 5,
                  color: Colors.blueGrey,
                  thickness: 4,
                ),
                const SizedBox(height: 8),
                Text(
                  "Xóa ${maskMessDelete.length} tin nhắn?",
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                if (maskMessDelete.values.firstWhere(
                      (value) => value != profilecontroller.currentUser.value.id!,
                      orElse: () => "",
                    ) == "")
                  InkWell(
                    onTap: () async {
                      await chatController.deleteMessages(
                        roomId: chatController.getRoomId(widget.user.id!),
                         messageIds: maskMessDelete.entries.map((entry) {
                            return entry.key;
                         }).toList(),
                         isRecall: true
                         );
                    },
                    child: ListTile(
                      leading: const Icon(Icons.undo, color: Colors.red),
                      title: const Text("Thu hồi (Xóa cả 2 phía)",
                          style: TextStyle(fontSize: 16, color: Colors.red)),
                    ),
                  ),
                InkWell(
                  onTap: () async {
                      await chatController.deleteMessages(
                        roomId: chatController.getRoomId(widget.user.id!),
                         messageIds: maskMessDelete.entries.map((entry) {
                            return entry.key;
                         }).toList(),
                         
                         );
                    },
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline_outlined, color: Colors.red),
                    title: const Text("Xóa ở phía bạn",
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 15),),
      ],
    ),
  );
}

  Widget _buildReactionEmoji(String emoji, String messageId) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10),
    child: GestureDetector(
      onTap: () async {
        await chatController.updateMessage("reactions", emoji, chatController.getRoomId(widget.user.id!), messageId, "add");
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
              await chatController.updateMessage("reactions", emoji.emoji, chatController.getRoomId(widget.user.id!), messageId, "add");
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
void _scrollToMessageById(String messageId) {
  final index = _messageIndexMap[messageId];
  if (index != null && _itemScrollController.isAttached) {
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.2,
    );

    _highlightedMessages.add(messageId);

    // Xóa hiệu ứng scale sau 1 giây
    Future.delayed(const Duration(milliseconds: 1000), () {
      _highlightedMessages.remove(messageId);
    });
  } else {
    print("[ScrollToMessage] Không tìm thấy index cho messageId: $messageId");
  }
}





 Widget _buildMessageBubble(ChatModel currentMessage, String messageId, LayerLink layerLink, RxBool showMeta) {
  return Obx(() {
    final isHighlighted = _highlightedMessages.contains(messageId);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: isHighlighted ? 1.08 : 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: CompositedTransformTarget(
        link: layerLink,
        child: GestureDetector(
          onTap: () => chatController.toggleMessage(currentMessage.id!),
          onLongPress: () {
            _chatBubbleMenu(context, messageId);
            _showActionBottomSheet(context, currentMessage);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                if (!onTapDelete.value) return SizedBox.shrink();

                final isSelected = maskMessDelete.containsKey(currentMessage.id!);
                return IconButton(
                  icon: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    if (isSelected) {
                      maskMessDelete.remove(currentMessage.id);
                    } else {
                      maskMessDelete.putIfAbsent(currentMessage.id!, () => currentMessage.senderId!);
                    }
                    // Kích hoạt cập nhật giá trị
                    maskMessDelete.refresh();
                  },
                );
              }),

              Expanded(
                child: Chatbubble(
                  user: _userInfo!,
                  chatModel: currentMessage,
                  isComming: currentMessage.receiverId != _userInfo!.id!,
                  showTimeAndStatus: showMeta.value,
                  onTapDelete: onTapDelete,
                  onTap: () {},
                  onTapReplyMess: (p0) {
                    _scrollToMessageById(p0);
                  },
                ),
              ),
            ],
          ),


        ),
      ),
    );
  });
}




  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !onTapDelete.value,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && onTapDelete.value) {
          onTapDelete.value = false;
          maskMessDelete.clear();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: BackButton(onPressed: () => Get.toNamed("/homePath")),
          titleSpacing: 0,
          title: Row(
            children: [
              InkWell(
                onTap: () => Get.to(Profilepage(userInfo: widget.user)),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Avatarprofile(
                    radius: 18,
                    width: 2,
                    ImgaeUrl: _userInfo!.profileImage,
                  ),
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
                        widget.user.name ?? "",
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
                final receiver = widget.user;
                final caller = profilecontroller.currentUser.value;
      
                if (caller.id != receiver.id) {
                  final callId = await callController.callAction(receiver, caller, "audio");
                  Get.to(AudioCallPage(callId: callId));
                } else {
                  Get.snackbar("Lỗi", "Không thể gọi cho chính mình");
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.video_call_sharp, size: 24),
              color: Colors.redAccent,
              tooltip: 'Gọi video',
              onPressed: () async {
                final receiver = widget.user;
                final caller = profilecontroller.currentUser.value;
      
                if (caller.id != receiver.id) {
                    final callId = await callController.callAction(receiver, caller, "video");
                  Get.to(VideoCallPage(callId: callId));
                } else {
                  Get.snackbar("Lỗi", "Không thể gọi cho chính mình");
                }
              },
            ),
            IconButton(
              onPressed: () => Get.to(Userprofile(userInfo: widget.user)),
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
                  child: StreamBuilder<List<ChatModel>>(
                  stream: chatController.getMessages(_userInfo!.id!),
                  builder: (context, snapshot)  {
                      if (snapshot.hasData) {
                    final messages = snapshot.data!;
                    if (messages.isNotEmpty)  {
                      chatController.markAsSeen(_userInfo!.id!);
                       if (messagesLenght != messages.length) {
                        messagesLenght = messages.length;
                           WidgetsBinding.instance.addPostFrameCallback((_) {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (_itemScrollController.isAttached) {
                                _itemScrollController.scrollTo(
                                  index: messages.length - 1,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                          });
                       }
                    }
                    return ScrollablePositionedList.builder(
                              itemScrollController: _itemScrollController,
                              itemPositionsListener: _itemPositionsListener,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final currentMessage = messages[index];
                                _messageIndexMap[currentMessage.id!] = index;
                                final previousMessage = index > 0 ? messages[index - 1] : null;
      
                                final groupTitle = chatController.getFormattedDateGroup(
                                  currentMessage.timestamp,
                                  previousMessage?.timestamp,
                                );
      
                                return 
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (groupTitle.isNotEmpty && !currentMessage.deletedFor!.contains(profilecontroller.currentUser.value.id!) ) ...[
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
                                          RxBool showMeta = chatController.isTapped(currentMessage.id!).obs;
      
                                          if (!showMeta.value && index < messages.length - 1) {
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
      
                                          return 
                                          currentMessage.deletedFor == null || !currentMessage.deletedFor!.contains(profilecontroller.currentUser.value.id!)
                                          ? Stack(
                                            children: [
                                              _buildMessageBubble(currentMessage, messageId, layerLink, showMeta),
                                              Positioned(
                                                  bottom: 35,
                                                  right: currentMessage.receiverId == _userInfo!.id!
                                                      ? 0
                                                      : null,
                                                  left: currentMessage.receiverId != _userInfo!.id!  ? 45 : null,
                                                  child: ReactionEmojiBuilder(
                                                    messageId: currentMessage.id!,
                                                    roomId: chatController.getRoomId(widget.user.id!),
      
                                                  ),
                                                )
      
                                            ],
                                          ): SizedBox.shrink();
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
              Obx( () => 
                onTapDelete.value == false ?
              FutureBuilder<ChatRoomModel?>(
              future: _futureChatRoomModel,
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
                    chatRoomModel: snapshot.data,
                    onSend: _handleSendMessage,
                    hasDataImage: _hasDataImg,
                    onIconTap: _handleIconAction,
                    recordFile: (fileStringRecord) {
                      fileRecord = fileStringRecord;
                    },
                  );
              },
            ) : 
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primaryContainer
              ),
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width*0.8
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _showActionDeleteBottom(context);
                      },
                      child: Center(
                        child: Text("Xóa (${maskMessDelete.value.length} tin nhắn)", style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.normal
                        ),),
                      ),
                    ),
                  ),
                  VerticalDivider (
                    width: 20,
                    thickness: 2,
                    color: Colors.blueGrey,
                  ),
                  InkWell(
                    onTap: () {
                      onTapDelete.value = false;
                      maskMessDelete.clear();
                    },
                    child: Text("Hủy", style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.normal
                        ),),
                  )

                ],
              ),
            ) 
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
      ),
    );
  }

}
