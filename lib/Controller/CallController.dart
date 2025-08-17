import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Model/CallModel.dart';
import 'package:whats_up/Pages/Call/AudioCall.dart';
import 'package:whats_up/Pages/Call/VideoCall.dart';

class CallController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final uuid = Uuid();
  StreamSubscription? _incomingCallSub;
  @override
  void onInit() {
    super.onInit();

    // Yêu cầu quyền notification (Android 13+)
    FlutterCallkitIncoming.requestNotificationPermission(
      {
        "title": "Notification permission",
        "rationaleMessagePermission": "Notification permission is required, to show notification.",
        "postNotificationMessageRequired": "Notification permission is required, Please allow notification permission from setting."
      },
    );

    // Yêu cầu quyền fullScreenIntent (Android 14+)
    _requestFullScreenIntentPermission();

    // Lắng nghe cuộc gọi đến
    if (auth.currentUser != null) {
     _incomingCallSub = getIncomingCalls().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final lastestCall = snapshot.docs.first;
          final data = lastestCall.data() as Map<String, dynamic>;
          final callId = data['id'] ?? lastestCall.id;
          final callerName = data['callerName'] ?? "Người gọi";
          final callerPic = data['callerPic'];
          final receiverId = data['receiverUid'];
          final type = data['type'];

          showIncomingCall(callId, callerName, callerPic, receiverId, type);
        }
      });
    }
    
    @override
    void onClose() {
      _incomingCallSub?.cancel();
      super.onClose();

    }

    // Lắng nghe sự kiện từ CallkitIncoming
    FlutterCallkitIncoming.onEvent.listen((event) async {
  final eventName = event?.event;
  final callId = event?.body?['id'];
  final receiverId = event?.body?['extra']?['receiverId'];
  final callerName = event?.body?['nameCaller'];
  final type = event?.body?['type'];

  print("CALL EVENT: $eventName");
  print("Receiver ID: $receiverId");

  switch (eventName) {
    case Event.actionCallAccept:
  if (receiverId != null) {
    await updateCallStatus(callId, 'accepted');

    // Đợi status chuyển sang 'accepted' để đồng bộ cả 2 bên
    final docRef = db
        .collection("notification")
        .doc(receiverId)
        .collection("call")
        .doc(callId);

    bool isAccepted = false;
    int retry = 0;

    while (!isAccepted && retry < 20) { // timeout ~ 2s
      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data()?['status'] == 'accepted') {
        isAccepted = true;
        break;
      }
      await Future.delayed(Duration(milliseconds: 100));
      retry++;
    }

    if (isAccepted) {
      if (type == 0){
          Get.to(() => AudioCallPage(callId: callId));
      } else {
        Get.to(() => VideoCallPage(callId: callId));
      }
      ;
    } else {
      print("Timeout waiting for accepted status");
    }
  } else {
    print('Receiver ID is null');
  }
  break;

    case Event.actionCallDecline:
      await updateCallStatus(callId, 'declined');
    case Event.actionCallEnded:
      await updateCallStatus(callId, 'ended');
    case Event.actionCallTimeout:
      await updateCallStatus(callId, 'declined');
      await showMissedCallNotification(callerName);
      break;
    default:
      print('Unhandled event: $eventName');
  }
});

  }

  Future<void> _requestFullScreenIntentPermission() async {
    bool canUse = await FlutterCallkitIncoming.canUseFullScreenIntent();
    if (!canUse) {
      await FlutterCallkitIncoming.requestFullIntentPermission();
    }
  }

 Future<String> callAction(User receiver, User caller, String type) async {
  String callId = uuid.v6();
  var newCall = CallModel(
    id: callId,
    callerEmail: caller.email,
    callerPic: caller.profileImage,
    callerUid: caller.id,
    receiverEmail: receiver.email,
    receiverName: receiver.name,
    receiverPic: receiver.profileImage,
    receiverUid: receiver.id,
    callerName: caller.name,
    status: "dialing",
    type: type,
  );

  try {
    // 📌 Ghi vào cả người gọi và người nhận
    final receiverRef = db
        .collection('notification')
        .doc(receiver.id)
        .collection('call')
        .doc(callId);

    final callerRef = db
        .collection('notification')
        .doc(caller.id)
        .collection('call')
        .doc(callId);

    final callData = {
      ...newCall.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Ghi song song cả 2 nơi
    await Future.wait([
      receiverRef.set(callData),
      callerRef.set(callData),
    ]);

    // Đợi Firestore tạo xong (có thể chỉ cần kiểm tra ở receiver)
    int attempts = 0;
    while (attempts < 50) {
      final snapshot = await receiverRef.get();
      if (snapshot.exists) break;
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (attempts == 50) {
      print("Timeout waiting for Firestore doc creation");
      return "";
    }

    return callId;
  } catch (e) {
    print("Error creating call: $e");
    return "";
  }
}



  Stream<QuerySnapshot> getIncomingCalls() {
    if (auth.currentUser == null) return const Stream.empty();
    return db
        .collection("notification")
        .doc(auth.currentUser!.uid)
        .collection("call")
        .where("status", isEqualTo: "dialing")
        .where("receiverUid", isEqualTo: auth.currentUser!.uid)
        .snapshots();
  }

  Future<void> updateCallStatus(String? callId, String status) async {
    if (callId == null || auth.currentUser == null) return;
    try {
      await db
          .collection("notification")
          .doc(auth.currentUser!.uid)
          .collection("call")
          .doc(callId)
          .update({'status': status});
    } catch (e) {
      print("Error updating call status: $e");
    }
  }

  Future<void> deleteCall(String callId) async {
    if (auth.currentUser == null) return;
    try {
      await db
          .collection("notification")
          .doc(auth.currentUser!.uid)
          .collection("call")
          .doc(callId)
          .delete();
    } catch (e) {
      print("Error deleting call: $e");
    }
  }

  Future<void> showIncomingCall(String callId, String callerName, String callerPic, String receiverId, String type) async {
    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      normalHandle: 24,
      callingNotification: NotificationParams(
        callbackText: "Gọi lại",
        isShowCallback: true,
        count: 5,
        id: DateTime.now().millisecondsSinceEpoch,
        showNotification: true,
        subtitle: "Cuộc gọi từ $callerName",
      ),
      appName: "What's Up",
      avatar: callerPic,
      handle: type == "audio" ?'Gọi thoại' : "Gọi video",
      type: type == "audio" ? 0 : 1, // 0: audio, 1: video
      duration: 60000,
      textAccept: 'Chấp nhận',
      textDecline: 'Từ chối',
      extra: {
        'userId': auth.currentUser?.uid,
        'receiverId' : receiverId
        },
      android: AndroidParams(
        isCustomNotification: true,
        isCustomSmallExNotification: true,
        isShowLogo: true  ,
        ringtonePath: 'system_ringtone_default',
        isShowFullLockedScreen: true,
        logoUrl: 'assets/icons/app_icon.png',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Cuộc gọi đến",
        isImportant: true,
        missedCallNotificationChannelName: "Cuộc gọi nhỡ"
      ),
      ios: IOSParams(
        iconName: 'CallKitIcon',
        handleType: 'generic',
        supportsVideo: false,
        audioSessionActive: true,

      ),
    );


    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> endCall(String callId) async {
    await FlutterCallkitIncoming.endCall(callId);
  }

  Future<void> showMissedCallNotification(String callerName) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('missed_call_channel', 'Cuộc gọi nhỡ',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Cuộc gọi nhỡ',
    'Bạn có cuộc gọi nhỡ từ $callerName',
    platformChannelSpecifics,
  );
}

}
