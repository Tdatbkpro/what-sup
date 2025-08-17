import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatefulWidget {
  
  const LottieAnimation({Key? key, required this.size, required this.type}) : super(key: key);
  final Size size;
  final String type;

  @override
  State<LottieAnimation> createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<LottieAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Lottie.asset(
        'assets/${widget.type}.json',
        controller: controller,
        onLoaded: (composition) {
          controller
            ..duration = composition.duration
            ..forward();
          debugPrint("Lottie Duration: ${composition.duration}");
        },
        height: widget.size.height,
        width: widget.size.width

      ),
    );
  }
}