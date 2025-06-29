import 'dart:async';
import 'dart:math';
import 'package:odrive_restaurant/common/component/loading.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/widgets/custom_radiotile2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_bus/event_bus.dart';

import 'package:shared_preferences/shared_preferences.dart';

class QuotasScreen extends StatefulWidget {
  const QuotasScreen({super.key});

  @override
  State<QuotasScreen> createState() => _QuotasScreenState();
}

class _QuotasScreenState extends State<QuotasScreen> {
  String? _selectedValue;
  String otp = '';
  bool _loading = false;
  int _selectedcourse = 0;
  int _selectedmontant = 0;
  String? _selectedValue2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const BgContainer(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.04,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 40 + MediaQuery.of(context).padding.top,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  'Réchargement'.text.size(18).semiBold.make(),

                  const Spacer(),
                  // CircleAvatar
                  const CircleAvatar(),
                ],
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 30.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  50.heightBox,
                  Column(
                    children: [
                      CustomRadioTile2(
                        title: '1 Course',
                        montant: '150',
                        value: '1',
                        groupValue: _selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                        },
                        activeColor: appColor,
                      ),
                      12.heightBox,
                      CustomRadioTile2(
                        title: '10 Courses',
                        montant: '1200',
                        value: '10',
                        groupValue: _selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                        },
                        activeColor: appColor,
                      ),
                      12.heightBox,
                      CustomRadioTile2(
                        title: '50 Courses',
                        montant: '5500',
                        value: '50',
                        groupValue: _selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                        },
                        activeColor: appColor,
                      ),
                    ],
                  ),
                  15.heightBox,
                  Center(
                    child: customButton(
                        context: context,
                        title: 'Suivant',
                        onPress: () {
                          Get.to(
                              () => AccountScreen(
                                    nbr_course: int.parse(_selectedValue!),
                                    montant: 5500,
                                  ),
                              transition: Transition.downToUp,
                              duration: const Duration(milliseconds: 500));
                        }),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
