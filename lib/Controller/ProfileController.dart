import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_up/Model/User.dart';
import 'package:http/http.dart' as http;

class Profilecontroller extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isSaving = false.obs;
  Rx<User> currentUser = User().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (auth.currentUser != null) {
      getUserProfileDetail();
    } else {
      print("⚠️ auth.currentUser is null!");
    }
  }

  Future<void> getUserProfileDetail() async {
    final doc = await db.collection("user").doc(auth.currentUser!.uid).get();
    final data = doc.data();
    if (data != null) {
      currentUser.value = User.fromJson(data);
      print(currentUser.value);
    } else {
      print("⚠️ Không tìm thấy dữ liệu người dùng trong Firestore.");
    }
  }

  Future<User> getUserById(String id) async {
    final doc = await db.collection("user").doc(id).get();
    if (doc.exists && doc.data() != null) {
    return User.fromJson(doc.data()!);
  } else {
    throw Exception("User not found");
  }
  }
  Future<void> updatePRofile(String? imagePath,
    String? name,
    String? phoneNumber,
    String? bio
) async {
  isSaving.value = true;
  if (name == null || name == "")
    name = currentUser.value.name!;
  if (phoneNumber == null || phoneNumber == "")
    phoneNumber = currentUser.value.phoneNumber;

  if (bio == null || bio == "")
    bio = currentUser.value.bio;
  String? imageUrl;

  // Nếu có ảnh mới thì upload
  if (imagePath != null && imagePath.isNotEmpty) {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/dod0lqxur/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = "What'sUp"
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      imageUrl = data['secure_url'];
    } else {
      print("❌ Upload ảnh thất bại");
    }
  }

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  // Dữ liệu cập nhật
  final updateData = <String, dynamic>{
    'name': name,
    'phoneNumber': phoneNumber,
    'bio': bio,
  };
  if (imageUrl != null) {
    updateData['profileImage'] = imageUrl;
  }

  await FirebaseFirestore.instance.collection('user').doc(uid).update(updateData);

  showSuccessSnackbar(currentUser.value.name!);

  // Tải lại dữ liệu user và gán vào currentUser
  await getUserProfileDetail();

  isSaving.value = false;
}

  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Cập nhật thành công, User : ',
      message,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 600),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeInOutBack,
    );
  }
}
