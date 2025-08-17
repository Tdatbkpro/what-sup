import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v6.dart';
import 'package:whats_up/Controller/ContactController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/ChatRoomModel.dart';
import 'package:whats_up/Model/ChatRoomWithCount.dart';
import 'package:whats_up/Model/ContactModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:http/http.dart' as http;
import 'package:whats_up/Pages/Chat/ChatPage.dart';
import 'package:whats_up/Pages/Chat/Widgets/ChatBottomBarPage.dart';

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final chatId = Uuid();
  

  String getRoomId(String targetUserId) {
  String currentUserId = auth.currentUser!.uid;
  return (currentUserId.compareTo(targetUserId) > 0)
      ? "$currentUserId$targetUserId"
      : "$targetUserId$currentUserId";
}

  //Future<void> senImages(String )

  Future<void> send(String targetUserId, String? message,List<XFile>? imageUrls, User received, String? mapUrl, String? cardId, FileInfo? filePicker, String? fileRecord) async {
    List<String> imageCvtUrls = [];
    

    if (imageUrls != null && imageUrls != []) {
      for (XFile imageXFile in imageUrls) {
    
    String imagePath = imageXFile.path;
    final url = Uri.parse("https://api.cloudinary.com/v1_1/dod0lqxur/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = "What'sUp"
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
        imageCvtUrls.add(data['secure_url']);
    } else {
      print("❌ Upload ảnh thất bại");
    }
    }
    }
    Profilecontroller profilecontroller = Get.put(Profilecontroller());
    User userShared = User();
    
    if(cardId != null) {
      userShared = await profilecontroller.getUserById(cardId!);
    }
    String roomId = getRoomId(targetUserId);
    ChatModel chatModel = ChatModel(
      id: chatId.v6(),
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      senderId: auth.currentUser!.uid,
      receiverId: targetUserId,
      senderName: profilecontroller.currentUser.value.name,
      readStatus: "sending",
      imageUrls: imageCvtUrls,
      mapUrl: mapUrl,
      businessId: cardId,
      document: filePicker,
      audioUrl: fileRecord,
      deletedFor: [],
      isRecalled: false,
      replies: ReplyInfo(id: replyMessage.value?.id, content: replyMessage.value?.content)
      
    );


    ChatRoomModel chatRoomModel = ChatRoomModel(
      id: roomId,
      lastMessage: message,
      lastMessageTimestamp: DateTime.now().toIso8601String(),
      sender: profilecontroller.currentUser.value,
      receiver: received,
      timestamp: DateTime.now().toIso8601String(),
      unReadMessNo: 0,
      participants: [received.id! , profilecontroller.currentUser.value.id!],
      draftMessages: {}
    );
    try {
          final docRef = db
            .collection("chats")
            .doc(roomId)
            .collection("messages")
            .doc(chatModel.id);

        // Gửi tin nhắn (tạm thời để là sending)
        await docRef.set(chatModel.toJson());

        // Nếu không lỗi thì cập nhật lại thành sent
        await docRef.update({"readStatus": "sent"});
        await db.collection("chats")
                .doc(roomId)
                .set(
                  chatRoomModel.toJson()
                )
                ;
        await db.collection("chats")
        .doc(roomId)
        .update({
          "draftMessages.${auth.currentUser!.uid}": FieldValue.delete(),
        });

    }
     catch (e){
        print("✅ ${e}");
     }
  }


  Future<ChatRoomModel?> getRoomByUserId(String targetUserId) async {
  String roomId = getRoomId(targetUserId); // bạn đã có hàm này
  final doc = await db.collection("chats").doc(roomId).get();

  if (doc.exists) {
    return ChatRoomModel.fromJson(doc.data()!);
  }
  return null;
}

Future<void> saveDraft(String? roomId, String message) async {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  if (roomId == null) return;
  await FirebaseFirestore.instance
      .collection("chats")
      .doc(roomId)
      .set({
        "draftMessages": { currentUserId: message }
      }, SetOptions(merge: true)); // 👈 THÊM DÒNG NÀY
}


  Stream<List<ChatModel>> getMessages(String targetUserId) {
    String roomId = getRoomId(targetUserId);
    return db
    .collection("chats")
    .doc(roomId)
    .collection("messages")
    .orderBy("timestamp", descending: false)
    .snapshots()
    .map(
      (snapshot) => snapshot.docs.map(
        (doc) => ChatModel.fromJson(doc.data())
      ).toList()
    );
  }
  Stream<List<ChatRoomModel>> getRooms() {
  return db
      .collection("chats")
      .where('participants', arrayContains: auth.currentUser!.uid)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => ChatRoomModel.fromJson(doc.data())).toList();
      });
}
  Stream<int> getCountMgsNotSeenInRoomId(String roomId, String targetUserId) {
  return db
      .collection("chats")
      .doc(roomId)
      .collection("messages")
      .where('senderId', isEqualTo: targetUserId)
      .where('readStatus', whereIn: ["sent", "received"])
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

  Future<void> markAsReceived(String targetUserId) async {
  String roomId = getRoomId(targetUserId);
  final snapshot = await db
      .collection("chats")
      .doc(roomId)
      .collection("messages")
      .where("receiverId", isEqualTo: auth.currentUser!.uid)
      .where("readStatus", isEqualTo: "sent")
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.update({"readStatus": "received"});
  }
}

Future<void> markAsSeen(String targetUserId) async {
  String roomId = getRoomId(targetUserId);
  final snapshot = await db
      .collection("chats")
      .doc(roomId)
      .collection("messages")
      .where("receiverId", isEqualTo: auth.currentUser!.uid)
      .where("readStatus",  whereIn: ["sent", "received"])
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.update({
      "readStatus": "seen",
      "seenAt": DateTime.now().toIso8601String()
    });
  }
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



String getFormattedDateGroup(String? currentTimestamp, [String? previousTimestamp]) {
  if (currentTimestamp == null) return '';

  final current = DateTime.tryParse(currentTimestamp);
  if (current == null) return '';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final currentDate = DateTime(current.year, current.month, current.day);

  // Nếu có previousTimestamp thì kiểm tra khoảng cách < 30 phút
  if (previousTimestamp != null) {
    final previous = DateTime.tryParse(previousTimestamp);
    if (previous != null) {
      final prevDate = DateTime(previous.year, previous.month, previous.day);
      final sameDay = prevDate == currentDate;
      final diffMinutes = current.difference(previous).inMinutes;

      if (sameDay && diffMinutes <= 30) {
        return ''; // Không cần nhóm
      }
    }
  }

  final diff = today.difference(currentDate).inDays;

  if (diff == 0) return "Hôm nay Lúc ${DateFormat("HH:mm").format(current)}";
  if (diff == 1) return "Hôm qua Lúc ${DateFormat("HH:mm").format(current)}";

  return "${currentDate.day.toString().padLeft(2, '0')}/"
         "${currentDate.month.toString().padLeft(2, '0')}/"
         "${currentDate.year} Lúc ${DateFormat("HH:mm").format(current)}";
}
String getFormattedDate(String? currentTimestamp, [String? previousTimestamp]) {
  if (currentTimestamp == null) return '';

  final current = DateTime.tryParse(currentTimestamp);
  if (current == null) return '';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final currentDate = DateTime(current.year, current.month, current.day);

  final diff = today.difference(currentDate).inDays;

  if (diff == 0) return "Hôm nay Lúc ${DateFormat("HH:mm").format(current)}";
  if (diff == 1) return "Hôm qua Lúc ${DateFormat("HH:mm").format(current)}";

  return "${currentDate.day.toString().padLeft(2, '0')}/"
         "${currentDate.month.toString().padLeft(2, '0')}/"
         "${currentDate.year} Lúc ${DateFormat("HH:mm").format(current)}";
}

  final ContactController _contactController = Get.put(ContactController());
  void navigateToChat(User user) async {
  final contact = await _contactController
      .getContactBetweenUsers(currentUserId: auth.currentUser!.uid, otherUserId: user.id!)
      .first;

  if (contact == null || contact.status != ContactStatus.accepted) {
    Get.snackbar(
      "Không thể mở chat",
      "Hai bạn chưa phải là bạn bè của nhau.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  Get.to(() => Chatpage(user: user)); // chỉ vào nếu quan hệ OK
}
  Future<void> updateMessage(
  String field,
  String content,
  String roomId,
  String messageId,
  String action,
) async {
  final docRef = db
      .collection("chats")
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

  final uid = auth.currentUser!.uid;

  if (action == "add") {
    fieldMap[uid] = content;
  } else if (action == "remove") {
    fieldMap.remove(uid);
  }

  await docRef.update({field: fieldMap});
}

  Stream<Map<String, String>> getReactionsMessageStream(String messageId, String roomId) {
  final docRef = db
      .collection("chats")
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

  Rx<ReplyMessage?> replyMessage = Rx<ReplyMessage?>(null);
  RxBool isReplying = false.obs;

  void setReplyMessage(ReplyMessage msg) {
    replyMessage.value = msg;
    isReplying.value = true;
  }

  void clearReply() {
    replyMessage.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
  isReplying.value = false;
});

  }

  Future<void> deleteMessages({
  required String roomId,
  required List<String> messageIds,
  bool isRecall = false,
}) async {
  final userId = auth.currentUser!.uid;
  final batch = db.batch();

  for (final messageId in messageIds) {
    final docRef = db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .doc(messageId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) continue;

    final data = snapshot.data()!;
    final senderId = data['senderId'];

    if (isRecall && senderId == userId) {
      // ✅ Nếu là thu hồi (và là người gửi)
      batch.update(docRef, {
        'isRecalled': true,
        'message': "Tin nhắn đã bị thu hồi",
        'imageUrls': [],
        'audioUrl': null,
        'mapUrl': null,
        'document': null,
      });
    } else {
      // ✅ Xóa phía mình
      final deletedFor = List<String>.from(data['deletedFor'] ?? []);
      if (!deletedFor.contains(userId)) {
        deletedFor.add(userId);
        batch.update(docRef, {
          'deletedFor': deletedFor,
        });
      }
    }
  }

  await batch.commit();
}


}


