import 'package:flutter/material.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/Strings.dart';
class Welcomebodypage extends StatelessWidget {
  const Welcomebodypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Image.asset(AssetImages.girlImg, width: 94, height: 94),
        //     const SizedBox(width: 8),
        //     Image.asset(AssetImages.boyImg, width: 94, height: 94),
        //   ],
        // ),
        LottieAnimation(size: Size(224, 224), type: "welcome"),
        //const SizedBox(height: 24),
        Text("Now You Are", style: Theme.of(context).textTheme.headlineMedium),
        Text("CONNECTED", style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 16),
        Text(
          WelcomeString.dicription,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
