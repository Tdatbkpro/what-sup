import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/DbController.dart';
import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Pages/Chat/ChatPage.dart';
import 'package:whats_up/Pages/Contact/Widgets/ListTileContact.dart';
import 'package:whats_up/Pages/Group/GroupChatPage.dart';

class ListContact extends StatefulWidget {
  const ListContact({super.key});

  @override
  State<ListContact> createState() => _ListContactState();
}

class _ListContactState extends State<ListContact> {
  Future<void> _refreshData() async {
    // Đợi vài giây để mô phỏng việc load lại dữ liệu
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Cập nhật lại dữ liệu tại đây nếu cần
    });
  }

  @override
  Widget build(BuildContext context) {

    Dbcontroller dbcontroller = Get.put(Dbcontroller());
    ChatController chatController = Get.put(ChatController());
    final contacts = dbcontroller.friendList;
    
    final groups = dbcontroller.groupJoins;
    final suggestionContact = dbcontroller.notFriendList;

    final totalItemCount = contacts.length + groups.length + suggestionContact.length + 3;

  return Obx(() {
    final totalItemCount = contacts.length + groups.length + suggestionContact.length + 3;
      if (!dbcontroller.isLoading.value) {
        return Center(
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      );
      }
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        itemCount: totalItemCount,

        itemBuilder: (context, index) {

          if (index == 0) {
            return Text("Bạn bè (${contacts.length})", style: Theme.of(context).textTheme.labelSmall);
          } else if (index <= contacts.length) {
            final contact = contacts[index-1];
            
              final ChatController chatController = Get.put(ChatController());
              chatController.markAsReceived(contact.id!);

            return Listtilecontact(
                type: 0,
                user: contact, 
                onTap: () {
                    chatController.navigateToChat(contact);
                },
              );

          } else if (index == contacts.length + 1) {
            return Text("Nhóm (${groups.length})", style: Theme.of(context).textTheme.labelSmall);
          } else if (index <= contacts.length + 1 + groups.length) {          
            if ( groups[index - contacts.length - 2].memberRoles!.keys.contains(FirebaseAuth.instance.currentUser!.uid) )
              {
                final group = groups[index - contacts.length - 2];
                return Listtilecontact( type: 1, groupChatModel: group,onTap: () {
                  Get.to(Groupchatpage(groupChatModel: group));
                },);
              } else {
                return SizedBox.shrink();
              }
            
            return SizedBox.shrink();
          } else if (index == contacts.length + groups.length + 2) {
            return Text("Gợi ý kết bạn (${suggestionContact.length})", style: Theme.of(context).textTheme.labelSmall);
          } else {
            final suggestion = suggestionContact[index - contacts.length - groups.length - 3];
            return Listtilecontact( type: 2,user: suggestion, onTap: () {
                  chatController.navigateToChat(suggestion);
                },);
            return SizedBox.shrink();
          }
        },

        separatorBuilder: (context, index) {
          // Không vẽ divider dưới tiêu đề
          if (index == 0 ||
              index == contacts.length || 
              index == contacts.length +1  ||
              index == contacts.length + groups.length +1 ||
              index == contacts.length + groups.length + 2) {
            return const SizedBox.shrink();
          }
          return const Divider(
            height: 1,
            thickness: 0.5,
            indent: 15,
            endIndent: 15,
          );
        },
      ),
    );
  });
  }
}
