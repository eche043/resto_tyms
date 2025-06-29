import 'package:odrive_restaurant/common/const/const.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var nameController = TextEditingController();
  var numberController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BgContainer(),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.04,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 40 + MediaQuery.of(context).padding.top,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Image.asset(
                          backIcon,
                          height: 24,
                          width: 24,
                        )),
                    12.widthBox,
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 40.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      boldText(
                        text: 'Full Name',
                        color: fontGrey,
                        size: 16.0,
                      ),
                      8.heightBox,
                      customTextField(
                        hint: 'Enter Full Name',
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      8.heightBox,
                      boldText(
                        text: 'Phone Number',
                        color: fontGrey,
                        size: 16.0,
                      ),
                      8.heightBox,
                      customTextField(
                        hint: 'Enter your phone Number',
                        controller: numberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      8.heightBox,
                      boldText(
                        text: 'Email',
                        color: fontGrey,
                        size: 16.0,
                      ),
                      8.heightBox,
                      customTextField(
                        hint: 'Enter Email Address',
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          } else if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      8.heightBox,
                      boldText(text: 'Password', color: fontGrey, size: 16.0),
                      8.heightBox,
                      customTextField(
                        hint: 'Enter password',
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: blackColor,
                            size: 24,
                          ),
                        ),
                      ),
                      8.heightBox,
                      boldText(
                          text: 'Confirm Password',
                          color: fontGrey,
                          size: 16.0),
                      8.heightBox,
                      customTextField(
                        hint: 'Confirm password',
                        controller: confirmPasswordController,
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: blackColor,
                            size: 24,
                          ),
                        ),
                      ),
                      12.heightBox,
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(children: [
                                TextSpan(
                                  text:
                                      "By clicking Create Account, You agree to the system's",
                                  style: TextStyle(
                                      color: fontGrey.withOpacity(0.7),
                                      fontWeight: FontWeight.w400),
                                ),
                                const TextSpan(
                                  text: " Terms & Policies",
                                  style: TextStyle(
                                      color: blackColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      25.heightBox,
                      Center(
                        child: customButton(
                          color: grey,
                          title: 'Sign up',
                          onPress: () {
                            Get.to(() => const OTPScreen(),
                                transition: Transition.downToUp,
                                duration: const Duration(milliseconds: 500));
                            // if (_formKey.currentState!.validate()) {
                            //   // Form is valid, perform sign-up action here
                            //   // Access form field values using controller instances
                            //   // For example: nameController.text, emailController.text, etc.
                            // }
                          },
                          context: context,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
