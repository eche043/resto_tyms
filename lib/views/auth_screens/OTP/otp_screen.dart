import 'package:odrive_restaurant/common/const/const.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      'OTP',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 80.0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: boldText(
                          text: 'Enter the confirmation Code',
                          size: 24.0,
                          color: darkGrey),
                    ),
                    20.heightBox,
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      onChanged: (value) {
                        setState(() {
                          otp = value;
                        });
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 50,
                        fieldWidth: 50,
                        activeColor: red,
                        inactiveColor: grey,
                        selectedColor: red,
                      ),
                      textStyle: const TextStyle(fontSize: 20),
                      keyboardType: TextInputType.number,
                      cursorColor: blackColor,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    ),
                    25.heightBox,
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Verification code has been sent to your phone 288*******.',
                        style: TextStyle(
                            fontSize: 16, color: darkGrey, fontFamily: 'serif'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    25.heightBox,
                    normalText(
                        text: "Haven't received the Code yet?",
                        color: darkGrey,
                        size: 16.0),
                    TextButton(
                      onPressed: () {},
                      child: normalText(
                          text: 'Resend (59 seconds)',
                          color: darkGrey,
                          size: 16.0),
                    ),
                    10.heightBox,
                    customButton(
                      context: context,
                      title: 'Continue',
                      onPress: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              content: SizedBox(
                                //height: MediaQuery.of(context).size.height * 0.36,
                                width: MediaQuery.of(context).size.width * 0.66,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    boldText(
                                        text: "Registered Successfully",
                                        size: 18.0,
                                        color: blackColor),
                                    8.heightBox,
                                    const Icon(Icons.check_circle,
                                        color: appColor, size: 50),
                                    12.heightBox,
                                    const Text(
                                      '899*********',
                                      style: TextStyle(
                                          color: appColor,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Your phone number has been successfully registered.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    25.heightBox,
                                    /* customButton(
                                        context: context,
                                        title: 'Continue to Homepage',
                                        onPress: () {
                                          Get.offAll(() => const HomeScreen(),
                                              transition: Transition.upToDown,
                                              duration: const Duration(
                                                  milliseconds: 500));
                                        }) */
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
