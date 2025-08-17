import 'dart:async';
import 'dart:math';

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Controller/FileController.dart';
import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';
import 'package:whats_up/Pages/Chat/Widgets/DecorationText.dart';
import 'package:whats_up/Pages/Chat/Widgets/ImageView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mime/mime.dart';
import 'package:whats_up/Pages/File/PdfPage.dart';
import 'package:whats_up/Pages/File/WebView.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart' hide PlayerState;
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

class LinkPreview extends StatefulWidget {
  final String url;

  const LinkPreview({super.key, required this.url});

  @override
  State<LinkPreview> createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  @override
Widget build(BuildContext context) {
  return FutureBuilder<Metadata?>(
    future: MetadataFetch.extract(widget.url),
    builder: (context, snapshot) {
      final data = snapshot.data;

      if (snapshot.connectionState != ConnectionState.done || data == null) {
        return const SizedBox(); // loading hoặc không có metadata
      }

      return GestureDetector(
        onTap: () {
          launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication);
        },
        child: Container(
          margin: const EdgeInsets.only(top: 4, right: 6, left: 6),
          padding: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl:  data.image!,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 8),
              if (data.title != null)
                Text(
                  data.title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              if (data.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
}
class Chatmess extends StatelessWidget {
  const Chatmess({
    super.key,
    required this.isComming,
    required this.message,
    this.timestamp,
    this.replyMessage, this.replyMessageId, this.onTapReplyMess,
  });

  final bool isComming;
  final String message;
  final String? replyMessageId;
  final String? replyMessage;
  final String? timestamp;
  final Function(String replyMessageId)? onTapReplyMess;

  bool isLink(String message) {
    final urlPattern = RegExp(
      r'^(https?:\/\/)?' // http hoặc https
      r'([\w-]+\.)+[\w-]+' // domain
      r'([\/\w .-]*)*\/?' // path
      r'(\?[^\s]*)?' // query
      r'(#\w+)?$', // fragment
      caseSensitive: false,
    );
    return urlPattern.hasMatch(message.trim());
  }

  @override
  Widget build(BuildContext context) {
    bool isLinkMessage = isLink(message);

    if (!message.contains('👍')) {
      Widget bubble = GestureDetector(
        onTap: () {
          if (isLinkMessage) {
            launchUrl(Uri.parse(message),
                mode: LaunchMode.externalApplication);
          }
        },
        child: BubbleSpecialThree(
          text: message,
          sent: true,
          isSender: !isComming,
          color: !isComming
              ? const Color(0xFF1B97F3)
              : const Color.fromARGB(255, 65, 36, 71),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
            decoration: isLinkMessage
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: Colors.white,
          ),
          tail: true,
        ),
      );

      // Nếu có replyMessage, tức là tin nhắn này đang reply ai đó
      // -> Dịch bubble lên để nó đè 10px vào bubble phía trước
      if (replyMessage != null) {
        bubble = Transform.translate(
          offset: const Offset(0, -10), // Chồng lên trên 10px
          child: bubble,
        );
      }

      return Align(
        alignment: isComming ? Alignment.centerLeft : Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isComming ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // Nếu có replyMessage, hiển thị nội dung tin nhắn gốc
            if (replyMessage != null)
              GestureDetector(
                onTap: () {
                  onTapReplyMess?.call(replyMessageId!);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: !isComming
                          ? [Color(0xFF1B97F3), Color.fromARGB(255, 76, 76, 76)]
                          : [
                              Color.fromARGB(255, 65, 36, 71),
                              Color.fromARGB(255, 76, 76, 76)
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trả lời tin nhắn",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        replyMessage!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bubble chính (có thể chồng lên bubble cũ 10px)
            bubble,

            if (isLinkMessage) LinkPreview(url: message),
          ],
        ),
      );
    } else {
      // Lottie icon
      String input = message;
      final match = RegExp(r'\d+').firstMatch(input);
      int size = int.tryParse(match?.group(0) ?? '') ?? 0;
      return LottieAnimation(
        size: Size(size.toDouble() + 50, size.toDouble() + 50),
        type: "like",
      );
    }
  }
}


class ChatImg extends StatelessWidget {
  const ChatImg({
    super.key,
    required this.isComming,
    this.message,
    required this.imageUrls, required this.user,
  });
  final User user;
  final bool isComming;
  final String? message;
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty && message == null) return SizedBox.shrink();
    return Align(
      alignment: isComming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        padding: const EdgeInsets.all(3),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isComming
              ? Colors.grey.shade800
              : Color(0xFF1B97F3),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isComming ? 0 : 10),
            bottomRight: Radius.circular(isComming ? 10 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
            spacing: 4,
            runSpacing: 2,
            children:  imageUrls.asMap().entries.map((url) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 200, // Tối đa chiều rộng
                    maxHeight: 200, // Tối đa chiều cao
                  ),
                  child: InkWell(
                    child: CachedNetworkImage(
                      imageUrl: url.value,
                      fit: BoxFit.contain, // Giữ nguyên tỉ lệ ảnh
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image, size: 60),
                    ),
                    onTap: () {
                      Get.to(Imageview(imageUrls: imageUrls, initialIndex: url.key, user: user));
                    },
                  ),
                ),
              );
            }).toList()
          ),
            if (message != null && message!.trim().isNotEmpty ) ...[
              const SizedBox(height: 4),
              
              DecorationText(
                text: message!,
                onTap: () {},
              ) ,
            ] else SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class ChatMapUrl extends StatelessWidget {
  const ChatMapUrl({
    super.key,
    required this.mapUrl,
    required this.isComming,
    this.time,
    required this.sender,
  });

  final String mapUrl;
  final bool isComming;
  final String? time;
  final ChatModel sender;

  int latLonToTileX(double lon, int zoom) {
    return ((lon + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  int latLonToTileY(double lat, int zoom) {
    lat = lat.clamp(-85.0511, 85.0511);
    double latRad = lat * pi / 180.0;
    return ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * (1 << zoom)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(mapUrl);
    final coords = uri.queryParameters['query']?.split(',') ?? ['0', '0'];
    final lat = double.tryParse(coords[0]) ?? 0.0;
    final lng = double.tryParse(coords[1]) ?? 0.0;
    const zoom = 17;

    final tileX = latLonToTileX(lng, zoom);
    final tileY = latLonToTileY(lat, zoom);
    final imageUrl = "https://tile.openstreetmap.org/$zoom/$tileX/$tileY.png";

    return Align(
      alignment: isComming ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        padding: const EdgeInsets.all(6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isComming
              ? Colors.grey.shade800
              : Color(0xFF1B97F3),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isComming ? 0 : 10),
            bottomRight: Radius.circular(isComming ? 10 : 0),
          ),
        ),
        child: InkWell(
          onTap: () => launchUrl(Uri.parse(mapUrl), mode: LaunchMode.externalApplication),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  width: 250,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.map, size: 60),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 80),
                child: Text(
                  isComming
                      ? "Vị trí của ${sender.senderName}"
                      : "Vị trí được chia sẻ",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                ),
              ),
              if (time != null) ...[
                const SizedBox(height: 2),
                Text(
                  time!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class CardMessage extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final bool isComming;

  const CardMessage({
    super.key,
    required this.name,
    required this.avatarUrl,
     this.onCall,
     this.onMessage,
    required this.isComming,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: isComming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: isComming
              ? Colors.grey.shade800
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isComming ? 0 : 12),
            bottomRight: Radius.circular(isComming ? 12 : 0),
          ),
        ),
        child: Column(
          children: [
            // Phần trên: avatar + tên
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Avatarprofile(radius: 20, width: 1, ImgaeUrl: avatarUrl,),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Phần dưới: Gọi điện - Nhắn tin
            Container(
              decoration: BoxDecoration(
                color: isComming ? Colors.grey.shade700 : Colors.white,
                borderRadius: isComming ? BorderRadius.only(bottomRight: Radius.circular(16)):BorderRadius.only(bottomLeft: Radius.circular(16))
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onCall,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Center(
                          child: Text(
                            'Gọi điện',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: isComming
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: isComming ? Colors.white24 : Colors.grey.shade300,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onMessage,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Nhắn tin',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: isComming
                                  ? Colors.white
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ChatFile extends StatelessWidget {
  const ChatFile({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.isComming,
    this.time,
    required this.sender,
  });

  final String fileUrl;
  final String fileName;
  final bool isComming;
  final String? time;
  final ChatModel sender;

  String? getFileMimeType(String path) {
    return lookupMimeType(path);
  }
  
  

  String generatePreviewUrl(String url) {
  final uri = Uri.parse(url);
  final segments = uri.pathSegments.toList();

  final uploadIndex = segments.indexOf('upload');
  if (uploadIndex == -1) return url;

  // ✅ Thêm transformation sau "upload"
  segments.insert(uploadIndex + 1, 'pg_1,e_preview,w_400');

  // ✅ Bắt buộc dùng "image" thay vì "raw" hoặc "auto" ở đầu
  if (segments[0] == 'raw' || segments[0] == 'auto') {
    segments[0] = 'image';
  }

  // ✅ Loại bỏ mọi đuôi mở rộng (vd: .pdf, .docx, .png, ...)
  final lastSegment = segments.last;
  final dotIndex = lastSegment.lastIndexOf('.');
  if (dotIndex != -1) {
    segments[segments.length - 1] = lastSegment.substring(0, dotIndex);
  }

  // ✅ Thêm đuôi .jpg (Cloudinary bắt buộc)
  if (!segments.last.endsWith('.jpg')) {
    segments[segments.length - 1] += '.jpg';
  }

  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    pathSegments: segments,
  ).toString();
}





  @override
  Widget build(BuildContext context) {
    final mimeType = getFileMimeType(fileName);
    final previewUrl = generatePreviewUrl(fileUrl);

    return Align(
      alignment: isComming ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isComming
              ? Colors.grey.shade800
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isComming ? 0 : 10),
            bottomRight: Radius.circular(isComming ? 10 : 0),
          ),
        ),
        child: InkWell(
          onTap: () async {
            debugPrint(previewUrl);
  final mime = getFileMimeType(fileName);
      try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WordViewerScreen(url: fileUrl, name: fileName,),
            ),
          );
      } catch (e) {
           ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: 
        Text('Không thể mở tệp: $e', style: TextStyle(
          fontSize: 15,

        ),),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        dismissDirection: DismissDirection.horizontal,
        elevation: 5,
        actionOverflowThreshold: 3,
        
        ),
        snackBarAnimationStyle: AnimationStyle(curve: 
        Curves.bounceOut
        )
      );
      }
    
//  if (mime != null && (mime.contains('doc') || mime.contains('xlsx') || mime.contains('c') || mime.contains('') )) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WordViewerScreen(url: fileUrl, name: fileName,),
//       ),
//     );
//   } else {
//     try {
//       final uri = Uri.parse(fileUrl);
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Không thể mở tệp: $e')),
//       );
//     }
//   }
},
// onLongPress: () async {
//   final uri = Uri.parse(fileUrl);
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
// },


          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: previewUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Center(child: buildFallbackIcon(mimeType)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Text(
                  isComming
                      ? "Tệp từ ${sender.senderName}"
                      : "Bạn đã gửi tệp",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                ),
              ),
              if (time != null) ...[
                const SizedBox(height: 2),
                Text(
                  time!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Fallback icon nếu preview không load được
  Widget buildFallbackIcon(String? mime) {
    if (mime == null) return const Icon(Icons.insert_drive_file, size: 60, color: Colors.white);

    if (mime.contains('pdf')) {
      return const Icon(Icons.picture_as_pdf, size: 60, color: Colors.redAccent);
    } else if (mime.contains('doc') || mime.contains('officedocument.wordprocessingml')) {
      return const Icon(Icons.description, size: 60, color: Colors.blueAccent);
    } else if (mime.contains('excel') || mime.contains('spreadsheetml')) {
      return const Icon(Icons.table_chart, size: 60, color: Colors.green);
    } else if (mime.contains('zip') || mime.contains('rar')) {
      return const Icon(Icons.archive, size: 60, color: Colors.orange);
    } else {
      return const Icon(Icons.insert_drive_file, size: 60, color: Colors.white);
    }
  }
}


class ChatVoice extends StatefulWidget {
  final String audioUrl;
  final bool isComming;
  final String? time;
  final String fileName; // ví dụ: "voice_20250716.m4a"

  const ChatVoice({
    super.key,
    required this.audioUrl,
    required this.fileName,
    required this.isComming,
    this.time,
  });

  @override
  State<ChatVoice> createState() => _ChatVoiceState();
}

class _ChatVoiceState extends State<ChatVoice> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setUrl(widget.audioUrl).then((_) {
      _duration = _player.duration ?? Duration.zero;
      setState(() {});
    });

    _player.positionStream.listen((pos) {
      setState(() => _position = pos);
    });

    _player.playerStateStream.listen((state) {
      if (state.playing != _isPlaying) {
        setState(() => _isPlaying = state.playing);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    return "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isComming ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: widget.isComming
              ? Colors.grey.shade800
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(widget.isComming ? 0 : 10),
            bottomRight: Radius.circular(widget.isComming ? 10 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _player.pause();
                    } else {
                      _player.play();
                    }
                  },
                ),
                Expanded(
                  child: AudioFileWaveforms(
                    size: Size(double.infinity, 40),
                    playerController: PlayerController(),
                    enableSeekGesture: false,
                    waveformType: WaveformType.fitWidth,
                    waveformData: [], // Optional: có thể load waveform từ bytes nếu có
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: Colors.white,
                      liveWaveColor: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatDuration(_position),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.fileName,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (widget.time != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.time!,
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChatRecord extends StatefulWidget {
  const ChatRecord({
    super.key,
    required this.isComming,
    required this.fileUrl,
  });

  final bool isComming;
  final String fileUrl;

  @override
  State<ChatRecord> createState() => _ChatRecordState();
}

class _ChatRecordState extends State<ChatRecord> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

late final StreamSubscription _durationSub;
late final StreamSubscription _positionSub;
late final StreamSubscription _playerStateSub;

@override
void initState() {
  super.initState();

  _durationSub = audioPlayer.durationStream.listen((d) {
    if (d != null && mounted) {
      setState(() {
        duration = d;
        isLoading = false;
      });
    }
  });

  _positionSub = audioPlayer.positionStream.listen((p) {
    if (mounted) {
      setState(() {
        position = p;
      });
    }
  });

  _playerStateSub = audioPlayer.playerStateStream.listen((state) {
    if (state.processingState == ProcessingState.completed && mounted) {
      setState(() {
        isPlaying = false;
        isPause = false;
        position = Duration.zero;
      });
      audioPlayer.seek(Duration.zero);
    }
  });
}

@override
void dispose() {
  _durationSub.cancel();
  _positionSub.cancel();
  _playerStateSub.cancel();
  audioPlayer.dispose();
  super.dispose();
}

 void _changeSeek(double value) {
  final seekPosition = Duration(seconds: value.toInt());
  audioPlayer.seek(seekPosition);
  if (mounted) {
    setState(() {
      position = seekPosition;
    });
  }
}

Future<void> _playAudio() async {
  final url = widget.fileUrl;

  if (isPause) {
    try {
      await audioPlayer.play();
      if (mounted) {
        setState(() {
          isPlaying = true;
          isPause = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    }
  } else if (isPlaying) {
    await audioPlayer.pause();
    if (mounted) {
      setState(() {
        isPlaying = false;
        isPause = true;
      });
    }
  } else {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await audioPlayer.setUrl(url);
      await audioPlayer.play();

      if (mounted) {
        setState(() {
          isPlaying = true;
          isPause = false;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          isLoading = false;
        });
      }
    }
  }
}




  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isComming
        ? const Color.fromARGB(255, 65, 36, 71)
        : const Color(0xFF1B97F3);

    final iconColor = widget.isComming ? Colors.white : Colors.white;

    return Align(
  alignment: widget.isComming ? Alignment.centerLeft : Alignment.centerRight,
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 280), // 👈 Giới hạn chiều rộng tối đa
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _playAudio,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: iconColor,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                    max: duration.inSeconds.toDouble().clamp(1.0, double.infinity),
                    onChanged: _changeSeek,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}


