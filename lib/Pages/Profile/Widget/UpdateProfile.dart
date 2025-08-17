import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/UserAvarta.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Controller/ImagePickerController.dart';
import 'package:whats_up/Controller/ProfileController.dart';


class Updateprofile extends StatefulWidget {
  const Updateprofile({super.key});

  @override
  State<Updateprofile> createState() => _UpdateprofileState();
}

class _UpdateprofileState extends State<Updateprofile> {
  FocusNode _nodeName = FocusNode();
  FocusNode _nodePhone = FocusNode();
  FocusNode _nodeEmail = FocusNode();
  FocusNode _nodeBio = FocusNode();

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  ImagePickerController imagePickerController = Get.put(ImagePickerController());
  Profilecontroller profilecontroller = Get.put(Profilecontroller());

  bool _isNameFocused = false;
  bool _isPhoneFocused = false;
  bool _isBioFocused = false;
  RxBool _isEmailFocused = false.obs;

  RxBool _isEdit = false.obs;
  RxString _imagePath = "".obs;

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nodeName.addListener(() {
      setState(() {
        _isNameFocused = _nodeName.hasFocus;
      });
    });
    _nodePhone.addListener(() {
      setState(() {
      _isPhoneFocused = _nodePhone.hasFocus;
      });
    });
    _nodeEmail.addListener(() {
      setState(() {
      _isEmailFocused.value = _nodeEmail.hasFocus;
      });
    });
    _nodeBio.addListener(() {
      setState(() {
      _isBioFocused = _nodeBio.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Profilecontroller profilecontroller = Get.put(Profilecontroller());
    Authcontroller authcontroller = Get.put(Authcontroller());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cập nhật hồ sơ"),
        centerTitle: true,
        actions: [
         Padding(padding: const EdgeInsets.only(right: 10),
         child:  IconButton(onPressed: () { authcontroller.signOut();}, icon: Icon(Icons.logout_rounded, size: 30,)),)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
          children: [
            // Avatar với icon chỉnh sửa
            Center(
              child: Stack(
                children: [
                  Obx(() {
                          if (_imagePath.value.isNotEmpty) {
                            // Ảnh mới được chọn
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(File(_imagePath.value)),
                            );
                          }

                          final imageUrl = profilecontroller.currentUser.value.profileImage;

                          if (imageUrl == null || imageUrl.isEmpty) {
                            return const CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage(AssetImages.manImg),
                            );
                          }

                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              radius: 50,
                              backgroundImage: imageProvider,
                            ),
                            placeholder: (context, url) => const CircleAvatar(
                              radius: 50,
                              child: LottieAnimation(size: Size(150,150), type: "circle_loading"),
                            ),
                            errorWidget: (context, url, error) => const CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage(AssetImages.manImg),
                            ),
                          );
                        }),


                 if (_isEdit.value) ...[
                  Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () async {
                      if (!imagePickerController.isPicking.value) {
                        final path = await imagePickerController.pickImageWithChoice(context);
                        if (path.isNotEmpty) {
                          _imagePath.value = path;
                        }
                      }
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ),
                 ]
                ],
              ),
            ),
            const SizedBox(height: 20),

            // TextField họ tên
            Obx(
              () => 
              TextField(
                style: Theme.of(context).textTheme.labelMedium,
                controller: nameController,
                focusNode: _nodeName,
                
                enabled: _isEdit.value,
                decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  labelText: _isNameFocused ? "Họ tên" : null,
                  hintText: nameController.text.isEmpty ? profilecontroller.currentUser.value.name ?? "Name" : nameController.text,
                  //floatingLabelBehavior: FloatingLabelBehavior.auto,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TextField email
            Obx(() => 
            AutoSizeTextField(
              focusNode: _nodeEmail,
              controller: emailController,
              enabled: false,
              minFontSize: 10, // Giới hạn nhỏ nhất
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.bodySmall,
                labelText:  _isEmailFocused.value ? "Email" : null,
                hintText:  profilecontroller.currentUser.value.email,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                contentPadding: EdgeInsets.only(left: 10, right: 20),
              ),
            ),
            ),
            const SizedBox(height: 16),

            // TextField số điện thoại
            Obx(() => 
            TextField(
              focusNode: _nodePhone,
              style: Theme.of(context).textTheme.labelMedium,
              controller: phoneController,
              enabled: _isEdit.value,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.bodySmall,
                labelText: _isPhoneFocused ? "Phone": null,
                hintText: phoneController.text.isEmpty ? profilecontroller.currentUser.value.phoneNumber : phoneController.text,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),),
             const SizedBox(height: 16),

            // TextField số điện thoại
            Obx(() => 
            TextField(
              focusNode: _nodeBio,
              style: Theme.of(context).textTheme.labelMedium,
              controller: bioController,
              enabled: _isEdit.value,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.bodySmall,
                labelText: _isBioFocused ? "Bio": null,
                hintText: bioController.text.isEmpty ? profilecontroller.currentUser.value.bio : bioController.text,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
            ),),
            const SizedBox(height: 30),

            // Nút cập nhật
            Obx(() => 
            SizedBox(
              //width: double.infinity,
              child: ElevatedButton.icon(
              icon: _isEdit.value
                  ? const Icon(Icons.save, color: Colors.white)
                  : profilecontroller.isSaving.value == false
                  ? const Icon(Icons.edit, color: Colors.white)
                  : const SizedBox(
                      width: 18,
                      height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  label: Text(
                    _isEdit.value
                        ? "Lưu"
                        : (profilecontroller.isSaving.value == false ? "Chỉnh sửa" : "Đang lưu..."),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEdit.value ? Colors.green : Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _isEdit.value = !_isEdit.value;
                    if (_isEdit.value != true) {
                      profilecontroller.updatePRofile(
                        _imagePath.value,
                        nameController.text,
                        phoneController.text,
                        bioController.text,
                      );
                      _imagePath.value = "";
                    }
                  },
                ),

            ),)
          ],
        ),
        )
      ),
    );
  }
}
