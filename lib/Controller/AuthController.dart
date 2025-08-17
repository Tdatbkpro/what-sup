  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart' hide User;
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:get/get.dart';
  import 'package:google_sign_in/google_sign_in.dart';
  import 'package:whats_up/Model/User.dart';

  class Authcontroller extends GetxController {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    final RxBool isLoading = false.obs;
    final RxBool successSignIn = true.obs;

    String signInMessageError = '';
    String signUpMessageError = '';

    Future<void> signIn(String email, String password) async {
      isLoading.value = true;
      signInMessageError = '';
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = userCredential.user?.uid;
        if (uid != null) {
          await db.collection("user").doc(uid).update({
            'lastOnlineStatus': DateTime.now().toIso8601String(),
            'status': 'online',
          });
        }

        successSignIn.value = true;
        showSuccessSnackbar('🎉 Đăng nhập thành công!');
        Get.offAllNamed("/homePath");
      } on FirebaseAuthException catch (e) {
        successSignIn.value = false;
        switch (e.code) {
          case 'invalid-email':
            signInMessageError = '❌ Email không đúng định dạng.';
            break;
          case 'user-disabled':
            signInMessageError = '❌ Tài khoản đã bị vô hiệu hóa.';
            break;
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            signInMessageError = '❌ Email hoặc mật khẩu không chính xác.';
            break;
          case 'too-many-requests':
            signInMessageError = '❌ Đăng nhập thất bại quá nhiều lần. Vui lòng thử lại sau.';
            break;
          case 'operation-not-allowed':
            signInMessageError = '❌ Phương thức đăng nhập chưa được bật.';
            break;
          case 'network-request-failed':
            signInMessageError = '❌ Lỗi kết nối mạng. Vui lòng kiểm tra Internet.';
            break;
          case 'internal-error':
            signInMessageError = '❌ Lỗi hệ thống. Vui lòng thử lại.';
            break;
          case 'missing-email':
            signInMessageError = '❌ Bạn chưa nhập email.';
            break;
          case 'missing-password':
            signInMessageError = '❌ Bạn chưa nhập mật khẩu.';
            break;
          default:
            signInMessageError = '❌ Lỗi không xác định: ${e.message}';
        }
        showErrorSnackbar(signInMessageError);
      } catch (e) {
        signInMessageError = '❌ Lỗi không xác định: $e';
        showErrorSnackbar(signInMessageError);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> signUp(String email, String password, String name) async {
      isLoading.value = true;
      signUpMessageError = '';
      try {
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = userCredential.user;
        if (user != null) {
          await initUser(email, name);
        }
        showSuccessSnackbar('🎉 Đăng ký tài khoản thành công!');
        Get.offAllNamed("/authPath");
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'email-already-in-use':
            signUpMessageError = '❌ Email đã được sử dụng.';
            break;
          case 'invalid-email':
            signUpMessageError = '❌ Email không hợp lệ.';
            break;
          case 'operation-not-allowed':
            signUpMessageError = '❌ Tính năng đăng ký đang bị vô hiệu hóa.';
            break;
          case 'weak-password':
            signUpMessageError = '❌ Mật khẩu quá yếu.';
            break;
          case 'network-request-failed':
            signUpMessageError = '❌ Lỗi mạng. Vui lòng kiểm tra kết nối.';
            break;
          case 'internal-error':
            signUpMessageError = '❌ Lỗi hệ thống.';
            break;
          case 'missing-email':
            signUpMessageError = '❌ Bạn chưa nhập email.';
            break;
          case 'missing-password':
            signUpMessageError = '❌ Bạn chưa nhập mật khẩu.';
            break;
          default:
            signUpMessageError = '❌ Lỗi không xác định: ${e.message}';
        }
        showErrorSnackbar(signUpMessageError);
      } catch (e) {
        signUpMessageError = '❌ Lỗi không xác định: $e';
        showErrorSnackbar(signUpMessageError);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> signOut() async {
      try {
        final uid = auth.currentUser?.uid;
        if (uid != null) {
          await db.collection("user").doc(uid).update({
            'lastOnlineStatus': DateTime.now().toIso8601String(),
            'status': 'offline',
          });
        }

        await auth.signOut();
        showSuccessSnackbar('✅ Đăng xuất thành công!');
      } catch (e) {
        showErrorSnackbar('❌ Đăng xuất thất bại: $e');
      }
      Get.offAllNamed('/welcomePath');
    }

    Future<void> initUser(String email, String name) async {
      try {
        final currentUser = auth.currentUser;
        if (currentUser == null) throw Exception('Người dùng chưa đăng nhập');

        final uid = currentUser.uid;
        var newUser = User(
          id: uid,
          email: email,
          name: name,
          phoneNumber: currentUser.phoneNumber,
          profileImage: currentUser.photoURL,
          createdAt: DateTime.now(),
        );
        await db.collection("user").doc(uid).set(newUser.toJson());
      } catch (e) {
        print('❌ Lỗi khi tạo user mới: $e');
      }
    }

    void showErrorSnackbar(String message) {
      Get.snackbar(
        'Lỗi',
        message,
        backgroundColor: Colors.redAccent.shade200,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 14,
        isDismissible: true,
      );
    }

    void showSuccessSnackbar(String message) {
      Get.snackbar(
        'Thành công',
        message,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 14,
        isDismissible: true,
      );
    }

    String getUserStatusText(DateTime? lastOnline) {
      if (lastOnline == null) return "Không rõ";
      final now = DateTime.now();
      final diff = now.difference(lastOnline);

      if (diff.inSeconds <= 60) return "Đang hoạt động";
      if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
      if (diff.inHours < 24) return "${diff.inHours} giờ trước";
      if (diff.inDays < 30) return "${diff.inDays} ngày trước";
      return "${DateFormat('dd/MM/yyyy').format(lastOnline)}";
    }
    Future<void> signInWithGoogle() async {
  isLoading.value = true;
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      isLoading.value = false;
      return; // Người dùng huỷ đăng nhập
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await googleSignIn.signOut();
    final UserCredential userCredential = await auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      final docSnapshot = await db.collection("user").doc(user.uid).get();

      if (!docSnapshot.exists) {
        final newUser = User(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          phoneNumber: user.phoneNumber,
          profileImage: user.photoURL,
          createdAt: DateTime.now(),
        );
        await db.collection("user").doc(user.uid).set(newUser.toJson());
      }

      await db.collection("user").doc(user.uid).update({
        'lastOnlineStatus': DateTime.now().toIso8601String(),
        'status': 'online',
      });

      showSuccessSnackbar('🎉 Đăng nhập bằng Google thành công!');
      Get.offAllNamed("/homePath");
    }
  } on FirebaseAuthException catch (e) {
    showErrorSnackbar('❌ Lỗi xác thực Google: ${e.message}');
  } catch (e) {
    showErrorSnackbar('❌ Đăng nhập Google thất bại: $e');
  } finally {
    isLoading.value = false;
  }
}


  }
