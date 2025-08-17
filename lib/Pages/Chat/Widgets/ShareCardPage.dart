import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/ContactController.dart';
import 'package:whats_up/Controller/DbController.dart';
import 'package:whats_up/Controller/GroupChatController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Model/ChatRoomModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/ChatPage.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';



class ShareCardChat extends StatefulWidget {
  final User sharedUser;
  const ShareCardChat({super.key, required this.sharedUser});

  @override
  State<ShareCardChat> createState() => _ShareCardChatState();
}

class _ShareCardChatState extends State<ShareCardChat> {
  final FocusNode _focusNodeSearch = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ChatController _chatController = Get.put(ChatController());
   List<User> allUsers = [];
  final Dbcontroller dbcontroller = Get.put(Dbcontroller());
  final ValueNotifier<bool> _hasFocus = ValueNotifier(false);
  final auth = FirebaseAuth.instance;
  final RxBool _typeAbcSeach = true.obs;
  

  @override
void initState() {
  super.initState();

}


  


  List<User> selectedUsers = [];

  void _toggleUser(User user) {
    setState(() {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    });
  }
  void _togglleSuffixSearch() async {
   _focusNodeSearch.unfocus(); // Ẩn bàn phím
  await Future.delayed(const Duration(milliseconds: 100)); // Đợi bàn phím đóng
  _typeAbcSeach.value = !_typeAbcSeach.value; // Đảo trạng thái
  _focusNodeSearch.requestFocus();
  }
  bool _isSelected(User user) => selectedUsers.contains(user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text( "Gửi danh thiếp"  , style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w600
            )),
            Text("Đã chọn: ${selectedUsers.length}", style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 14
            ))
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Obx( () =>
                 TextField(
                controller: _searchController,
                focusNode: _focusNodeSearch,
                onChanged: (_) => setState(() {}),
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          ),
                keyboardType: _typeAbcSeach.value == true ? TextInputType.name : TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  prefixIcon: Icon(Icons.search),
                  
                  hintText: "Tìm tên hoặc số điện thoại",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder( // Viền khi focus
                    borderSide: BorderSide(color: Colors.blue, width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w500,),
                  hintStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w500,),
                  suffixIcon: _typeAbcSeach.value == true ? IconButton(onPressed: _togglleSuffixSearch
                  , icon: Icon(Icons.abc_rounded))  :  IconButton(onPressed: _togglleSuffixSearch
                  , icon: Icon(Icons.numbers)) 
                ),
              ),
            ),
          ),
          SizedBox(height: 8),

          // Danh sách người dùng
          Expanded(
          child: Obx(() {
            final filteredUsers = dbcontroller.friendList.where((user) {
              final query = _searchController.text.toLowerCase();
              final name = user.name?.toLowerCase() ?? '';
              return name.contains(query);
            }).toList();

            if (filteredUsers.isEmpty) {
              return  Center(child: Text("Không tồn tại người dùng nào." , style: Theme.of(context).textTheme.labelMedium,));
            }

            return ListView.separated(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  leading: user.profileImage != null
                      ? Avatarprofile(radius: 20, width: 1, ImgaeUrl: user.profileImage)
                      : CircleAvatar(child: Text(user.name![0])),
                  title: Text(user.name!,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.w600)),
                  subtitle: FutureBuilder(
                    future: _chatController.getRoomByUserId(user.id!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final chatRoom = snapshot.data;
                      return Text(
                        _chatController.getFormattedDate(chatRoom!.lastMessageTimestamp!),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                      );
                    },
                  ),
                  trailing: _isSelected(user)
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                  onTap: () => _toggleUser(user),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.blue,
                indent: 20,
                endIndent: 20,
              ),
            );
          }),
        ),


          // Danh sách đã chọn + nút tiếp tục
          if (selectedUsers.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                
                border: Border(top: BorderSide(color: Colors.blue) ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight:Radius.circular(12)),
                boxShadow: [
                BoxShadow(
                  color:  Colors.white.withAlpha((0.1 * 255).round()), // dùng alpha (0–255)
                  offset: Offset(0, -4), // bóng ở phía trên
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
    ],
                color: Theme.of(context).colorScheme.primaryContainer
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: selectedUsers.map((user) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Avatarprofile(radius: 18, width: 1,  ImgaeUrl: user.profileImage,),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: InkWell(
                                    onTap: () => _toggleUser(user),
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.close, size: 14),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                        for(User user in selectedUsers) {
                          _chatController.send(widget.sharedUser.id!, "Danh thiếp của của ${user.name}", null,widget.sharedUser, null, user.id,null,null);
                        }
                        Get.off(() => Chatpage(user:  widget.sharedUser)); // Xoá trang hiện tại và mở lại


                      },
                    shape: CircleBorder(),
                    mini: true,
                    backgroundColor:  Colors.blue,
                    child: Icon(Icons.arrow_forward, color:  Colors.white,),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
