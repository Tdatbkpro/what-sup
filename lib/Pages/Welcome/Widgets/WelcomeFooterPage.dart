import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Pages/Chat/Voice/FlowShader.dart';

class Welcomefooterpage extends StatelessWidget {
  const Welcomefooterpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: SlideAction(
        onSubmit: () {
          Get.offAllNamed("/authPath");
        },
        
        //innerColor: Theme.of(context).colorScheme.secondaryContainer,
        outerColor: Theme.of(context).colorScheme.primaryContainer,
       //sliderButtonIcon:  LottieAnimation(size: Size(20, 20), type: "submit"),
        submittedIcon:  LottieAnimation(size: Size(40, 40), type: "submit"),
        animationDuration: const Duration(seconds: 2),

        elevation: 5,
        text: "Slide to connect",
        textStyle: Theme.of(context).textTheme.labelLarge,
        sliderButtonIconPadding: 15,
        child: Flowshader(child: Text("Slide to connect")),
        height: 65,
      ),
    );
  }
}
