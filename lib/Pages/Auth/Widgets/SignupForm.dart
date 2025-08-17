import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:whats_up/Controller/AuthController.dart';
import 'package:whats_up/Widget/PrimaryButton.dart';
import 'package:sign_in_button/sign_in_button.dart';

class Signupform extends StatefulWidget {
  const Signupform({super.key});

  @override
  State<Signupform> createState() => _SignupformState();
}

class _SignupformState extends State<Signupform> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final Authcontroller authcontroller = Get.put(Authcontroller());
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    TextInput.finishAutofillContext();
    final email = emailController.text;
    final password = passwordController.text;
    final username = nameController.text;

    authcontroller.signUp(email, password, username);
    print("Tapped Login with email: $email, password: $password , username: $username");

    // TODO: Xử lý đăng nhập ở đây (gọi API, kiểm tra, chuyển màn hình...)
  }
  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          TextField(
            controller: nameController,
            style: Theme.of(context).textTheme.labelSmall,
            autofillHints: const [AutofillHints.nickname],
            decoration: InputDecoration(
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
              hintText: "Username",
              hintStyle: Theme.of(context).textTheme.labelMedium,
              hintTextDirection: TextDirection.ltr,
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: emailController,
            style: Theme.of(context).textTheme.labelSmall,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
              hintText: "Email",
              hintStyle: Theme.of(context).textTheme.labelMedium,
              hintTextDirection: TextDirection.ltr,
              prefixIcon: Icon(Icons.alternate_email_outlined),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: passwordController,
            style: Theme.of(context).textTheme.labelSmall,
            obscureText: true,
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
              prefixIcon: Icon(Icons.password_sharp),
            ),
          ),
          SizedBox(height: 40),
          

                Obx(() => 
                  authcontroller.isLoading.value ?
                   LottieAnimation(size: Size(40,40), type: "submit")
                : Primarybutton(btnName: "Signup", btnIcon: Icons.person_add,
                onTap: () {
                  _handleSignup();
                },
                ),
                ),
        ],
      ),
    );
  }
}
