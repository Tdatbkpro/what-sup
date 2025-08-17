import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/ContactController.dart';
import 'package:whats_up/Controller/DbController.dart';
import 'package:whats_up/Controller/GroupChatController.dart';
import 'package:whats_up/Model/ChatRoomModel.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';
import 'package:whats_up/Pages/Contact/Search.dart';

class UserModel {
  final String name;
  final String? avatarUrl;
  final String? subtitle;

  UserModel({required this.name, this.avatarUrl, this.subtitle});
}

class CreateGroupChat extends StatefulWidget {
  const CreateGroupChat({super.key});

  @override
  State<CreateGroupChat> createState() => _CreateGroupChatState();
}

class _CreateGroupChatState extends State<CreateGroupChat> {
  FocusNode _focusNodeNameGroup = FocusNode();
  FocusNode _focusNodeSearch = FocusNode();
  //RxBool _hasFocus = false.obs;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GroupChatController _groupChatController = Get.put(GroupChatController());
  final ChatController _chatController = Get.put(ChatController());
   List<User> allUsers = [];
  final Dbcontroller dbcontroller = Get.put(Dbcontroller());
  final ValueNotifier<bool> _hasFocus = ValueNotifier(false);
  final ValueNotifier<bool> _showError = ValueNotifier(false);
  RxBool _typeAbcSeach = true.obs;
  

  @override
void initState() {
  super.initState();
  allUsers = dbcontroller.allUsers;
  _focusNodeNameGroup.addListener(() {
    _hasFocus.value = _focusNodeNameGroup.hasFocus;
     
    if (!_focusNodeNameGroup.hasFocus && _groupNameController.text.trim().isEmpty) {
      _showError.value = true;
    } else {
      _showError.value = false;
    }
  });
}


  

  String? _groupAvatar;
  File? _groupAvatarFile;
  List<User> selectedUsers = [];

  void _pickGroupAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _groupAvatarFile = File(picked.path);
      final url = await _groupChatController.convertStorage(picked.path);
      setState(() {
        _groupAvatar = url;
        
      });
    }

  }
  void _showAvatarPickerSheet() {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Cập nhật hình đại diện", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.white)),
            SizedBox(height: 5),
            Divider(
              height: 1,
              thickness: 0.5,
              indent: 15,
              endIndent: 15,
              color: Colors.blue,
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Chụp ảnh mới", style: Theme.of(context).textTheme.labelMedium!,),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) {
                  final url = await _groupChatController.convertStorage(picked.path);
                  setState(() {
                    _groupAvatar = url;
                    _groupAvatarFile = File(picked.path);
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Chọn ảnh từ điện thoại", style: Theme.of(context).textTheme.labelMedium!,),
              onTap: () async {
                Navigator.pop(context);
                _pickGroupAvatar();
              },
            ),
          ],
        ),
      );
    },
  );
}
 


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
    final filteredUsers = allUsers.where((user) {
      final query = _searchController.text.toLowerCase();
      final name = user.name!.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(_groupNameController.text == "" ? "Nhóm mới" : _groupNameController.text, style: Theme.of(context).textTheme.labelSmall!.copyWith(
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
          // Tên nhóm + avatar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showAvatarPickerSheet,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: _groupAvatar != null ? FileImage(_groupAvatarFile!) : null,
                    backgroundColor: Colors.grey.shade300,
                    child: _groupAvatar == null ? Icon(Icons.camera_alt, color: Colors.grey) : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: 
                    ValueListenableBuilder(
                    valueListenable: _hasFocus,
                    builder: (context, hasFocus, _) {
                      return ValueListenableBuilder(
                        valueListenable: _showError,
                        builder: (context, showError, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                focusNode: _focusNodeNameGroup,
                                controller: _groupNameController,
                                cursorColor: Colors.blue,
                                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                onChanged: (value) {
                                  if (value.trim().isNotEmpty) {
                                    _showError.value = false;
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: !hasFocus ? "Đặt tên nhóm" : null,
                                  labelText: hasFocus ? "Tên nhóm" : null,
                                  errorText: showError ? "⚠ Vui lòng đặt tên nhóm" : null,
                                  errorStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                                    fontSize: 14,
                                    color: Colors.orange[400]
                                  ),
                                  labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  hintStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  suffixIcon: hasFocus
                                      ? IconButton(
                                          onPressed: () {
                                            _focusNodeNameGroup.unfocus();
                                          },
                                          icon: Icon(Icons.check, color: Colors.blue),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  
                )
              ],
            ),
          ),

          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            child: ListView.separated(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  leading: user.profileImage != null
                      ? Avatarprofile(radius: 20, width: 1, ImgaeUrl: user.profileImage,)
                      : CircleAvatar(child: Text(user.name![0])),
                  title: Text(user.name!, style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w600),),
                  subtitle: FutureBuilder(future: _chatController.getRoomByUserId(user.id!), builder: (context, snapshot) {
                  //   if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return ElevatedButton.icon(
                  //     onPressed: null,
                  //     icon: const SizedBox(
                  //       width: 16,
                  //       height: 16,
                  //       child: CircularProgressIndicator(strokeWidth: 2),
                  //     ),
                  //     label: const Text("Đang tải..."),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.grey.shade300,
                  //       foregroundColor: Colors.black,
                  //     ),
                  //   );
                  // }
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    final chatRoom = snapshot.data;
                    return Text( _chatController.getFormattedDate(chatRoom!.lastMessageTimestamp!),style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w300, fontSize: 14), );
                  },),

                   
                  trailing: _isSelected(user)
                      ? Icon(Icons.check_circle, color: Colors.blue)
                      : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                  onTap: () => _toggleUser(user),
                );
              }, separatorBuilder: (context, index) { 
                return Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.blue,
                    indent: 20,
                    endIndent: 20,
                );
               },
            ),
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
                                // CircleAvatar(
                                //   backgroundImage: user.profileImage != null
                                //       ? NetworkImage(user.profileImage!)
                                //       : null,
                                //   child: user.avatarUrl == null ? Text(user.name[0].toUpperCase()) : null,
                                //   radius: 25,
                                // ),
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
                      if (selectedUsers.length < 2) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning, color: Colors.orange),
                                  SizedBox(width: 18),
                                  Text("Cảnh báo",style:  Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: Colors.white,
                                    fontSize: 20
                                  )),
                                ],
                              ),
                              content: Text("Cần chọn ít nhất 3 thành viên để tạo nhóm", style: Theme.of(context).textTheme.labelMedium!,),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  
                                  child: Text("Đóng" ,style: Theme.of(context).textTheme.labelMedium!,),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (_groupNameController.value.text == ""){
                         _focusNodeNameGroup.requestFocus();
                      } else {
                        _groupChatController.createGroup(name: _groupNameController.value.text, members: selectedUsers, profileUrl: _groupAvatar);
                        Future.delayed(Duration(milliseconds: 300));
                        Get.to(Search());
                      }
                      },
                    shape: CircleBorder(),
                    mini: true,
                    backgroundColor: selectedUsers.length <2 ? Colors.blue[200] : Colors.blue,
                    child: Icon(Icons.arrow_forward, color: selectedUsers.length <3 ? null:  Colors.white,),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
