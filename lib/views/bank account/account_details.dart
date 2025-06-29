import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/component/loading.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/widgets/custom_radiotile2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_bus/event_bus.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Créez une classe d'événement pour représenter l'intégration de l'utilisateur avec Google
class UserGoogleIntegrationEvent {}

// Créez une instance de l'EventBus
EventBus eventBus = EventBus();

class AccountScreen extends StatefulWidget {
  final int nbr_course;
  final int montant;

  AccountScreen({
    super.key,
    required this.nbr_course,
    required this.montant,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? _selectedValue;
  String otp = '';
  bool _loading = false;
  StreamSubscription<UserGoogleIntegrationEvent>? subscription;
  TextEditingController _phoneController = TextEditingController();
  int _selectedcourse = 0;
  int _selectedmontant = 0;
  String? _selectedValue2;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(LifecycleEventHandler());
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    subscription!.cancel();
    super.dispose();
  }

  void SuccesEchecDialog(bool etat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Arrondir les coins
          ),
          elevation: 0, // Supprimer l'ombre
          backgroundColor: Colors.transparent, // Fond transparent
          child: Container(
            //width: 327,
            //height: 380,
            padding: const EdgeInsets.all(12),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              //mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: etat
                        ? DecorationImage(
                            image: AssetImage(
                                "assets/images/succes.gif"), // Image depuis les assets
                            fit: BoxFit.fill,
                          )
                        : DecorationImage(
                            image: AssetImage(
                                "assets/images/echec.gif"), // Image depuis les assets
                            fit: BoxFit.fill,
                          ),
                    borderRadius: BorderRadius.circular(
                        50), // Arrondir les coins de l'image
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: Text(
                      !etat
                          ? 'Votre réchargement à echouer '
                          : 'Réchargement effectué',
                      textAlign: TextAlign.center,
                      style: text20Secondary,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(
                    //width: double.infinity,
                    children: [
                      Expanded(
                        child: Text(
                          !etat
                              ? 'Merci de bien vouloir réessayer après avoir vérifié votre compte'
                              : 'Vous pouvez recevoir des commandes',
                          textAlign: TextAlign.center,
                          style: text14GrayScale900,
                        ),
                      ),
                    ]),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          width: 263,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Color(0xFF03443C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              int userId = prefs.getInt("userId") ?? 0;
                              !etat
                                  ? Navigator.of(context).pop()
                                  : Get.offAll(
                                      () => HomeScreen());
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: Text(
                                      !etat ? 'Réessayer' : 'Continuer',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFFEFEFE),
                                        fontSize: 16,
                                        fontFamily: 'Abel',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void startExecution(idFromClient, method) {
    print(idFromClient);
    // Créez un Timer périodique qui s'exécutera toutes les 20 secondes
    Timer.periodic(Duration(seconds: 10), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Vérifiez le statut du paiement
      print("object__________________________--------_____---__--_-__-");

      print(idFromClient);
      var responseStatus = await checkStatus(idFromClient);
      print(responseStatus["status"]);
      if (responseStatus["status"] == "SUCCESSFUL") {
        print("faileddddddddd");
        await saveRechargement(responseStatus, idFromClient, 10);
        setState(() {
          _loading = false;
        });
        // Affichez un message en cas d'échec du paiement
        SuccesEchecDialog(false);
        timer.cancel();
      } else if (responseStatus["status"] == "FAILED") {
        await saveRechargement(responseStatus, idFromClient, widget.nbr_course);
        await addCourse(widget.nbr_course);

        // Affichez un message en cas de succès du paiement

        // Arrêtez la boucle d'exécution car le paiement est réussi
        timer.cancel();

        setState(() {
          _loading = false;
        });
        SuccesEchecDialog(true);
      } else if (responseStatus["status"] == 404) {
        timer.cancel();
        setState(() {
          _loading = false;
        });
        SuccesEchecDialog(false);
      } else {
        await saveRechargement(responseStatus, idFromClient, widget.nbr_course);
      }
    });
  }

  void startExecutionWave(idFromClient) async {
    // Vérifiez le statut du paiement
    print("object__________________________--------_____---__--_-__-");
    var responseStatus = await checkStatus(idFromClient);
    if (responseStatus["status"] == "SUCCEED") {
      await saveRechargement(responseStatus, idFromClient, 10);
      setState(() {
        _loading = false;
      });
      // Affichez un message en cas d'échec du paiement
      SuccesEchecDialog(false);
    } else if (responseStatus["status"] == "FAILED") {
      await saveRechargement(responseStatus, idFromClient, 10);

      setState(() {
        _loading = false;
      });
      // Affichez un message en cas de succès du paiement
      SuccesEchecDialog(true);

      // Arrêtez la boucle d'exécution car le paiement est réussi
    } else {
      await saveRechargement(responseStatus, idFromClient, 10);
      setState(() {
        _loading = false;
      });
      // Affichez un message en cas de succès du paiement
      SuccesEchecDialog(false);

      // Arrêtez la boucle d'exécution car le paiement est réussi
    }
  }

  Future<void> launchWave(String url) async {
    print(url);
    await launch(url);

    /*}  else {
      throw 'Impossible d\'ouvrir l\'URL $url';
    } */
  }

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
                  'Bank Acount'.text.size(18).semiBold.make(),

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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    height: 200,
                    //  width: 350,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          16), // Adjust the border radius as needed
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Shadow color
                          spreadRadius: 5, // Spread radius
                          blurRadius: 7, // Blur radius
                          offset: const Offset(0, 3), // Shadow offset
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(card1),
                            const SizedBox(width: 8),
                            Image.asset(card2),
                            const SizedBox(width: 8),
                            Image.asset(card3),
                          ],
                        ),
                        20.heightBox,
                        'Add credit or debit card'
                            .text
                            .color(fontGrey.withOpacity(0.7))
                            .make()
                      ],
                    ),
                  ),
                  50.heightBox,
                  Column(
                    children: [
                      CustomRadioTile(
                        title: 'Orange Money',
                        imageAsset: orangeIcon,
                        value: 'orange',
                        groupValue: _selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                          _showBottomSheet(true, 'OM');
                        },
                        activeColor: appColor,
                      ),
                      12.heightBox,
                      CustomRadioTile(
                        title: 'MTN Mobile Money',
                        imageAsset: mtnIcon,
                        value: 'mtn',
                        groupValue: _selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                          _showBottomSheet(false, "MTN");
                        },
                        activeColor: appColor,
                      ),
                      12.heightBox,
                      CustomRadioTile(
                        title: 'Moov Money',
                        imageAsset: moovIcon,
                        value: 'Moov',
                        groupValue: _selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                          _showBottomSheet(false, "MOOV");
                        },
                        activeColor: appColor,
                      ),
                      12.heightBox,
                      CustomRadioTile(
                        title: 'Wave',
                        imageAsset: waveIcon,
                        value: 'wave',
                        groupValue: _selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                          _showBottomSheet(false, "WAVE");
                        },
                        activeColor: appColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _loading ? LoadingWidget() : Container(),
        ],
      ),
    );
  }

  void _showBottomSheet(bool _otp, String type) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: white,
      showDragHandle: true,
      enableDrag: true,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          //padding: const EdgeInsets.symmetric(horizontal: 30),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateX(-pi / 5.5), // Rotate on X-axis
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    'Nouveau réchargement'.text.size(22).semiBold.make(),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        normalText(
                            text: 'Numéro du paiement',
                            color: blackColor,
                            size: 16.0),
                        8.heightBox,
                        customTextField(
                            hint: 'Entrer le numéro de téléphone',
                            controller: _phoneController),
                      ],
                    ),
                    _otp ? const SizedBox(height: 16) : Container(),
                    _otp
                        ? 'Code OTP'.text.size(22).semiBold.make()
                        : Container(),
                    const SizedBox(height: 20),
                    _otp
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PinCodeTextField(
                                appContext: context,
                                length: 4,
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
                                  activeColor: green,
                                  inactiveColor: blackColor,
                                  selectedColor: red,
                                ),
                                textStyle: const TextStyle(fontSize: 20),
                                keyboardType: TextInputType.number,
                                cursorColor: blackColor,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                              ),
                            ],
                          )
                        : Container(),
                    const SizedBox(height: 16),
                    Center(
                      child: customButton(
                          context: context,
                          title: 'Submit',
                          onPress: () async {
                            Navigator.pop(context);
                            setState(() {
                              _loading = true;
                            });

                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String completName =
                                prefs.getString("userName") ?? "";

                            List<String> nameParts = completName.split(' ');
                            String name =
                                nameParts.isNotEmpty ? nameParts.first : '';
                            String prenoms = nameParts.sublist(1).join(' ');
                            DateTime now = DateTime.now();
                            var idFromClient =
                                "${now.millisecondsSinceEpoch}T${prefs.getInt('userId')}D";
                            if (type == "OM") {
                              var response = await paiementom(
                                  idFromClient,
                                  prefs.getString("userEmail"),
                                  name,
                                  prenoms,
                                  _phoneController.text,
                                  otp,
                                  widget.montant);
                              print(
                                  "responseeeeeee-------------------------------");
                              print(response);
                              if (response["status"] == "SUCCESSFUL") {
                                await saveRechargement(
                                    response, idFromClient, widget.nbr_course);

                                await addCourse(widget.nbr_course);

                                setState(() {
                                  _loading = false;
                                });
                                SuccesEchecDialog(true);
                              } else {
                                startExecution(idFromClient, "OM");
                              }
                            }
                            if (type == "MTN") {
                              var response = await paiementmtn(
                                  idFromClient,
                                  prefs.getString("userEmail"),
                                  name,
                                  prenoms,
                                  _phoneController.text,
                                  widget.montant);
                              print(
                                  "responseeeeeee-------------------------------");
                              print(response);
                              if (response["status"] == "SUCCESSFUL") {
                                await saveRechargement(
                                    response, idFromClient, 10);

                                setState(() {
                                  _loading = false;
                                });
                                SuccesEchecDialog(true);
                              } else {
                                startExecution(idFromClient, "MTN");
                              }
                            }
                            if (type == "MOOV") {
                              var response = await paiementmoov(
                                  idFromClient,
                                  prefs.getString("userEmail"),
                                  name,
                                  prenoms,
                                  _phoneController.text,
                                  widget.montant);
                              print(
                                  "responseeeeeee-------------------------------");
                              print(response);
                              if (response["status"] == "SUCCESSFUL") {
                                await saveRechargement(
                                    response, idFromClient, 10);

                                setState(() {
                                  _loading = false;
                                });
                                SuccesEchecDialog(true);
                              } else {
                                startExecution(idFromClient, "OM");
                              }
                            }
                            if (type == "WAVE") {
                              var response = await paiementwave(
                                  idFromClient,
                                  prefs.getString("userEmail"),
                                  name,
                                  prenoms,
                                  _phoneController.text,
                                  widget.montant);
                              print(response);

                              if (response["status"] == "INITIATED" ||
                                  response["status"] == "PENDING") {
                                await saveRechargement(
                                    response, idFromClient, 10);

                                await launchWave(response["payment_url"]);
                                subscription = eventBus
                                    .on<UserGoogleIntegrationEvent>()
                                    .listen((event) {
                                  // Faites ce que vous devez faire lorsque l'événement se produit
                                  startExecutionWave(idFromClient);
                                });
                              }
                            }
                          }),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler();

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        eventBus.fire(UserGoogleIntegrationEvent());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }
}
