import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Pages/Welcome/Widgets/WelcomeBodyPage.dart';
import 'package:whats_up/Pages/Welcome/Widgets/WelcomeFooterPage.dart';
import 'package:whats_up/Pages/Welcome/Widgets/WelcomeHeadPage.dart';

class Welcomepage extends StatelessWidget {
  const Welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight, // Giữ đúng full chiều cao màn
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Welcomeheadpage(),
              Welcomebodypage(),
              Welcomefooterpage(),
            ],
          ),
        );
      },
    ),
  ),
);

  }
}
