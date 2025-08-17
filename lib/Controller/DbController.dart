import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:get/get.dart';
import 'package:whats_up/Model/GroupChatModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Model/ContactModel.dart'; // nếu cần model Contact

class Dbcontroller extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;
  RxList<User> allUsers = <User>[].obs;
  RxList<User> friendList = <User>[].obs;
  RxList<User> notFriendList = <User>[].obs;
  RxList<GroupChatModel> groupJoins = <GroupChatModel>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await getUserList();
    await getGroupList();
    
  }

Future<void> getUserList() async {
  isLoading.value = false;

  final currentUserId = auth.currentUser!.uid;

  // Stream người dùng (trừ bản thân)
  db
      .collection("user")
      .where("id", isNotEqualTo: currentUserId)
      .snapshots()
      .listen((allSnapshot) async {
    allUsers.value =
        allSnapshot.docs.map((e) => User.fromJson(e.data())).toList();

    // Stream contacts accepted liên quan đến currentUser
    db
        .collection("contacts")
        .where("status", isEqualTo: "accepted")
        .where(
          Filter.or(
            Filter("senderId", isEqualTo: currentUserId),
            Filter("receiverId", isEqualTo: currentUserId),
          ),
        )
        .snapshots()
        .listen((contactsSnapshot) {
      final friendUserIds = <String>{};

      for (var doc in contactsSnapshot.docs) {
        final data = doc.data();
        if (data['senderId'] == currentUserId) {
          friendUserIds.add(data['receiverId']);
        } else {
          friendUserIds.add(data['senderId']);
        }
      }

      friendList.value =
          allUsers.where((user) => friendUserIds.contains(user.id)).toList();
      notFriendList.value =
          allUsers.where((user) => !friendUserIds.contains(user.id)).toList();

      isLoading.value = true;
    });
  });
}

Future<void> getGroupList() async {
    db.collection("groupChats").snapshots()
    .listen((allSnapshot) async {
      final all = allSnapshot.docs.map((e) => GroupChatModel.fromJson(e.data())).toList();
      groupJoins.value = all.toList();
    });
} 
}