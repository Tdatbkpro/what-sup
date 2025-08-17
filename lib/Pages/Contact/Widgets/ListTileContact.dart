import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_up/Controller/ContactController.dart';
import 'package:whats_up/Model/ContactModel.dart';
import 'package:whats_up/Model/GroupChatModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';
import 'package:whats_up/Pages/Group/Widget/DefaultAvatarGroup.dart';
import 'package:whats_up/Pages/Profile/ProfilePage.dart';

class Listtilecontact extends StatelessWidget {

  final int type; // 0: bạn bè, 1: nhóm, 2: gợi ý kết bạn
  final VoidCallback? onTap; // 👈 thêm onTap từ ngoài
  final User? user;
  final GroupChatModel? groupChatModel;

  const Listtilecontact({
    super.key,
    required this.type,
    this.onTap, this.user, this.groupChatModel, // 👈 thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap, // 👈 truyền sự kiện tap từ ngoài
      leading: 
      InkWell(
        child: 
          user != null ? Avatarprofile(radius: 20, width: 1, ImgaeUrl: user!.profileImage,) : 
          (groupChatModel!.profileUrl == null ? DefaultGroupAvatar(members: groupChatModel!.members!)
          :  Avatarprofile(radius: 20, width: 1, ImgaeUrl: groupChatModel!.profileUrl,)
          )
        ,
        onTap: () {
          user != null ? Get.to(Profilepage(userInfo: user!)) : null;
        },
      ),
      
      
      
      // InkWell(child: 
      // groupChatModel!.profileUrl == null  && user == null ?
      // Avatarprofile(radius: 20, width: 0, ImgaeUrl: user == null ?  groupChatModel!.profileUrl : user!.profileImage,),
      //   onTap: () {
      //    /// Get.to(Profilepage(userInfo: user!));
      //   },
      // ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( user == null ?  groupChatModel!.name.toString() : user!.name.toString(), style: Theme.of(context).textTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.w600
          )),
          Text(
             user == null ?  groupChatModel!.description ?? "" : user!.bio ?? "",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14),
          ),
        ],
      ),
      trailing: _buildTrailing(context),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    ContactController contactController = Get.put(ContactController());
    final colorScheme = Theme.of(context).colorScheme;

    if (type == 0) {
      return IconButton(
        icon: const Icon(Icons.call),
        color: colorScheme.primary,
        onPressed: () {},
      );
    } else if (type == 1) {
      return const SizedBox.shrink();
    } else {
      return StreamBuilder<Contact?>(
  stream: contactController.getContactBetweenUsers(
    currentUserId: auth.currentUser!.uid,
    otherUserId: user!.id!,
  ),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: const Text("Đang tải..."),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
        ),
      );
    }

    final contact = snapshot.data;

    if (contact == null) {
      return ElevatedButton.icon(
        onPressed: () {
          contactController.sendFriendRequest(
            senderId: auth.currentUser!.uid,
            receiverId: user!.id!,
          );
        },
        icon: const Icon(Icons.person_add_alt_1, size: 16),
        label: const Text("Kết bạn", style: TextStyle(fontSize: 14),),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      );
    }

    final isCurrentUserSender = contact.senderId == auth.currentUser!.uid;

    switch (contact.status) {
      case ContactStatus.pending:
        if (isCurrentUserSender) {
          return ElevatedButton.icon(
            onPressed: () {
              contactController.unfriend(user!.id!);
            },
            icon: const Icon(Icons.person_remove_alt_1, size: 16, color: Colors.orange),
            label: const Text("Hủy kết bạn", style: TextStyle(color: Colors.orange ,fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  contactController.acceptFriendRequest(user!.id!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text("Chấp nhận", style: TextStyle(color: Colors.teal, fontSize: 14)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () {
                  //contactController.rejectFriendRequest(user.id!);
                  contactController.unfriend( user!.id!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text("Từ chối", style: TextStyle(color: Colors.red ,fontSize: 14)),
              ),
            ],
          );
        }

      case ContactStatus.accepted:
        return const SizedBox.shrink();

      case ContactStatus.rejected:  
      return const SizedBox.shrink();
    }
  },
);

    }
  }
}
