import 'dart:io' show Platform;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/providers/auth_provider.dart';
import 'package:odrive_restaurant/views/auth_screens/onboarding/role_selection_screen.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = true;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.offAll(() => RoleSelectionScreen())),
      ),
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
                child: Column(
              children: [
                Image.asset(
                  appLogo,
                  width: 200,
                  height: 200,
                ),
                Form(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        // Champ pour l email
                        _buildEmailField(context, emailController),
                        // Champ pour le mot de passe
                        _buildPasswordField(
                            context, passwordController, _isPasswordVisible,
                            (value) {
                          setState(() {
                            _isPasswordVisible = value;
                          });
                        }),
                        // Bouton de connexion
                        _buildLoginButton(
                            context, emailController, passwordController),
                        _buildLoginButton2(
                            context, emailController, passwordController),
                        // Autres éléments (boutons, liens, etc.)
                        // _buildOtherOptions(context),
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ),
          // Consumer<AuthProvider>(
          //   builder: (context, authProvider, child) {
          //     return authProvider.loading ? LoadingWidget() : Container();
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildEmailField(
      BuildContext context, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        boldText(text: "Email", color: fontGrey, size: 16.0),
        8.heightBox,
        customTextField(
          hint: "Email",
          controller: controller,
          obscureText: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "erreur";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      BuildContext context,
      TextEditingController controller,
      bool isVisible,
      Function(bool) onVisibilityChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        boldText(
            text: AppLocalizations.of(context)!.password,
            color: fontGrey,
            size: 16.0),
        8.heightBox,
        customTextField(
          hint: AppLocalizations.of(context)!.passwordHint,
          controller: controller,
          obscureText: isVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.passwordError;
            }
            return null;
          },
          suffixIcon: IconButton(
            onPressed: () {
              onVisibilityChanged(!isVisible);
            },
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: blackColor,
              size: 24,
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: normalText(
              text: AppLocalizations.of(context)!.forgetPassword,
              color: appColor,
              size: 16.0),
        ),
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return authProvider.error
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      authProvider.errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  )
                : SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) {
    final provider = Provider.of<AuthProvider>(context, listen: false);

    return Column(
      children: [
        25.heightBox,
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return customButton(
              color: authProvider.loading ? grey : appColor,
              title: AppLocalizations.of(context)!.managerLogin,
              isLoading: authProvider.loading,
              onPress: () {
                if (!emailController.text.isEmpty &&
                    !passwordController.text.isEmpty) {
                  provider
                      .loginUser(emailController.text, passwordController.text)
                      .then((_) {
                    if (!provider.error) {
                      Get.offAll(() => HomeScreen(),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 500));
                    }
                  });
                }
              },
              context: context,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton2(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) {
    final provider = Provider.of<AuthProvider>(context, listen: false);

    return Column(
      children: [
        25.heightBox,
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return customButton2(
              color: authProvider.loading ? grey : white,
              title: AppLocalizations.of(context)!.ownerLogin,
              isLoading: authProvider.loading,
              onPress: () {
                if (!emailController.text.isEmpty &&
                    !passwordController.text.isEmpty) {
                  provider
                      .loginUser(emailController.text, passwordController.text)
                      .then((_) {
                    if (!provider.error) {
                      Get.offAll(() => HomeScreen(),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 500));
                    }
                  });
                }
              },
              context: context,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOtherOptions(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.33,
                  height: 1,
                  color: fontGrey.withOpacity(0.3)),
              5.widthBox,
              Text(AppLocalizations.of(context)!.or),
              5.widthBox,
              Container(
                  width: MediaQuery.of(context).size.width * 0.33,
                  height: 1,
                  color: fontGrey.withOpacity(0.3)),
            ],
          ),
        ),
        if (Platform.isAndroid)
          customButton(
            color: blue,
            title: AppLocalizations.of(context)!.googleSignIn,
            onPress: () {},
            context: context,
            imagePath: googleLogo,
          ),
        20.heightBox,
        if (Platform.isIOS)
          customButton(
            color: blackColor,
            title: AppLocalizations.of(context)!.appleSignIn,
            onPress: () {},
            imagePath: appleLogo,
            context: context,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            normalText(
                text: AppLocalizations.of(context)!.haveAccount,
                color: fontGrey),
            TextButton(
              onPressed: () {
                Get.to(() => const SignUpScreen(),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 500));
              },
              child: normalText(
                  text: AppLocalizations.of(context)!.signUp, color: appColor),
            )
          ],
        ),
      ],
    );
  }
}
