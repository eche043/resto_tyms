import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odrive_restaurant/common/const/images.dart';
import 'package:odrive_restaurant/common/widgets/bg_image.dart';
import 'package:odrive_restaurant/main.dart';
import 'package:odrive_restaurant/model/pref.dart';
import 'package:odrive_restaurant/views/Home/home_screen.dart';
import 'package:odrive_restaurant/views/auth_screens/onboarding/role_selection_screen.dart';
import 'package:odrive_restaurant/views/auth_screens/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  changescreen() async {
    Pref pref = Pref();
    var prefs = await SharedPreferences.getInstance();
    String lang = prefs.getString("language") ?? "";
    print("langgggggggg");
    print(lang);
    if (lang == "") {
      MyApp.setLocale(context, const Locale('fr'));
    } else {
      MyApp.setLocale(context, Locale(lang));
    }
    var userId = prefs.getInt("userId");
    /* Lang strings = Lang();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var id = pref.getString('language');
    var lid = Lang.french;
    print(id);
    if (id != null) lid = int.parse(id);
    print(lid);
    strings.setLang(lid); */
    Future.delayed(const Duration(seconds: 3), (() {
      if (userId != null) {
        Get.offAll(() => HomeScreen());
      } else {
        //Get.offAll(() => const SignInScreen());
        Get.offAll(() => const RoleSelectionScreen());
      }
    }));
  }

  @override
  void initState() {
    changescreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BgContainer(),
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Image.asset(
                      logodilivery,
                      height: 114,
                      width: 235,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
