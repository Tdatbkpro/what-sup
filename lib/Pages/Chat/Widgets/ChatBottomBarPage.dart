import 'dart:async';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Model/ChatRoomModel.dart';
import 'package:whats_up/Model/GroupChatRoomModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/Voice/RecordButton.dart';
import 'package:whats_up/Pages/Chat/Voice/AudioService.dart';
class ReplyMessage {
  final User targetUser;
  final String id;
  final String content;
  final String? imageUrl;

  ReplyMessage({
    required this.content,
    required this.id,
    required this.targetUser,
    this.imageUrl,
  });
}

class Chatbottombarpage extends StatefulWidget {
  final TextEditingController controller;
  final ChatRoomModel? chatRoomModel;
  final GroupChatRoomModel? groupChatRoomModel;
  final VoidCallback onSend;
  final RxBool hasDataImage;
  final Function(String action)? onIconTap;
  final Function(String recordFile)? recordFile;

  


  

  const Chatbottombarpage({
    super.key,
    required this.controller,
    required this.onSend,
    this.onIconTap, this.chatRoomModel, required this.hasDataImage, this.recordFile, this.groupChatRoomModel
  });

  @override
  State<Chatbottombarpage> createState() => _ChatbottombarpageState();
}

class _ChatbottombarpageState extends State<Chatbottombarpage> with SingleTickerProviderStateMixin{

  late FocusNode _focusNode;
  RxBool isRecording = false.obs;
  ChatController chatController = Get.put(ChatController());

  final RxBool _isEmojiVisible = false.obs;
  final RxBool _isFocused = false.obs;
  final RxBool _showIcons = true.obs;
  final RxBool _hasText = false.obs;
  late AnimationController controller;
  RxBool _isDeleteRecord = false.obs;
  late Rx<ReplyMessage?> localReplyMessage;
  final RxString _textBuffer = ''.obs;
  RxBool  recordSended = false.obs;

   late String recordFile;

  final audioService = AudioService();
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  final RxInt likeStrength = 1.obs;
    Timer? _holdTimer;

  @override
  void initState() {
    
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _focusNode = FocusNode();
    // ignore: unrelated_type_equality_checks
    if ( widget.chatRoomModel ==null) {
      _hasText.value = false;
    }
    else {
      if (widget.chatRoomModel!.draftMessages!.isNotEmpty) {
        widget.chatRoomModel!.draftMessages!.forEach((key, value) {
          if (key == FirebaseAuth.instance.currentUser!.uid && value != "") {
            _hasText.value == true;
          }
        });
      }
    }
    
    _focusNode.addListener(_handleFocusChanged);
  }


  final LayerLink _addIconLink = LayerLink();
  OverlayEntry? _addMenuOverlay;

_toggleAddMenu() {
  if (_addMenuOverlay != null) {
    _addMenuOverlay?.remove();
    _addMenuOverlay = null;
    return;
  }

  _addMenuOverlay = OverlayEntry(
    builder: (context) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _addMenuOverlay?.remove();
        _addMenuOverlay = null;
      },
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.3))), // cần có Stack mới được dùng Positioned

          Positioned(
            width: MediaQuery.of(context).size.width * 0.4,
            child: CompositedTransformFollower(
              link: _addIconLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.topRight,
              offset: const Offset(-5, -150),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    //maxHeight: 200,
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _addMenuItem('location', Icons.location_on, Colors.redAccent, 'Vị trí'),
                        _addMenuItem('file', Icons.attach_file, Colors.blue, 'Tệp đính kèm'),
                        _addMenuItem('contact', Icons.badge, Colors.green, 'Danh thiếp'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Overlay.of(context).insert(_addMenuOverlay!);
}



  void _handleTextChanged() {
    _hasText.value = widget.controller.text.trim().isNotEmpty;

    // Nếu có chữ → ẩn nhóm icon
    if (_hasText.value) {
      _showIcons.value = false;
    } else {
      // Nếu không có chữ và mất focus → hiện nhóm icon
      if (!_isFocused.value) {
        _showIcons.value = true;
      }
    }
  }

  void _handleFocusChanged() {
    _isFocused.value = _focusNode.hasFocus;

    if (!_isFocused.value && !_hasText.value) {
      _showIcons.value = true;
    }
  }

  void _onForwardTap() {
    _showIcons.value = true;
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {
      _textBuffer.value = widget.controller.text;
    });
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    audioService.dispose();
    controller.dispose();
    waveformData.clear();
    if (audioService.isPlaying) {
       audioService.stop();
    _durationSub?.cancel();
  _positionSub?.cancel();

    
     // hoặc pause()
  }
  super.dispose();
  }
  double normalizeAmp(double amp) {
  return ((amp + 60) / 60).clamp(0.0, 1.0); // 0..1
}
List<double> waveformData = [];
Duration timeRecord = Duration.zero;
Duration currentTime = Duration.zero;
late int index  = 0;
String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

Widget buildWaveform({
  required List<double> waveformData,
  required double height,
  required double width,
  required int currentIndex, // <- THÊM DÒNG NÀY
}) {
  final barWidth = 2.0;
  final spacing = 1.5;

  final maxBarCount = (width / (barWidth + spacing)).floor();

  // Lấy các bar tính từ currentIndex - maxBarCount đến currentIndex
  final startIndex = (currentIndex - maxBarCount + 1).clamp(0, waveformData.length);
  final endIndex = (currentIndex + 1).clamp(0, waveformData.length);

  final visibleData = waveformData.sublist(startIndex, endIndex);

  return SizedBox(
    width: width,
    height: height,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(visibleData.length, (index) {
        final normalized = normalizeAmp(visibleData[index]);
        final barHeight = normalized * height;

        return Padding(
          padding: EdgeInsets.only(right: spacing),
          child: Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    ),
  );
}
Widget buildPlayPauseButton() {
  final icon = audioService.isPlaying
      ? FontAwesomeIcons.circlePause
      : FontAwesomeIcons.circlePlay;

  final iconColor = audioService.isPlaying ? Colors.redAccent : Colors.greenAccent;

  final iconWidget = FaIcon(icon, size: 18, color: iconColor);
  final timeWidget = Text(formatDuration(currentTime), style: TextStyle(fontSize: 12, color: audioService.isPlaying ? Colors.redAccent : Colors.greenAccent));

  return InkWell(
    onTap: () {
      audioService.togglePlayPause();

      _positionSub=  audioService.positionStream.listen((position) {
        if (position != null && timeRecord.inMilliseconds > 0) {
          setState(() {
            currentTime = position;
            index = ((currentTime.inMilliseconds / timeRecord.inMilliseconds) * waveformData.length).floor();
          });
        }
      });
    },
    child: Obx(() => 
     _showIcons.value
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              timeWidget,
            ],
          )
        : Column(
          children: [
            Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                
                children: [
                  iconWidget,
                  SizedBox(width: 6),
                  timeWidget
                ],
              ),
              SizedBox(height: 8,)
          ],
        ),)
  );
}

  void _startIncreasingLikeStrength() {
  likeStrength.value = 1;
  _holdTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
    if (likeStrength.value < 30) {
      likeStrength.value++;
    } else {
      // widget.onIconTap?.call("👍${likeStrength.value}");
      likeStrength.value = 1;
      _holdTimer?.cancel();
    }
  });
}

void _stopIncreasingAndSend() {
  _holdTimer?.cancel();
   widget.onIconTap?.call("👍${likeStrength.value}");
  likeStrength.value = 1;
 
}



  @override
  Widget build(BuildContext context) {
    
    
    widget.controller.text = widget.chatRoomModel?.draftMessages?[FirebaseAuth.instance.currentUser!.uid] ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        Obx(() => 
      chatController.isReplying.value && chatController.replyMessage.value != null
      ? Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                     "Trả lời tin nhắn của ${chatController.replyMessage.value!.targetUser.name}" ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      chatController.replyMessage.value!.content ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      

                    ),
                  ],
                ),
              ),
              if (chatController.replyMessage.value!.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CachedNetworkImage(
                    imageUrl: chatController.replyMessage.value!.imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              IconButton(
                icon: Icon(Icons.close_sharp, color: Colors.white),
                onPressed: () {
                 chatController.clearReply();
                },
              ),
            ],
          ),
        )
      : SizedBox.shrink(),
),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: Column(
                        children: [
                          (_hasText.value == false || _showIcons.value)
                              ? Row(
                                  key: const ValueKey('icons'),
                                  children: [
                                    const SizedBox(width: 3),
                                    _iconButton(Icons.add_circle, 'add'),
                                    const SizedBox(width: 3),
                                    _iconButton(Icons.camera_alt, 'camera'),
                                    const SizedBox(width: 3),
                                    _iconButton(Icons.image_outlined, 'gallery'),
                                    const SizedBox(width: 3),
                                    // _iconButton(Icons.mic, 'mic'),
                                    InkWell(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      _isEmojiVisible.value = !_isEmojiVisible.value;
                                    },
                                    child: Column(
                                      children: [
                                        Obx(() => Icon(
                                              _isEmojiVisible.value
                                                  ? Icons.emoji_emotions_outlined
                                                  : Icons.emoji_emotions,
                                              color: Theme.of(context).colorScheme.primary,
                                            )),
                                        
                                      ],
                                    ),
                                  ),
                                   
                                    
                                    const SizedBox(width: 3),
                                  ],
                                )
                              : InkWell(
                                  key: const ValueKey('forward'),
                                  onTap: _onForwardTap,
                                  child: Row(
                                    children: [
                                      _iconButton(Icons.arrow_forward_ios_rounded, 'forward'),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    )),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 2),
                      if(waveformData.isEmpty) 
                      Expanded(
                          child: TextField(
                            focusNode: _focusNode,
                            controller: widget.controller,
                            style: Theme.of(context).textTheme.labelSmall,
                            maxLines: 5,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            onChanged: (value) {
                              _hasText.value = value.trim().isNotEmpty;
                              _showIcons.value = !(_hasText.value);
                              chatController.saveDraft(widget.chatRoomModel?.id, value.trim());
                            },
                            onSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                              _isFocused.value = false;
                              _showIcons.value = true;
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 3, bottom: 5, top: 5),
                              isDense: true,
                              hintText: 'Nhắn tin',
                              hintStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 16),
                              border: InputBorder.none,
                              fillColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                      )
                      else  ...[
    
                          buildPlayPauseButton(),
                          SizedBox(width: 8,),
                          Obx(() => isRecording.value == false
                            ? InkWell(
                                onTap: () {
                                  
                                  isRecording.value = true;
                                },
                                child: Column(
                                  children: [
                                    FaIcon(FontAwesomeIcons.trash, size: 18, color: Colors.orangeAccent),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              )
                            : Column(
                              children: [
                                LottieAnimation(
                                    size: Size(42, 42),
                                    type: "Delete_message",
                                    onCompleted: () {
                                      isRecording.value = false; // ✅ Set lại sau khi chạy xong animation
                                      waveformData.clear();
                                      _hasText.value = false;
                                      audioService.stop();
                                      setState(() {
                                        
                                      });
                                    },
                                  ),
                                  //SizedBox(height: 6,)
                              ],
                            )),

                          
                          Expanded(
                            child: Column(
                              children: [
                                buildWaveform(waveformData: waveformData, height: 30, width: _showIcons.value == false ? 150 : 100,currentIndex: index),
                                SizedBox(height: 8,)
                              ],
                            )               
                            ),

                      ],
                      Column(
                        children: [
                          Recordbutton(controller: controller,
                          onRecordingChanged: (bool value) {
                          setState(() {
                            isRecording.value = value;
                          });
                        },
                       waveformData: (List<double> data) {
                          setState(() {                          
                            waveformData = data;
                            _hasText.value = true;
                            _showIcons.value = false;
                          });
                        },
                        dataRecord: (file) async {
                        recordFile = file;
                        widget.recordFile?.call(file); 
                        await audioService.init(file);
                        print(file);
                        _durationSub = audioService.durationStream.listen((duration) {
                          if (duration != null) {
                            setState(() {
                              timeRecord = duration;
                              print("Tổng thời lượng ghi âm: $timeRecord");
                            });
                          }
                        });
                        //widget.onIconTap?.call("record");
                        },
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const SizedBox(height: 3),
                  Obx(() => GestureDetector(
                        onTap: () async {
                      if (_hasText.value || widget.hasDataImage.value) {
                        try {
                          widget.onSend();
                          waveformData.clear();
                          await audioService.stop();
                          audioService.dispose();
                        } catch (e) {
                          debugPrint("Send Error: $e");
                        }
                      } else if (waveformData.isNotEmpty) {
                        widget.onIconTap?.call("👍${likeStrength.value}");
                        // Không gọi onSend — chỉ play/pause hoặc bỏ qua
                        debugPrint("Chưa gửi âm thanh — đang xử lý ghi âm");
                      } else {
                        debugPrint("Không có gì để gửi");
                      }
                    },
                      onLongPressStart: (_) => _startIncreasingLikeStrength(),
                      onLongPressEnd: (_) => _stopIncreasingAndSend(),

                        child: Icon(
                          _hasText.value  || widget.hasDataImage.value ? Icons.send : Icons.thumb_up_alt_sharp,
                          size: 24 + likeStrength.value.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )),
                  const SizedBox(height: 6),
                
                ],
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
        Obx(() => Offstage(
          offstage: !_isEmojiVisible.value,
          child:  SizedBox(
                height: 300,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    widget.controller.text += emoji.emoji;
                    _hasText.value = true;
                    widget.controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: widget.controller.text.length),
                    );
                    
                  },
                  onBackspacePressed: () {
                      _isEmojiVisible.value = false;
                    },
                  config: const Config(
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax: 32,
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
              ),
        )),
      ],
    );
  }

  Widget _iconButton(IconData icon, String action) {
    if (action == 'add') {
        return CompositedTransformTarget(
        link: _addIconLink,
        child: GestureDetector(
          onTap: () => _toggleAddMenu(),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
      );
    }
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => widget.onIconTap?.call(action),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
    );
}

  Widget _addMenuItem(String value, IconData icon, Color color, String text) {
  return InkWell(
    onTap: () {
      widget.onIconTap?.call(value);
      _toggleAddMenu(); // Đóng menu
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    ),
  );
}


}
