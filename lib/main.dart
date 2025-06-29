import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:odrive_restaurant/common/config/lang.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/l10n/l10n.dart';
import 'package:odrive_restaurant/model/account.dart';
import 'package:odrive_restaurant/model/pref.dart';
import 'package:odrive_restaurant/providers/auth_provider.dart';
import 'package:odrive_restaurant/providers/dashboard_provider.dart';
import 'package:odrive_restaurant/providers/order_provider.dart';
import 'package:odrive_restaurant/providers/product_provider.dart';
import 'package:odrive_restaurant/providers/restaurant_provider.dart';
import 'package:odrive_restaurant/providers/role_provider.dart';
import 'package:odrive_restaurant/providers/user_provider.dart';
import 'package:odrive_restaurant/services/message_provider.dart';
import 'package:provider/provider.dart';

Lang strings = Lang();
Pref pref = Pref();
Account account = Account();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await pref.init();
  String? selectedLanguage = pref.get("language");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (context) => RestaurantsProvider()),
        ChangeNotifierProvider(create: (context) => RoleProvider()),
        ChangeNotifierProvider(
            create: (context) => UserProvider()..loadUserData()),
      ],
      child: MyApp(selectedLanguage: selectedLanguage),
    ),
  ); //MyApp(selectedLanguage: selectedLanguage));
}

/* class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  String? selectedLanguage;
  MyApp({Key? key, this.selectedLanguage}) : super(key: key);

  void updateLocale(String newLocale) {
    print("object update*********************");
    selectedLanguage = newLocale;
    MyApp.navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      builder: (context) => MyApp(selectedLanguage: selectedLanguage),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      locale: selectedLanguage != null
          ? Locale(selectedLanguage!)
          : const Locale('fr'),
      title: 'Food Delivery',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, elevation: 0),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
} */

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  String? selectedLanguage;
  MyApp({super.key, this.selectedLanguage});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  String selectedLanguage = "";
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //updateLocale(widget.selectedLanguage);
  }

  void updateLocale(String? newLocale) {
    print("object update*********************");

    setState(() {
      selectedLanguage = newLocale ?? "";
    });
    /* MyApp.navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      builder: (context) => MyApp(selectedLanguage: selectedLanguage),
    )); */
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      /* locale: selectedLanguage != ""
          ? Locale(selectedLanguage!)
          : const Locale('fr'), */
      locale: _locale,
      title: 'Tyms Restaurant',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, elevation: 0),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
