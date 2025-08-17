import 'package:get/get.dart';
import 'package:whats_up/Pages/Auth/AuthPage.dart';
import 'package:whats_up/Pages/Chat/ChatPage.dart';
import 'package:whats_up/Pages/Contact/Search.dart';
import 'package:whats_up/Pages/HomePage/HomePage.dart';
import 'package:whats_up/Pages/Profile/ProfilePage.dart';
import 'package:whats_up/Pages/Profile/Widget/UpdateProfile.dart';
import 'package:whats_up/Pages/Welcome/WelcomePage.dart';
var pagePath = [
    GetPage(
      name: "/authPath"
    , page: () => Authpage(),
    transition: Transition.leftToRight,
    transitionDuration: Duration(milliseconds: 600)
    ),
    GetPage(
      name: "/homePath"
    , page: () => Homepage(),
    transition: Transition.fadeIn,
    transitionDuration: Duration(milliseconds: 600)
    ),
    // GetPage(
    //   name: "/chatPath"
    // , page: () => Chatpage(),
    // transition: Transition.rightToLeft,
    // transitionDuration: Duration(milliseconds: 600)
    // ),
    GetPage(
      name: "/welcomePath"
    , page: () => Welcomepage(),
    transition: Transition.fadeIn,
    transitionDuration: Duration(milliseconds: 300)
    ),
    // GetPage(
    //   name: "/profilePath"
    // , page: () => Profilepage(),
    // transition: Transition.downToUp,
    // transitionDuration: Duration(milliseconds: 300)
    // ),
     GetPage(
      name: "/updateProfilePath"
    , page: () => Updateprofile(),
    transition: Transition.native,
    transitionDuration: Duration(milliseconds: 300)
    ),
    GetPage(
      name: "/contact"
    , page: () => Search(),
    transition: Transition.upToDown,
    transitionDuration: Duration(milliseconds: 200)
    ),
];