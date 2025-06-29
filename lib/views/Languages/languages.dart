import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/main.dart';
import 'package:odrive_restaurant/model/pref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  Pref pref = Pref();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      body: Stack(
        children: [
          const BgContainer(),
          CustomAppBar(
            leadingImageAsset: drawer,
            title: AppLocalizations.of(context)!.language_title,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset:
                            const Offset(3, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: InkWell(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString("language", "fr");
                        pref.set(Pref.language, "fr");
                        // Mettre à jour la langue de l'application

                        MyApp.setLocale(context, const Locale('fr'));
                        // Mettre à jour la langue
                        setState(() {}); // Rafraîchir l'interface utilisateur
                        //runApp(MyApp(selectedLanguage: "fr"));
                      },
                      child: Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/fra.png'),
                              radius: 20,
                            ),
                            title: Text(
                              'Français',
                              //style: theme.text16bold,
                            ),
                            subtitle: Text(
                              'Français',
                              //style: theme.text14,
                            ),
                            trailing: AnimatedContainer(
                              width: 25,
                              height: 25,
                              duration: const Duration(milliseconds: 400),
                              child: const CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/images/iconok.png"),
                                  radius: 15),
                            ),
                          )))),
              Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset:
                            const Offset(3, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: InkWell(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString("language", "en");
                        pref.set(Pref.language, "en");
                        MyApp.setLocale(context, const Locale('en'));
                        setState(() {}); // Rafraîchir l'interface utilisateur
                        //runApp(MyApp(selectedLanguage: "en"));
                      },
                      child: Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/usa.png'),
                              radius: 20,
                            ),
                            title: Text(
                              'English',
                              //style: theme.text16bold,
                            ),
                            subtitle: Text(
                              'English',
                              //style: theme.text14,
                            ),
                            trailing: AnimatedContainer(
                              width: 25,
                              height: 25,
                              duration: const Duration(milliseconds: 400),
                              child: const CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/images/iconok.png"),
                                  radius: 15),
                            ),
                          ))))
            ],
          )
        ],
      ),
    );
  }
}
