import 'package:flutter/material.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/Strings.dart';
import 'package:flutter_svg/svg.dart';

class Welcomeheadpage extends StatelessWidget {
  const Welcomeheadpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(AssetImages.appIconSVG, width: 128, height: 128),
        const SizedBox(height: 12),
        Text(WelcomeString.appName, style: Theme.of(context).textTheme.headlineLarge),
      ],
    );
  }
}
