import 'dart:io' show Platform;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:odrive_restaurant/common/component/loading.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/config/lang.dart';
import 'package:odrive_restaurant/common/const/const.dart';

Lang strings = Lang();

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var numberController = TextEditingController();
  var passwordController = TextEditingController();
  bool _isPasswordVisible = true;
  final _formKey = GlobalKey<FormState>();
  bool _error = false;
  bool _loading = false;

  String indicatif = "+225";

  @override
  Widget build(BuildContext context) {
    print(strings.get(10));
    print("strings----------------------");
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BgContainer(),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 40.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          boldText(
                            text: AppLocalizations.of(context)!.phone,
                            color: fontGrey,
                            size: 16.0,
                          ),
                          8.heightBox,
                          phoneContainer(
                              hint: AppLocalizations.of(context)!.phoneHint,
                              controller: numberController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .phoneError;
                                }
                                return null;
                              },
                              onChange: (value) {
                                setState(() {
                                  print(value.toString());
                                  indicatif = value.toString();
                                });
                              })
                          /* customTextField(
                            hint: AppLocalizations.of(context)!.phoneHint,
                            controller: numberController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.phoneError;
                              }
                              return null;
                            },
                          ), */
                        ],
                      ),
                      8.heightBox,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          boldText(
                              text: AppLocalizations.of(context)!.password,
                              color: fontGrey,
                              size: 16.0),
                          8.heightBox,
                          customTextField(
                            hint: AppLocalizations.of(context)!.passwordHint,
                            controller: passwordController,
                            obscureText: _isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .passwordError;
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
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: blackColor,
                                size: 24,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: normalText(
                                text: AppLocalizations.of(context)!
                                    .forgetPassword,
                                color: appColor,
                                size: 16.0),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          25.heightBox,
                          customButton(
                              color: numberController.text.isEmpty ||
                                      passwordController.text.isEmpty
                                  ? grey
                                  : appColor,
                              title: AppLocalizations.of(context)!.signIn,
                              onPress: () async {
                                // if (_formKey.currentState!.validate()) {
                                //   // Form is valid, perform sign-up action here
                                //   // Access form field values using controller instances
                                //   // For example: nameController.text, emailController.text, etc.
                                // }
                                if (!numberController.text.isEmpty &&
                                    !passwordController.text.isEmpty) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  dynamic response = await login(
                                      indicatif + numberController.text,
                                      passwordController.text);

                                  if (response["error"] == 1) {
                                    setState(() {
                                      _error = true;
                                      _loading = false;
                                    });
                                  }
                                  if (response["error"] == 0) {
                                    setState(() {
                                      _error = false;
                                      _loading = false;
                                    });
                                    Get.offAll(() => HomeScreen(),
                                        transition: Transition.downToUp,
                                        duration:
                                            const Duration(milliseconds: 500));
                                  }
                                }
                              },
                              context: context),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.33,
                                  height: 1,
                                  color: fontGrey.withOpacity(0.3),
                                ),
                                5.widthBox,
                                Text(AppLocalizations.of(context)!.or),
                                5.widthBox,
                                Container(
                                  color: fontGrey.withOpacity(0.3),
                                  width:
                                      MediaQuery.of(context).size.width * 0.33,
                                  height: 1,
                                ),
                              ],
                            ),
                          ),
                          if (Platform.isAndroid)
                            customButton(
                                color: blue,
                                title:
                                    AppLocalizations.of(context)!.googleSignIn,
                                onPress: () {},
                                context: context,
                                imagePath: googleLogo),
                          /* 20.heightBox,
                          customButton(
                            color: darkBlue,
                            title: 'Continue with facebook',
                            imagePath: fbLogo,
                            onPress: () {},
                            context: context,
                          ), */
                          20.heightBox,
                          if (Platform.isIOS)
                            customButton(
                                color: blackColor,
                                title:
                                    AppLocalizations.of(context)!.appleSignIn,
                                onPress: () {},
                                imagePath: appleLogo,
                                context: context),
                          20.heightBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              normalText(
                                  text:
                                      AppLocalizations.of(context)!.haveAccount,
                                  color: fontGrey),
                              TextButton(
                                  onPressed: () {
                                    Get.to(() => const SignUpScreen(),
                                        transition: Transition.downToUp,
                                        duration:
                                            const Duration(milliseconds: 500));
                                  },
                                  child: normalText(
                                    text: AppLocalizations.of(context)!.signUp,
                                    color: appColor,
                                  ))
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          _loading ? LoadingWidget() : Container(),
        ],
      ),
    );
  }
}
