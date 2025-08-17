import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatefulWidget {
  const LottieAnimation({
    super.key,
    required this.size,
    required this.type,
    this.onCompleted,
  });

  final Size size;
  final String type;
  final VoidCallback? onCompleted;

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

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint("🎉 Animation completed");
        if (widget.onCompleted != null) {
          widget.onCompleted!();
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Lottie.asset(
    'assets/${widget.type}.json',
    controller: controller,
    onLoaded: (composition) {
      controller.duration = composition.duration;

      if (widget.type == "like" || widget.type == "welcome" || widget.type == "submit" ) {
        controller.reverse(from: 1.0); 
        controller.repeat(reverse: true);// reverse từ cuối về đầu

        controller.addStatusListener((status) {
          if (status == AnimationStatus.dismissed) {
            controller.forward(); // Khi reverse xong thì chạy lại từ đầu
          }
        });
      } else {
        controller.forward(); // Bình thường
      }

      debugPrint("⏱️ Lottie Duration: ${composition.duration}");
    },
    height: widget.size.height,
    width: widget.size.width,
  );
}
    }