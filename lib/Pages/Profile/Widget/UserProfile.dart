import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/UserAvarta.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Controller/CallController.dart';
import 'package:whats_up/Controller/ContactController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/ContactModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Call/AudioCall.dart';
import 'package:whats_up/Pages/Call/VideoCall.dart';
import 'package:whats_up/Pages/Chat/ChatPage.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';

class Userprofile extends StatelessWidget {
  final User userInfo;
  const Userprofile({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    Authcontroller authcontroller = Get.put(Authcontroller());
    Profilecontroller profilecontroller = Get.put(Profilecontroller());
    ContactController contactController = Get.put(ContactController());
    CallController callController = Get.put(CallController());
    final auth = FirebaseAuth.instance.currentUser;
    return SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Avatarprofile(radius: 40, width: 2, ImgaeUrl: userInfo.profileImage,),
              SizedBox(height: 10),
              Text(
                userInfo.name ?? "user",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(fontSize: 20),
              ),
              Text(
                userInfo.email ?? "email",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                     final callId = await callController.callAction(userInfo, profilecontroller.currentUser.value, "audio");
                      Get.to(AudioCallPage(callId: callId,));
                    },
                    icon: Icon(Icons.call),
                    label: Text("Call"),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade800,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,   
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),  
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Get.to(Chatpage(user: userInfo));
                    },
                    icon: Icon(Icons.chat_outlined),
                    label: Text("Chat"),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: Colors.blue.shade800,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final callId = await callController.callAction(userInfo, profilecontroller.currentUser.value, "video");
                      Get.to(VideoCallPage(callId: callId,));
                    },
                    icon: Icon(Icons.video_call_sharp),
                    label: Text("Video"),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      foregroundColor: Colors.purple.shade800,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),

              // 🔴 LOGOUT BUTTON
              StreamBuilder<Contact?>(
                stream: contactController.getContactBetweenUsers(currentUserId: auth!.uid, otherUserId: userInfo.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LottieAnimation(size: Size(100,100), type: "circle_loading"));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  }

                  final contact = snapshot.data;
                  if(contact == null) {
                    return Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () {
                          contactController.sendFriendRequest(senderId: auth.uid, receiverId: userInfo.id!);
                      },
                      icon: Icon(Icons.logout),
                      label: Text("Kết bạn"),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        
                      ),
                      
                    ),
                  );
                  }
                   else if (contact.status == ContactStatus.accepted) {
                        return Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () {
                          contactController.unfriend(userInfo.id!);
                      },
                      icon: Icon(Icons.logout),
                      label: Text("Xóa bạn"),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade800,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        
                      ),
                      
                    ),
                  );
                   } else if (contact.status == ContactStatus.pending &&  contact.senderId == auth.uid) {
                        return Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () {
                          contactController.cancelRequest(userInfo.id!);
                      },
                      icon: Icon(Icons.logout),
                      label: Text("Hủy kết bạn"),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        
                      ),
                      
                    ),
                  );
                   } else {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                              Align(
                              alignment: Alignment.center,
                              child: TextButton.icon(
                                onPressed: () {
                                    contactController.unfriend(userInfo.id!);
                                },
                                icon: Icon(Icons.logout),
                                label: Text("Từ chối"),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red.shade800,
                                  foregroundColor: Colors.red.shade100,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  
                                ),
                                
                              ),
                            ),
                            SizedBox(width: 15,),
                            Align(
                              alignment: Alignment.center,
                              child: TextButton.icon(
                                onPressed: () {
                                    contactController.acceptFriendRequest(userInfo.id!);
                                },
                                icon: Icon(Icons.logout),
                                label: Text("Chấp nhận"),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.teal.shade800,
                                  foregroundColor: Colors.teal.shade100,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  
                                ),
                                
                              ),
                            ),
                        ],
                      );
                   }
                },
              )

            ],
          ),
        ),
      );
  }
}