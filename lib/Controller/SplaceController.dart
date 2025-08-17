import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class Splacecontroller extends GetxController{
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    splaceController();
  }

  Future<void> splaceController() async {
    await Future.delayed(
      Duration(seconds: 3),
    );
    if (auth.currentUser == null) {
      Get.offAllNamed("/welcomePath");
    } else {
      Get.offAllNamed("/homePath");
      //print(auth.currentUser!.email);
    }
  }
}