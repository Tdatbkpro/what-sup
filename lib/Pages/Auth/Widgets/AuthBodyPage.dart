import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_up/Pages/Auth/Widgets/LoginForm.dart';
import 'package:whats_up/Pages/Auth/Widgets/SignupForm.dart';

class Authbodypage extends StatefulWidget {
  const Authbodypage({super.key});

  @override
  State<Authbodypage> createState() => _AuthbodypageState();
}

class _AuthbodypageState extends State<Authbodypage> {
  final RxBool isLogin = true.obs;

@override
Widget build(BuildContext context) {
  final heightBox = MediaQuery.sizeOf(context).height / 2;

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Obx(() => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 10,
              top: 10,
              end: 10,
              bottom: 25
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => isLogin.value = true,
                        child: Column(
                          children: [
                            Text(
                              "Login",
                              style: isLogin.value
                                  ? Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 20)
                                  : Theme.of(context).textTheme.labelSmall,
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isLogin.value ? heightBox / 4 : 0,
                              height: 3,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => isLogin.value = false,
                        child: Column(
                          children: [
                            Text(
                              "Sign Up",
                              style: !isLogin.value
                                  ? Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 20)
                                  : Theme.of(context).textTheme.labelSmall,
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: !isLogin.value ? heightBox / 4 : 0,
                              height: 3,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                isLogin.value
                    ? 
                    Container(
                      child:  Loginform(key: ValueKey("login"))
                    )
                    
                    : const Signupform(key: ValueKey("signup"),)
              ],
            ),
          ),
        ),
      )),
    ),
  );
}

}
