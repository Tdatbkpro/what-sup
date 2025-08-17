import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/instance_manager.dart';
import 'package:get/utils.dart';
import 'package:whats_up/Animation/delele_lottie.dart';
import 'package:whats_up/Config/Images.dart';
import 'package:whats_up/Config/Strings.dart';
import 'package:whats_up/Controller/SplaceController.dart';


class Splacepage extends StatefulWidget {
  const Splacepage({super.key});

  @override
  State<Splacepage> createState() => _SplacepageState();
}

class _SplacepageState extends State<Splacepage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeIn = Tween<double>(begin: 0, end: 2.5).animate(_controller);
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Splacecontroller splacecontroller = Get.put(Splacecontroller());
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              SvgPicture.asset(AssetImages.appIconSVG,
              width: 80,
              height: 80,
              ),
              const SizedBox(height: 10,),
              Text(WelcomeString.appName,
              style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10,),
              LottieAnimation(size: Size(150, 150), type: "splace")
          ],
        ),
        ),
      ),
    );
  }
}
