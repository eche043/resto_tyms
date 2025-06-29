import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/config/lang.dart';
import 'package:odrive_restaurant/model/pref.dart';

class Account {
  String _fcbToken = "";
  String userName = "";
  String userId = "";
  String email = "";
  String phone = "";
  String userAvatar = "";
  String token = "";

  int notifyCount = 0;
  String currentOrder = "";
  String openOrderOnMap = "";
  String backRoute = "";

  bool onLine = true;
  bool initUser = true;

  okUserEnter(String name, String password, String avatar, String _email,
      String _token, String _phone, int unreadNotify, String _userId) async {
    initUser = true;
    userName = name;
    userAvatar = avatar;
    if (userAvatar.isEmpty) userAvatar = serverImgNoUserPath;
    if (userAvatar.isEmpty) userAvatar = serverImgNoUserPath;
    email = _email;
    phone = _phone;
    if (phone.isEmpty) phone = "";
    token = _token;
    userId = _userId;
    notifyCount = unreadNotify;
    pref.set(Pref.userEmail, _email);
    pref.set(Pref.userPassword, password);
    pref.set(Pref.userAvatar, avatar);
    print("User Auth! Save email=$email pass=$password");
    _callAll(true);
    // var status = await getStatus();
    // if (status["error"] == '0') {
    //   _successGetStatus(status["active"]);
    // }
    if (_fcbToken.isNotEmpty) addNotificationToken(_fcbToken);
  }

  _successGetStatus(int active) {
    onLine = (active == 1);
  }

  /* setOnlineStatus(bool status) {
    onLine = status;
    var _text = "0";
    if (status) _text = "1";
    setStatus(token, _text, () {});
  } */

  redraw() {
    _callAll(initUser);
  }

  var callbacks = Map<String, Function(bool)>();

  _callAll(bool value) {
    for (var callback in callbacks.values) {
      try {
        callback(value);
      } catch (ex) {}
    }
  }

  logOut() {
    initUser = false;
    pref.clearUser();
    userName = "";
    userAvatar = "";
    email = "";
    token = "";
    _callAll(false);
  }

  addCallback(String name, Function(bool) callback) {
    callbacks.addAll({name: callback});
  }

  removeCallback(String name) {
    callbacks.remove(name);
  }

//  Function _redrawMainWindow;

//  setRedraw(Function callback){
//    _redrawMainWindow = callback;
//  }

  /*  isAuth(Function(bool) callback) {
    var email = pref.get(Pref.userEmail);
    var pass = pref.get(Pref.userPassword);
    dprint("Login: email=$email pass=$pass");
    if (email.isNotEmpty && pass.isNotEmpty) {
      login(email, pass, (String name,
          String password,
          String avatar,
          String email,
          String token,
          String phone,
          int unreadNotify,
          String userId) {
        callback(true);
        okUserEnter(
            name, password, avatar, email, token, phone, unreadNotify, userId);
      }, (String err) {
        callback(false);
      });
    } else
      callback(false);
  } */

  setFcbToken(String token) {
    _fcbToken = token;
    addNotificationToken(_fcbToken);
  }

  addNotify() {
    notifyCount++;
    _callAll(true);
    if (_callbackNotify != null) _callbackNotify!();
  }

  Function? _callbackNotify;

  addCallbackNotify(Function? callback) {
    _callbackNotify = callback;
  }
}
