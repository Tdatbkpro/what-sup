import 'package:flutter/material.dart';
import 'package:whats_up/Pages/Auth/Widgets/AuthBodyPage.dart';
import 'package:whats_up/Pages/Welcome/Widgets/WelcomeHeadPage.dart';


class Authpage extends StatefulWidget {
  const Authpage({super.key});

  @override
  State<Authpage> createState() => _AuthpageState();
}

class _AuthpageState extends State<Authpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(     // <-- Dùng SingleChildScrollView ở đây
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Welcomeheadpage(),
                SizedBox(height: 20),
                Authbodypage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

