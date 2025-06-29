import '../../common/const/const.dart';
import 'signup_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Stack(children: [
        SizedBox(
          width: double.infinity,
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                // begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [blackColor, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(appLogo, fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Image.asset(appLogo)),
              20.heightBox,
              customButton(
                  color: appColor,
                  title: 'Sign In',
                  onPress: () {
                    Get.to(() => const SignInScreen(),
                        transition: Transition.rightToLeft);
                  },
                  context: context),
              30.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.33,
                    height: 1,
                    color: fontGrey.withOpacity(0.3),
                  ),
                  5.widthBox,
                  const Text('OR'),
                  5.widthBox,
                  Container(
                    color: fontGrey.withOpacity(0.3),
                    width: MediaQuery.of(context).size.width * 0.33,
                    height: 1,
                  ),
                ],
              ),
              30.heightBox,
              customButton(
                  color: blue,
                  title: 'Continue with google',
                  onPress: () {},
                  context: context,
                  imagePath: googleLogo),
              20.heightBox,
              customButton(
                color: darkBlue,
                title: 'Continue with facebook',
                imagePath: fbLogo,
                onPress: () {},
                context: context,
              ),
              20.heightBox,
              customButton(
                  color: blackColor,
                  title: 'Continue with Apple',
                  onPress: () {},
                  imagePath: appleLogo,
                  context: context),
              20.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  normalText(text: 'Do you have an account?', color: fontGrey),
                  TextButton(
                      onPressed: () {
                        Get.to(() => const SignUpScreen(),
                            transition: Transition.rightToLeft);
                      },
                      child: normalText(
                        text: 'Sign Up',
                        color: appColor,
                      ))
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}
