import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Pages/Contact/Widgets/ListTileContact.dart';
import 'package:whats_up/Widget/PrimaryButton.dart';

class Loginform extends StatefulWidget {
  const Loginform({super.key});

  @override
  State<Loginform> createState() => _LoginformState();
}

class _LoginformState extends State<Loginform> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Authcontroller authcontroller = Get.put(Authcontroller());
  RxBool showPassword = false.obs;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    TextInput.finishAutofillContext();
    final email = emailController.text;
    final password = passwordController.text;
    authcontroller.signIn(email, password);
    print("Tapped Login with email: $email, password: $password");
    // TODO: Xử lý đăng nhập ở đây (gọi API, kiểm tra, chuyển màn hình...)
  }
  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }
  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          TextField(
            controller: emailController,
            style: Theme.of(context).textTheme.labelSmall,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              
              hintText: "Email",
              hintStyle: Theme.of(context).textTheme.labelMedium,
              hintTextDirection: TextDirection.ltr,
              
              prefixIcon: Icon(Icons.alternate_email_outlined),
              focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
              border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueGrey),
                                  ),        
            ),
          ),
          SizedBox(height: 20),
          Obx(() => TextField(
              controller: passwordController,
              style: Theme.of(context).textTheme.labelSmall,
              obscureText: !showPassword.value, // Sử dụng biến reactive
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
                hintText: "Password",
                hintStyle: Theme.of(context).textTheme.labelMedium,
                hintTextDirection: TextDirection.ltr,
                prefixIcon: const Icon(Icons.password_sharp),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword.value ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: toggleShowPassword,
                ),
              ),
            )),

          SizedBox(height: 40),
          Obx(() => 
            authcontroller.isLoading.value ? LottieAnimation(size: Size(40,40), type: "submit") :
          Column(
          
            children: [
              Primarybutton(
                btnName: "Login",
                btnIcon: Icons.login_sharp,
                onTap: _handleLogin,

              ),
              SignInButton(Buttons.google, onPressed: () async {
                  await authcontroller.signInWithGoogle();
              },
              mini: false,
              elevation: 6,
  
              shape: RoundedRectangleBorder(
                 borderRadius: BorderRadiusGeometry.circular(12)
              ),
              text: "Đăng nhập bằng google",
              )
            ],
          ),
          )


        ],
      ),
    );
  }
}
