import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/GroupChatController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';

class ReactionEmojiBuilder extends StatefulWidget {
  final String messageId;
  final String roomId;

  const ReactionEmojiBuilder({
    super.key,
    required this.messageId,
    required this.roomId,

  });

  @override
  State<ReactionEmojiBuilder> createState() => _ReactionEmojiBuilderState();
}

class _ReactionEmojiBuilderState extends State<ReactionEmojiBuilder>
    with TickerProviderStateMixin {
  TabController? tabController;

  Future<List<User>> getUsersByEmoji(String emoji, Map<String, String> emojiDetail) async {
  Profilecontroller profilecontroller = Get.find();
  List<User> users = [];

  for (var entry in emojiDetail.entries) {
    if (entry.value == emoji) {
      final user = await profilecontroller.getUserById(entry.key);
      users.add(user);
    }
  }
  return users;
}


  /// Widget hiển thị danh sách user đã react
 Widget listDetailEmojiView(
    String emoji, List<User> listUserEmoji, VoidCallback refreshModal) {
  ChatController chatController = Get.find();
  GroupChatController groupChatController = Get.find();
  return ListView.separated(
    itemCount: listUserEmoji.length,
    itemBuilder: (context, index) {
      final user = listUserEmoji[index];
      final isCurrentUser =
          user.id == FirebaseAuth.instance.currentUser!.uid;
      return ListTile(
        leading: Avatarprofile(
            radius: 18, width: 0, ImgaeUrl: user.profileImage),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name ?? '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
            ),
            if (isCurrentUser)
              InkWell(
                onTap: () async {
                  await chatController.updateMessage(
                    "reactions",
                    "",
                    widget.roomId,
                    widget.messageId,
                    "remove",
                  );
                  await groupChatController.updateMessage("reactions", "",widget.roomId,widget.messageId, "remove");
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: const Text(
                  "Nhấn để gỡ",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
        dense: true,
        trailing: Text(emoji, style: const TextStyle(fontSize: 28)),
      );
    },
    separatorBuilder: (context, index) => const Divider(
      height: 1,
      thickness: 0.5,
      indent: 15,
      endIndent: 15,
    ),
  );
}


  /// Bottom sheet hiện chi tiết react
  void showDetailReacts(BuildContext context, Map<String, int> emojiCount,
    Map<String, String> emojiDetail) {
  tabController?.dispose();
  tabController = TabController(length: emojiCount.length, vsync: this);

  showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    elevation: 6,
    isDismissible: true,
    enableDrag: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(10),
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Cảm xúc",
                          style:
                              TextStyle(fontSize: 20, color: Colors.white)),
                      InkWell(
                        child: const FaIcon(FontAwesomeIcons.deleteLeft,
                            size: 18),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: tabController,
                  tabs: emojiCount.entries.map((entry) {
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.key,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 4),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: emojiCount.entries.map((entry) {
                      return FutureBuilder<List<User>>(
                        future: getUsersByEmoji(entry.key, emojiDetail),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }
                          return listDetailEmojiView(
                            entry.key,
                            snapshot.data!,
                            () {
                              setModalState(() {});
                            },
                          );
                        },
                      );
                    }).toList(),
                  )

                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  @override
Widget build(BuildContext context) {
  GroupChatController groupChatController = Get.put(GroupChatController());
  ChatController chatController = Get.put(ChatController());

        return FutureBuilder<bool>(
          future: groupChatController.hasGroupId(widget.roomId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          debugPrint("❌ Error checking group: ${snapshot.error}");
          return const SizedBox.shrink(); // hoặc báo lỗi
        }

        final exists = snapshot.data!;
        debugPrint("✅ Group exists: $exists groupId là ${widget.roomId}");
      final stream = exists
          ? groupChatController.getReactionsMessageStream(widget.messageId, widget.roomId)
          : chatController.getReactionsMessageStream(widget.messageId, widget.roomId);

      return StreamBuilder<Map<String, String>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final reactions = snapshot.data!;
          final emojiCount = <String, int>{};

          for (var emoji in reactions.values) {
            emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
          }

          final listReact = reactions.values.toSet().toList();

          return GestureDetector(
            onTap: () => showDetailReacts(context, emojiCount, reactions),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  ...listReact.map((emoji) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 15),
                        ),
                      )),
                  const SizedBox(width: 4),
                  Text(
                    reactions.length.toString(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}
