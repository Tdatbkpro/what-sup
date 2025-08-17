import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/Strings.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Controller/CallController.dart';
import 'package:whats_up/Controller/ChatController.dart';
import 'package:whats_up/Controller/ProfileController.dart';
import 'package:whats_up/Pages/HomePage/Widget/ChatList.dart';
import 'package:whats_up/Pages/HomePage/Widget/GroupChatList.dart';
import 'package:whats_up/Pages/HomePage/Widget/MyTabBar.dart';
import 'package:whats_up/Pages/Notifi/NotificationPage.dart';
import 'package:whats_up/Pages/Profile/ProfilePage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin, WidgetsBindingObserver  {
  late TabController _tabController;
  Authcontroller authcontroller = Get.put(Authcontroller());
  final ChatController chatController = Get.put(ChatController());
  CallController callController = Get.put(CallController());
  @override
 void initState() {
    super.initState();
    //authcontroller.updateUserStatusOnline();
     chatController.markAsReceived(FirebaseAuth.instance.currentUser!.uid);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
     WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Profilecontroller profilecontroller = Get.put(Profilecontroller());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed("contact");
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add_comment_rounded,

        ),
      ),
      appBar: AppBar(
        
        leadingWidth: 45,
        title: Text(WelcomeString.appName, style: Theme.of(context).textTheme.bodyMedium),
        // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: SvgPicture.asset(AssetImages.appIconSVG),
        ),
        toolbarHeight: 60,
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10),
             child: IconButton(icon: Icon(Icons.notification_important_sharp, size: 32), onPressed: () { 
              Get.to(NotificationScreen());
              },),
          ),
          Padding(padding: const EdgeInsets.only(right: 10),
             child: IconButton(icon: Icon(Icons.search_outlined, size: 32), onPressed: () { 
              Get.toNamed("contact");
              },),
          ),
          Padding(padding: const EdgeInsets.only(right: 10),
             child: IconButton(icon: Icon(Icons.info, size: 28), onPressed: () { 
              Get.toNamed("/updateProfilePath");
              },),
          )
        ],
       bottom: MyTabBar(_tabController, context),
       
      ),
      body: TabBarView(
        controller: _tabController,
        children:[
          Chatlist(),
          Groupchatlist(),
          Chatlist()
        ],
      ),
    );
  }
}
