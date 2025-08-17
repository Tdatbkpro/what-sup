import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_up/Model/ContactModel.dart';


class ContactController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final contacts = <Contact>[].obs;
  String getContactId(String targetUserId) {
  String currentUserId = auth.currentUser!.uid;
  return (currentUserId.compareTo(targetUserId) > 0)
      ? "$currentUserId$targetUserId"
      : "$targetUserId$currentUserId";
}

Stream<Contact?> getContactBetweenUsers({
  required String currentUserId,
  required String otherUserId,
}) {
  final contactId = getContactId(otherUserId); // 👈 ghép ID theo quy tắc
  return _firestore
      .collection('contacts')
      .doc(contactId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return null;
        return Contact.fromJson(snapshot.data()!);
      });
}


  /// Gửi yêu cầu kết bạn
  Future<void> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    final contactId = getContactId(receiverId);
    final contact = Contact(
      id: contactId,
      senderId: senderId,
      receiverId: receiverId,
      createdAt: DateTime.now(),
      status: ContactStatus.pending,
    );

    try {
      await _firestore.collection('contacts').doc(contactId).set(contact.toJson());
      contacts.add(contact);
    } catch (e) {
      print("Error sending friend request: $e");
    }
  }

  Future<void> acceptFriendRequest(String senderId) async {
    String contactId = getContactId(senderId);
    await _firestore.collection("contacts").doc(contactId).update({"status" : ContactStatus.accepted.name});
  }
  Future<void> rejectFriendRequest(String senderId) async {
    String contactId = getContactId(senderId);
    await _firestore.collection("contacts").doc(contactId).update({"status" : ContactStatus.rejected.name});
  }
  /// Cập nhật trạng thái lời mời (chấp nhận / từ chối)
  Future<void> updateStatus({
    required String contactId,
    required ContactStatus newStatus,
  }) async {
    try {
      await _firestore.collection('contacts').doc(contactId).update({
        'status': newStatus.name,
      });

      // Cập nhật trong danh sách local
      final index = contacts.indexWhere((c) => c.id == contactId);
      if (index != -1) {
        contacts[index].status = newStatus;
        contacts.refresh();
      }
    } catch (e) {
      print("Error updating contact status: $e");
    }
  }

  /// Kiểm tra xem đã gửi lời mời chưa
  Future<bool> hasSentRequest(String senderId, String receiverId) async {
    final query = await _firestore
        .collection('contacts')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: ContactStatus.pending.name)
        .get();

    return query.docs.isNotEmpty;
  }
  Stream<bool> hasSentRequestStream(String senderId, String receiverId) {
  return _firestore
      .collection('contacts')
      .where('senderId', isEqualTo: senderId)
      .where('receiverId', isEqualTo: receiverId)
      .where('status', isEqualTo: ContactStatus.pending.name)
      .snapshots()
      .map((snapshot) => snapshot.docs.isNotEmpty);
}

  Future<void> unfriend(String otherUserId) async {
  final contactId = getContactId(otherUserId);
  try {
    final docRef = _firestore.collection("contacts").doc(contactId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      print("❌ Không tồn tại liên hệ với $otherUserId.");
      return;
    }

    await docRef.delete();
    contacts.removeWhere((c) => c.id == contactId);

    print("✅ Đã hủy kết bạn với $otherUserId");
  } catch (e) {
    print("❌ Lỗi khi hủy kết bạn: $e");
  }
}



  /// Hủy lời mời đã gửi
  Future<void> cancelRequest(String contactId) async {
    try {
      await _firestore.collection('contacts').doc(contactId).delete();
      contacts.removeWhere((c) => c.id == contactId);
    } catch (e) {
      print("Error cancelling request: $e");
    }
  }
}
