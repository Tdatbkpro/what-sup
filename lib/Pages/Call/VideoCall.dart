import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_up/Config/CallConfigZego.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallPage extends StatelessWidget {
  final String callId;
  const VideoCallPage({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
  final profileController = Get.find<Profilecontroller>();

  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('notification')
        .doc(profileController.currentUser.value.id)
        .collection('call')
        .doc(callId)
        .snapshots(),
    builder: (context, snapshot) {
      Map<String, dynamic>? data;

      if (snapshot.connectionState == ConnectionState.active) {
        final doc = snapshot.data;

        if (doc == null || !doc.exists) {
          Future.microtask(() => Navigator.pop(context));
        } else {
          data = doc.data() as Map<String, dynamic>;
          if (data!['status'] != 'accepted' && data['status'] != 'dialing') {
            Future.microtask(() => Navigator.pop(context));
          }
        }
      }

      return Scaffold(
        body: SafeArea(
          child: ZegoUIKitPrebuiltCall(
            appID: ZegoCallConfig.appId,
            appSign: ZegoCallConfig.appSign,
            userID: profileController.currentUser.value.id ?? '',
            userName: profileController.currentUser.value.name ?? '',
            callID: callId,
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              ..turnOnCameraWhenJoining = true
              ..useSpeakerWhenJoining = true,
            events: ZegoUIKitPrebuiltCallEvents(
              onCallEnd: (event, defaultAction) async {
                defaultAction();

                if (data == null) return; // Tránh lỗi null

                final currentUserId = profileController.currentUser.value.id;
                final otherUserId = currentUserId == data!['callerUid']
                    ? data!['receiverUid']
                    : data!['callerUid'];

                await Future.wait([
                  FirebaseFirestore.instance
                      .collection('notification')
                      .doc(currentUserId)
                      .collection('call')
                      .doc(callId)
                      .update({'status': 'ended'}),
                  FirebaseFirestore.instance
                      .collection('notification')
                      .doc(otherUserId)
                      .collection('call')
                      .doc(callId)
                      .update({'status': 'ended'}),
                ]);
              },
            ),
          ),
        ),
      );
    },
  );
}


}
