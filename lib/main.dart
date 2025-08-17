import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:whats_up/Config/CallConfigZego.dart';
import 'package:whats_up/Config/PagePath.dart';
import 'package:whats_up/Config/Themes.dart';
import 'package:whats_up/Controller/CallController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Pages/Chat/Voice/Globals.dart';
import 'package:whats_up/Pages/SplacePage/SplacePage.dart';
import 'package:whats_up/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await ZegoUIKit().init(
    appID: ZegoCallConfig.appId,
    appSign: ZegoCallConfig.appSign,
  );

  await Supabase.initialize(
  url: 'https://larmqpyrdspdszkvenln.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxhcm1xcHlyZHNwZHN6a3ZlbmxuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2NDQwNzIsImV4cCI6MjA2ODIyMDA3Mn0.kmV8iAcmOO_4rTxV4iqBbXLRSEsptWLTCUFoVzLt5ho',
  
);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateStatus("online");     // 🔹 Cập nhật ngay khi mở app
    _startHeartbeat();           // 🔹 Bắt đầu cập nhật định kỳ
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateLastOnline();
    });
  }

  void _updateStatus(String status) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(user.uid)
        .set({
          "status": status,
          "lastOnlineStatus": DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
  }
}


  void _updateLastOnline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection("user").doc(user.uid).update({
        "lastOnlineStatus": DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateStatus("online");   // 🔹 Quay lại app → online ngay
      _startHeartbeat();         // 🔹 Khởi động lại timer
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _updateStatus("offline");  // 🔹 Thoát hoặc chuyển nền → offline
      _heartbeatTimer?.cancel(); // 🔹 Dừng timer
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whats Up',
      getPages: pagePath,
      home: Splacepage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
    );
  }
}
