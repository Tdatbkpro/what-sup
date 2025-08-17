import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/GroupChatRoomModel.dart';
import 'package:whats_up/Model/GroupMessageModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Model/GroupChatModel.dart';
import 'package:http/http.dart' as http;

class GroupChatController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<GroupChatModel> groupChats = <GroupChatModel>[].obs;

  Stream<List<GroupChatModel>> getUserGroupsStream() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('groupChats')
        .where('memberRoles.$uid', isGreaterThan: '') // kiểm tra có vai trò
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupChatModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> createGroup({
      required String name,
    String? description,
    String? profileUrl,
    String? groupCoverUrl,
    String groupType = "private",
    List<User>? members,
  }) async {
    Profilecontroller profilecontroller = Get.find();
      final currentUser = profilecontroller.currentUser.value;
      members!.add(currentUser!);
    final groupId = const Uuid().v4();
    final timestamp = DateTime.now().toIso8601String();

    // Người tạo là admin
    Map<String, String> memberRoles = {
      currentUser.id! : 'admin',
    };

    // Thêm các thành viên khác làm member
    members?.forEach((user) {
      if (user.id != currentUser.id) {
        memberRoles[user.id!] = 'member';
      }
    });


    final group = GroupChatModel(
      id: groupId,
      name: name,
      description: description ?? "",
      profileUrl: profileUrl,
      groupCoverUrl: groupCoverUrl,
      groupType: groupType,
      createAt: timestamp,
      createBy: currentUser.id,
      members: members,
      memberRoles: memberRoles,
      statusMembers: [],
      lastMessage: "",
      lastMessageTime: "",
      unReadCount: 0,
      timeStamp: timestamp,
      membersSeen: [],
      isMuted: false,
      pinnedMessage: null,
      draftMessages: {}
    );

    try {
      await _firestore
          .collection('groupChats')
          .doc(groupId)
          .set(group.toJson());

      groupChats.add(group);
    } catch (e) {
      print("❌ Error creating group: $e");
    }

  }

  /// Thêm thành viên vào nhóm
  Future<void> addMember(String groupId, User newUser) async {
    final docRef = _firestore.collection("groupChats").doc(groupId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final group = GroupChatModel.fromJson(data);

    group.members ??= [];
    group.memberRoles ??= {};

    // Thêm vào danh sách
    if (!group.members!.any((u) => u.id == newUser.id)) {
      group.members!.add(newUser);
      group.memberRoles![newUser.id!] = "member";
    }

    await docRef.update(group.toJson());
  }

  /// Xoá thành viên khỏi nhóm
  Future<void> removeMember(String groupId, String userId) async {
    final docRef = _firestore.collection("groupChats").doc(groupId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final group = GroupChatModel.fromJson(data);

    group.members?.removeWhere((u) => u.id == userId);
    group.memberRoles?.remove(userId);

    await docRef.update(group.toJson());
  }

  /// Gửi tin nhắn mới đến nhóm
  Future<void> sendMessageToGroup({
  required GroupChatModel groupChat,
  String? message,
  required User userSender,

  String? type, // text, image, etc.
  List<String>? imageUrls,
  String? videoUrl,
  String? audioUrl,
  FileInfo? document,
  String? replyToMessageId,
  List<String>? mentions,
}) async {
  final messageId = const Uuid().v6();
  final now = DateTime.now().toIso8601String();

  final groupMessage = GroupMessageModel(
    id: messageId,
    groupId: groupChat.id,
    senderId: userSender.id,
    senderName: userSender.name,
    senderAvatar: userSender.profileImage,
    message: message,
    timestamp: now,
    type: type ?? "text",
    imageUrls: imageUrls,
    videoUrl: videoUrl,
    audioUrl: audioUrl,
    document: document,
    replyToMessageId: replyToMessageId,
    mentions: mentions,
    seenBy: [],
    reactions: {},
    replies: null
  );

  try {
    final docRef = _firestore.collection('groupChats').doc(groupChat.id);

    // ✅ Gửi tin nhắn vào subcollection "messages"
    await docRef.collection('messages').doc(messageId).set(groupMessage.toJson());

    // ✅ Chỉ cập nhật các trường liên quan đến tin nhắn cuối cùng
    await docRef.update({
      'lastMessage': message,
      'lastMessageSenderId': userSender.id,
      'lastMessageSenderName': userSender.name,
      'lastMessageTimestamp': now,
      'timestamp': now,
      'draftMessages': {}
    });

    // ✅ Xóa tin nháp (nếu có) của người gửi
    await _firestore.collection("chats")
        .doc(groupChat.id)
        .update({
          "draftMessages.${_auth.currentUser!.uid}": FieldValue.delete(),
        });

  } catch (e) {
    print("❌ Lỗi gửi tin nhắn nhóm: $e");
  }
}


  Future<GroupChatRoomModel?> getRoomByGroupId(String groupId) async {
  //String roomId = getRoomId(groupId); // bạn đã có hàm này
  final doc = await _firestore.collection("groupChats").doc(groupId).get();

  if (doc.exists) {
    return GroupChatRoomModel.fromJson(doc.data()!);
  }
  return null;
}
  Future<void> saveDraft(String? groupChatId, String message) async {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  if (groupChatId == null) return;
  await FirebaseFirestore.instance
      .collection("groupChats")
      .doc(groupChatId)
      .set({
        "draftMessages": { currentUserId: message }
      }, SetOptions(merge: true)); // 👈 THÊM DÒNG NÀY
}
  Stream<List<GroupChatModel>> getGroupRooms() {
  return _firestore
      .collection("groupChats")
      .snapshots()
      .map((snapshot) {
        final currentUserId = _auth.currentUser!.uid;
        return snapshot.docs
            .where((doc) {
              final data = doc.data();
              final memberRoles = data['memberRoles'] as Map<String, dynamic>?;
              return memberRoles != null && memberRoles.containsKey(currentUserId);
            })
            
            .map((doc) => GroupChatModel.fromJson(doc.data()))
            .toList();
      });
}


  Future<GroupChatRoomModel?> getGroupRoomByID(String groupId) async {
    final docRef = await _firestore
                .collection("groupChats")
                .doc(groupId)
                .get();
    if (docRef.exists) return GroupChatRoomModel.fromJson(docRef.data()!);
    return null;
  }
  Stream<List<GroupMessageModel>> getGroupMessages(String groupId) {
  return _firestore
      .collection('groupChats')
      .doc(groupId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => GroupMessageModel.fromJson(doc.data()))
          .toList());
}
  final tappedMessages = <String>{}.obs;

  void toggleMessage(String id) {
    if (tappedMessages.contains(id)) {
      tappedMessages.remove(id);
    } else {
      tappedMessages.add(id);
    }
  }

  bool isTapped(String id) => tappedMessages.contains(id);

  Stream<int> getCountMgsNotSeenInGroupRoomId(String groupRoomId, String currentUserId) {
  return _firestore
      .collection("groupChats")
      .doc(groupRoomId)
      .collection("messages")
      .where("senderId", isNotEqualTo: currentUserId)
      .snapshots()
      .map((snapshot) {
        final unSeen = snapshot.docs.where((doc) {
          final seenBy = List<String>.from(doc['seenBy'] ?? []);
          return !seenBy.contains(currentUserId);
        }).toList();
        return unSeen.length;
      });
}
  Future<String> convertStorage(String path) async {
  if (path.isEmpty || !(await File(path).exists())) {
    print("❌ Invalid path: $path");
    return "";
  }

  final url = Uri.parse("https://api.cloudinary.com/v1_1/dod0lqxur/image/upload");

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = "What'sUp"
    ..files.add(await http.MultipartFile.fromPath('file', path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = json.decode(respStr);
    return data['secure_url'];
  } else {
    print("❌ Upload failed with status ${response.statusCode}");
    return "";
  }
}


  Future<void> maskSeen(String groupId) async {
  final snapshot = await _firestore
      .collection("groupChats")
      .doc(groupId)
      .collection("messages")
      .where("senderId", isNotEqualTo: _auth.currentUser!.uid)
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.update({
      'seenBy': FieldValue.arrayUnion([_auth.currentUser!.uid])
    });
  }
}

Future<void> updateMessage(
  String field,
  String content,
  String roomId,
  String messageId,
  String action,
) async {
  final docRef = _firestore
      .collection("groupChats")
      .doc(roomId)
      .collection("messages")
      .doc(messageId);

  final snapshot = await docRef.get();

  if (!snapshot.exists) {
    print("Message not found");
    return;
  }

  final data = snapshot.data();
  Map<String, dynamic> fieldMap = {};

  // Nếu trường đã tồn tại, copy nó ra để cập nhật
  if (data != null && data[field] != null) {
    fieldMap = Map<String, String>.from(data[field]);
  }

  final uid = _auth.currentUser!.uid;

  if (action == "add") {
    fieldMap[uid] = content;
  } else if (action == "remove") {
    fieldMap.remove(uid);
  }

  await docRef.update({field: fieldMap});
}

 Stream<Map<String, String>> getReactionsMessageStream(String messageId, String roomId) {
  final docRef = _firestore
      .collection("groupChats")
      .doc(roomId)
      .collection("messages")
      .doc(messageId);

  return docRef.snapshots().map((snapshot) {
    final data = snapshot.data();

    if (data == null || data["reactions"] == null) {
      return {};
    }

    try {
      return Map<String, String>.from(data["reactions"]);
    } catch (e) {
      print("Lỗi khi parse reactions: $e");
      return {};
    }
  });
}

Future<bool> hasGroupId(String groupId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('groupChats')
      .where('id', isEqualTo: groupId)
      .limit(1) // Tăng hiệu suất
      .get();

  return snapshot.docs.isNotEmpty;
}

}