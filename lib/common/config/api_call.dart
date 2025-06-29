import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/main.dart';
import 'package:odrive_restaurant/model/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

var loginagent = "0759261075";
var passwordagent = "rRPS3SSWTC";
var username =
    '21c5685f39c665e481147bf9273ef6c80a36d1003cecec9c85fc466596b1734e';
var password =
    '50a4687f72e0724ee6ab328530ef71589311bfe517cb00a791c6d9b335844861';
var agence = "ODRCI10751";

// Timeout par défaut
const Duration _timeout = Duration(seconds: 30);
//Account account = Account();
login(String email, String password) async {
  try {
    var body = json.encoder.convert({
      'phone': 'null',
      'email': '$email',
      'password': '$password',
      'owner': 'true'
    });

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Content-Length': "${body.length}",
      // 'Host' : "madir.com.ng"
    };

    var url = "${serverPath}login";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print("login: $url, $body");
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);

      // if (jsonResult['error'] == 0) {

      //   return jsonResult;
      // } else {
      // }
      return jsonResult;
    }
  } catch (ex) {
    print(ex);
    //callbackError(ex.toString());
  }
}

getOrders() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    var url = "${serverPath}ordersList";
    var response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $uid',
      'Content-type': 'application/json',
      'Accept': "application/json",
      'X-CSRF-TOKEN': uid,
    }).timeout(const Duration(seconds: 30));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      print(jsonResult);
      return jsonResult;
    } else {
      return {'error': 'verifiez votre connexion'};
    }
  } catch (ex) {
    return {'error': 'Une erreur s\'est produite'};
  }
}

sendLocation(String lat, String lng, String speed) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  if (lat.isEmpty || lng.isEmpty) return;

  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    var body = json.encoder.convert({
      'lat': lat,
      'lng': lng,
      'speed': speed,
    });

    var url = "${serverPath}sendLocation";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  } catch (ex) {
    print(ex.toString());
  }
}

reject(String comment, String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    String body =
        '{"id" : ${json.encode(id)}, "comment": ${json.encode(comment)}}';
    var url = "${serverPath}reject";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401)
      return {'error': 'Une erreur s\'est produite vérifier votre connexion'};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return jsonResult;
    } else
      return {
        'error': 'Une erreur inconnue s\'est produite vérifier votre connexion'
      };
  } catch (ex) {
    return {'error': 'Une erreur inconnue s\'est produite'};
  }
}

accept(String id, Function() callback, Function(String) callbackError) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    String body = '{"id" : ${json.encode(id)}}';
    var url = "${serverPath}accept";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401) return callbackError("401");
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"].toString() == "0") {
        callback();
      } else {
        callbackError(jsonResult["error"].toString());
      }
    } else {
      callbackError("statusCode=${response.statusCode}");
    }
  } catch (ex) {
    callbackError(ex.toString());
  }
}

complete(String id, Function() callback, Function(String) callbackError) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    String body = '{"id" : ${json.encode(id)}}';
    var url = "${serverPath}complete";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401) return {callbackError("401")};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"] == "0") {
        callback();
      } else
        callbackError(jsonResult["error"]);
    } else
      callbackError("statusCode=${response.statusCode}");
  } catch (ex) {
    callbackError(ex.toString());
  }
}

qrCodeScanner(String qr_code) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    String body = '{"qr_code" : ${json.encode(qr_code)}}';
    var url = "${serverPath}verifyQrcode";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401)
      return {'error': 'une erreur s\'est produite'};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"] == "0") {
        return jsonResult;
      } else
        return jsonResult;
    } else
      return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  } catch (ex) {
    return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  }
}

Future<Map<String, dynamic>> paiementom(idfromclient, recipientemail,
    recipientfirstname, recipientlastname, destinataire, otp, montant) async {
  try {
    print("in intouchservice");
    // URL de l'API
    final String apiUrl =
        'https://api.gutouch.com/dist/api/touchpayapi/v1/$agence/transaction?loginAgent=$loginagent&passwordAgent=$passwordagent';

    print("in intouchservice ${apiUrl}");

    Map<String, dynamic> requestBody = {
      "idFromClient": idfromclient,
      "additionnalInfos": {
        "recipientEmail": recipientemail,
        "recipientFirstName": recipientfirstname,
        "recipientLastName": recipientlastname,
        "destinataire": destinataire,
        "otp": otp
      },
      "amount": montant,
      "callback": "https://odriveportail.com/api/callback",
      "recipientNumber": "0778992531",
      "serviceCode": "PAIEMENTMARCHANDOMPAYCIDIRECT"
    };
    print("after requestBody");
    print(requestBody);

    // Convertir le corps de la requête en format JSON
    String requestBodyJson = json.encode(requestBody);

    // Créer l'objet de requête HTTP
    http.Request request = http.Request('PUT', Uri.parse(apiUrl));
    request.headers['Content-Type'] = 'application/json';
    request.body = requestBodyJson;

    // Créer l'objet d'authentification Digest
    DigestAuthClient digestAuthClient = DigestAuthClient(username, password);

    // Envoyer la requête avec l'authentification Digest
    http.StreamedResponse streamedResponse =
        await digestAuthClient.send(request);

    // Lire le corps de la réponse
    String responseString = await streamedResponse.stream.bytesToString();

    // Créer une réponse avec le corps et le code de statut
    http.Response response =
        http.Response(responseString, streamedResponse.statusCode);

    // Afficher la réponse
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête réussie: ${jsonResponse}');

      // Retourner une instance de TransactionResponse
      return jsonResponse;
    } else {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête error: ${jsonResponse['status']}');
      return jsonResponse;
    }

    // Traiter la réponse
  } catch (e) {
    print(e);
    return {"error": e};
  }
}

Future<Map<String, dynamic>> paiementmtn(idfromclient, recipientemail,
    recipientfirstname, recipientlastname, destinataire, montant) async {
  try {
    print("in intouchservice");
    // URL de l'API
    final String apiUrl =
        'https://api.gutouch.com/dist/api/touchpayapi/v1/$agence/transaction?loginAgent=$loginagent&passwordAgent=$passwordagent';

    print("in intouchservice ${apiUrl}");

    Map<String, dynamic> requestBody = {
      "idFromClient": idfromclient,
      "additionnalInfos": {
        "recipientEmail": recipientemail,
        "recipientFirstName": recipientfirstname,
        "recipientLastName": recipientlastname,
        "destinataire": destinataire
      },
      "amount": montant,
      "callback": "https://odriveportail.com/api/callback",
      "recipientNumber": destinataire,
      "serviceCode": "PAIEMENTMARCHAND_MTN_CI"
    };
    print("after requestBody");
    print(requestBody);

    // Convertir le corps de la requête en format JSON
    String requestBodyJson = json.encode(requestBody);

    // Créer l'objet de requête HTTP
    http.Request request = http.Request('PUT', Uri.parse(apiUrl));
    request.headers['Content-Type'] = 'application/json';
    request.body = requestBodyJson;

    // Créer l'objet d'authentification Digest
    DigestAuthClient digestAuthClient = DigestAuthClient(username, password);

    // Envoyer la requête avec l'authentification Digest
    http.StreamedResponse streamedResponse =
        await digestAuthClient.send(request);

    // Lire le corps de la réponse
    String responseString = await streamedResponse.stream.bytesToString();

    // Créer une réponse avec le corps et le code de statut
    http.Response response =
        http.Response(responseString, streamedResponse.statusCode);

    // Afficher la réponse
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête réussie: ${jsonResponse}');

      // Retourner une instance de TransactionResponse
      return jsonResponse;
    } else {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête error: ${jsonResponse['status']}');
      return jsonResponse;
    }

    // Traiter la réponse
  } catch (e) {
    print(e);
    return {"error": e};
  }
}

Future<Map<String, dynamic>> paiementmoov(idfromclient, recipientemail,
    recipientfirstname, recipientlastname, destinataire, montant) async {
  try {
    print("in intouchservice");
    // URL de l'API
    const String apiUrl =
        'https://api.gutouch.com/dist/api/touchpayapi/v1/ODRCI10751/transaction?loginAgent=0759261075&passwordAgent=rRPS3SSWTC';

    print("in intouchservice ${apiUrl}");

    Map<String, dynamic> requestBody = {
      "idFromClient": idfromclient,
      "additionnalInfos": {
        "recipientEmail": recipientemail,
        "recipientFirstName": recipientfirstname,
        "recipientLastName": recipientlastname,
        "destinataire": destinataire
      },
      "amount": montant,
      "callback": "https://odriveportail.com/api/callback",
      "recipientNumber": destinataire,
      "serviceCode": "PAIEMENTMARCHAND_MOOV_CI"
    };
    print("after requestBody");
    print(requestBody);

    // Convertir le corps de la requête en format JSON
    String requestBodyJson = json.encode(requestBody);

    // Créer l'objet de requête HTTP
    http.Request request = http.Request('PUT', Uri.parse(apiUrl));
    request.headers['Content-Type'] = 'application/json';
    request.body = requestBodyJson;

    // Créer l'objet d'authentification Digest
    DigestAuthClient digestAuthClient = DigestAuthClient(username, password);

    // Envoyer la requête avec l'authentification Digest
    http.StreamedResponse streamedResponse =
        await digestAuthClient.send(request);

    // Lire le corps de la réponse
    String responseString = await streamedResponse.stream.bytesToString();

    // Créer une réponse avec le corps et le code de statut
    http.Response response =
        http.Response(responseString, streamedResponse.statusCode);

    // Afficher la réponse
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête réussie: ${jsonResponse}');

      // Retourner une instance de TransactionResponse
      return jsonResponse;
    } else {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête error: ${jsonResponse['status']}');
      return jsonResponse;
    }

    // Traiter la réponse
  } catch (e) {
    print(e);
    return {"error": e};
  }
}

Future<Map<String, dynamic>> paiementwave(idfromclient, recipientemail,
    recipientfirstname, recipientlastname, destinataire, montant) async {
  try {
    print("in intouchservice");
    // URL de l'API
    const String apiUrl =
        'https://api.gutouch.com/dist/api/touchpayapi/v1/ODRCI10751/transaction?loginAgent=0759261075&passwordAgent=rRPS3SSWTC';

    print("in intouchservice ${apiUrl}");

    Map<String, dynamic> requestBody = {
      "idFromClient": idfromclient,
      "additionnalInfos": {
        "recipientEmail": recipientemail,
        "recipientFirstName": recipientfirstname,
        "recipientLastName": recipientlastname,
        "destinataire": destinataire,
        "partner_name": "O'DRIVE",
        "return_url": "https://successurl.com",
        "cancel_url": "https://failedurl.com"
      },
      "amount": montant,
      "callback": "https://odriveportail.com/api/callback",
      "recipientNumber": destinataire,
      "serviceCode": "CI_PAIEMENTWAVE_TP"
    };
    print("after requestBody");
    print(requestBody);

    // Convertir le corps de la requête en format JSON
    String requestBodyJson = json.encode(requestBody);

    // Créer l'objet de requête HTTP
    http.Request request = http.Request('PUT', Uri.parse(apiUrl));
    request.headers['Content-Type'] = 'application/json';
    request.body = requestBodyJson;

    // Créer l'objet d'authentification Digest
    DigestAuthClient digestAuthClient = DigestAuthClient(username, password);

    // Envoyer la requête avec l'authentification Digest
    http.StreamedResponse streamedResponse =
        await digestAuthClient.send(request);

    // Lire le corps de la réponse
    String responseString = await streamedResponse.stream.bytesToString();

    // Créer une réponse avec le corps et le code de statut
    http.Response response =
        http.Response(responseString, streamedResponse.statusCode);

    // Afficher la réponse
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête réussie: ${jsonResponse}');

      // Retourner une instance de TransactionResponse
      return jsonResponse;
    } else {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête error: ${jsonResponse['status']}');
      return jsonResponse;
    }

    // Traiter la réponse
  } catch (e) {
    print(e);
    return {"error": e};
  }
}

Future<dynamic> saveRechargement(
    dynamic paiementDetail, String idFromClient, int nbre_course) async {
  print("saveeeeeeeeeeeeee");
  print("deeeeeeeeeeeeeetail");
  print(paiementDetail);
  print(paiementDetail);

  try {
    var body = json.encoder.convert(paiementDetail);

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Content-Length': "${body.length}",
      // 'Host' : "madir.com.ng"
    };
    print("bbbbbbbooooooo");
    print(body);

    var url = "${serverPath}saverechargement";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print("savepaiement: $url, $body");
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return {"message": "rechargement sauvegarder"};
    } else {
      print("Erreur lors de la sauvegarde du paiement");
      return {"error": "Erreur lors de la sauvegarde du rechargement"};
    }
  } catch (ex) {
    print(ex);
    //callbackError(ex.toString());
  }
}

Future<Map<String, dynamic>> checkStatus(idfromclient) async {
  try {
    final String apiUrl =
        'https://api.gutouch.com/dist/api/touchpayapi/v1/ODRCI10751/transaction/$idfromclient?loginAgent=0759261075&passwordAgent=rRPS3SSWTC';

    // Créer l'objet de requête HTTP
    http.Request request = http.Request('GET', Uri.parse(apiUrl));
    request.headers['Content-Type'] = 'application/json';
    //request.body = requestBodyJson;

    // Créer l'objet d'authentification Digest
    DigestAuthClient digestAuthClient = DigestAuthClient(username, password);

    // Envoyer la requête avec l'authentification Digest
    http.StreamedResponse streamedResponse =
        await digestAuthClient.send(request);

    // Lire le corps de la réponse
    String responseString = await streamedResponse.stream.bytesToString();

    // Créer une réponse avec le corps et le code de statut
    http.Response response =
        http.Response(responseString, streamedResponse.statusCode);

    // Afficher la réponse
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête réussie: ${jsonResponse}');

      // Retourner une instance de TransactionResponse
      return jsonResponse;
    } else {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Requête error: ${jsonResponse['status']}');
      return jsonResponse;
    }
  } catch (e) {
    print(e);
    return {"error": e};
  }
}

Future<dynamic> addCourse(int course) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    String body = '{"course" : ${json.encode(course)}}';
    var url = "${serverPath}addCourse";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401)
      return {'error': 'une erreur s\'est produite'};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"] == "0") {
        return jsonResult;
      } else
        return jsonResult;
    } else
      return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  } catch (ex) {
    return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  }
}

Future<dynamic> getCourse() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    var url = "${serverPath}getCourse";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders)
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401)
      return {'error': 'une erreur s\'est produite'};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"] == "0") {
        return jsonResult;
      } else
        return jsonResult;
    } else
      return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  } catch (ex) {
    return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  }
}

Future<dynamic> setStatus(int active) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    String body = '{"active" : ${json.encode(active)}}';
    var url = "${serverPath}setStatus";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401)
      return {'error': 'une erreur s\'est produite'};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"] == "0") {
        return jsonResult;
      } else
        return jsonResult;
    } else
      return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  } catch (ex) {
    return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  }
}

Future<dynamic> getStatistics() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  print(uid);
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };

    var url = "${serverPath}getStatistics";
    var response = await http
        .get(Uri.parse(url), headers: requestHeaders)
        .timeout(const Duration(seconds: 60));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401)
      return {'error': 'une erreur s\'est produite'};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      print(jsonResult);
      if (jsonResult["error"] == "0") {
        return jsonResult;
      } else
        return jsonResult;
    } else
      return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  } catch (ex) {
    print(ex);
    return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  }
}

Future<dynamic> changeProfile(String name, String email, String phone) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  print(name);
  print(email);
  print(phone);
  if (name == "" || phone == "") {
    return {"error": "1"};
  }
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };
    // Créez un objet JSON directement
    Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'phone': phone,
    };

    //String body = '{"name" : $name, "email":$email, "phone": $phone}';
    print(requestBody);
    var url = "${serverPath}changeProfile";
    var response = await http
        .post(Uri.parse(url),
            headers: requestHeaders, body: jsonEncode(requestBody))
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401)
      return {'error': 'une erreur s\'est produite'};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"] == "0") {
        return jsonResult;
      } else
        return jsonResult;
    } else
      return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  } catch (ex) {
    return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  }
}

Future<dynamic> changePassword(String oldPassword, String newPassword) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'Authorization': "Bearer $uid",
    };
    // Créez un objet JSON directement
    Map<String, dynamic> requestBody = {
      'oldPassword': oldPassword,
      'newPassword': newPassword
    };

    //String body = '{"name" : $name, "email":$email, "phone": $phone}';
    print(requestBody);
    var url = "${serverPath}changePassword";
    var response = await http
        .post(Uri.parse(url),
            headers: requestHeaders, body: jsonEncode(requestBody))
        .timeout(const Duration(seconds: 30));

    print(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401)
      return {'error': 'une erreur s\'est produite'};
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult["error"] == "0") {
        return jsonResult;
      } else
        return jsonResult;
    } else
      return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  } catch (ex) {
    return {'error': 'une erreur s\'est produite vérifiez votre connexion'};
  }
}

Future<dynamic> uploadAvatar(File photo) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    // Créer un objet de type MultipartRequest
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${serverPath}uploadAvatar"),
    );

    // Ajouter le fichier à la requête
    request.files.add(
      http.MultipartFile(
        'file', // Nom du champ dans le formulaire
        photo.readAsBytes().asStream(), // Flux de bytes du fichier
        photo.lengthSync(), // Taille du fichier
        filename: photo.path.split('/').last, // Nom du fichier
      ),
    );

    // Ajouter les en-têtes à la requête
    request.headers['Authorization'] = 'Bearer $uid';
    request.headers['Accept'] = 'application/json';

    // Envoyer la requête
    var streamedResponse = await request.send();

    // Lire la réponse
    var response = await http.Response.fromStream(streamedResponse);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 401) {
      return {'error': 'Une erreur s\'est produite'};
    } else if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      if (jsonResult['ret'] == true) {
        return jsonResult;
      } else {
        return jsonResult;
      }
    } else {
      return {'error': 'Une erreur s\'est produite. Veuillez réessayer.'};
    }
  } catch (ex) {
    return {'error': 'Une erreur s\'est produite. Veuillez réessayer.'};
  }
}

addNotificationToken(String fcbToken) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  try {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': "application/json",
      'X-CSRF-TOKEN': uid,
      'Authorization': "Bearer $uid",
    };

    String body = '{"fcbToken": "$fcbToken"}';

    print('body: $body');
    var url = "${serverPath}fcbToken";
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));

    print("fcbToken");
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  } catch (_) {}
}

getMessages(int orderId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  print("orderId--------");
  print(orderId);
  var url = "${serverPath}getMessages?order_id=$orderId";
  var response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $uid',
    'Content-type': 'application/json',
    'Accept': "application/json",
    'X-CSRF-TOKEN': uid,
  }).timeout(const Duration(seconds: 30));

  print(response.statusCode);

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    print("--------------body--------------");
    print(body);
    return body.map((dynamic item) => Message.fromJson(item)).toList();
  } else {
    print(response.body);
    throw Exception('Failed to load messages');
  }
}

sendMessage(int orderId, int receiverId, String messageText) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': "application/json",
    'X-CSRF-TOKEN': uid,
    'Authorization': "Bearer $uid",
  };

  String body =
      '{"order_id": $orderId, "receiver_id":$receiverId, "message_text": "$messageText"}';

  print('body: $body');
  var url = "${serverPath}sendMessage";
  var response = await http
      .post(Uri.parse(url), headers: requestHeaders, body: body)
      .timeout(const Duration(seconds: 30));

  if (response.statusCode != 200) {
    throw Exception('Failed to send message');
  }
}

sendAudioMessage(int orderId, int receiverId, String audioUrl) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  var message = null;

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': "application/json",
    'X-CSRF-TOKEN': uid,
    'Authorization': "Bearer $uid",
  };

  String body =
      '{"order_id": $orderId, "receiver_id":$receiverId, "audio_url": "$audioUrl","message_text":$message }';

  print('body: $body');
  var url = "${serverPath}sendMessage";
  var response = await http
      .post(Uri.parse(url), headers: requestHeaders, body: body)
      .timeout(const Duration(seconds: 30));

  if (response.statusCode != 200) {
    print(response.body);
    throw Exception('Failed to send message');
  }
}

sendImageMessage(int orderId, int receiverId, String imageUrl) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  var message = null;
  var audioUrl = null;
  print(orderId);
  print(receiverId);

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': "application/json",
    'X-CSRF-TOKEN': uid,
    'Authorization': "Bearer $uid",
  };

  String body =
      '{"order_id": $orderId, "receiver_id":$receiverId, "image_url": "$imageUrl","message_text":$message }';

  print('body: $body');
  var url = "${serverPath}sendMessage";
  var response =
      await http.post(Uri.parse(url), headers: requestHeaders, body: body);

  if (response.statusCode != 200) {
    print(response.body);
    throw Exception('Failed to send message');
  }
}

getLivreurStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  var url = "${serverPath}statusLivreur";
  var response = await http.post(Uri.parse(url), headers: {
    'Authorization': 'Bearer $uid',
    'Content-type': 'application/json',
    'Accept': "application/json",
    'X-CSRF-TOKEN': uid,
  }).timeout(const Duration(seconds: 30));

  print(response.statusCode);

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    print("--------------body--------------");
    print(body);
    return body;
  } else {
    print(response.body);
    throw Exception('Failed to get LivreurStatus');
  }
}

storeLivreurStatus(int statusId, int orderId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  var url = "${serverPath}storeStatusLivreur";
  var body = json.encoder.convert({
    'status_id': statusId,
    'commande_id': orderId,
  });
  var response = await http
      .post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $uid',
            'Content-type': 'application/json',
            'Accept': "application/json",
            'X-CSRF-TOKEN': uid,
          },
          body: body)
      .timeout(const Duration(seconds: 30));

  print(response.statusCode);

  if (response.statusCode == 200) {
    return "Status mis à jour avec succès.";
  } else {
    print(response.body);
    throw Exception('Failed to update status');
  }
}

/// Récupérer les totaux (commandes, restaurants, gains)
Future<Map<String, dynamic>> getTotals() async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('uuid') ?? '';

  try {
    final headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $uid',
    };

    final url = '${serverPath}totals';
    final response =
        await http.post(Uri.parse(url), headers: headers).timeout(_timeout);

    print('Get totals: $url');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);

      if (jsonResult['error'] == '0') {
        return {
          'success': true,
          'data': {
            'total_orders': jsonResult['orders'] ?? 0,
            'total_restaurants': jsonResult['restaurants'] ?? 0,
            'total_earnings':
                double.tryParse(jsonResult['totals']?.toString() ?? '0') ?? 0.0,
            'total_foods': jsonResult['foods'] ?? 0,
            'currency_symbol': jsonResult['code'] ?? 'FCFA',
            'right_symbol': jsonResult['rightSymbol'] == 'true',
            'symbol_digits': jsonResult['symbolDigits'] ?? 0,
            'restaurant_image': jsonResult['restaurantImage'],
            'food_image': jsonResult['foodImage'],
            'order_image': jsonResult['orderImage'],
          }
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de la récupération des totaux',
        };
      }
    } else {
      return {
        'success': false,
        'error': 'Erreur de connexion (${response.statusCode})',
      };
    }
  } catch (ex) {
    print('Get totals error: $ex');
    return {
      'success': false,
      'error': 'Erreur de connexion: ${ex.toString()}',
    };
  }
}

/// Récupérer l'évolution des commandes
Future<Map<String, dynamic>> getOrdersEvolution({
  String period = 'month',
  String? startDate,
  String? endDate,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('uuid') ?? '';

  try {
    final headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $uid',
    };

    // Construire les paramètres de requête
    final Map<String, String> queryParams = {
      'periode': period,
    };

    if (startDate != null) {
      queryParams['start_date'] = startDate;
    }

    if (endDate != null) {
      queryParams['end_date'] = endDate;
    }

    final uri = Uri.parse('${serverPath}getOrdersEvolution')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers).timeout(_timeout);

    print('Get orders evolution: $uri');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);

      if (jsonResult['error'] == '0') {
        return {
          'success': true,
          'data': jsonResult['data'],
          'period': jsonResult['period'],
          'start_date': jsonResult['start_date'],
          'end_date': jsonResult['end_date'],
          'restaurants': jsonResult['restaurants'],
          'currency': jsonResult['currency'],
        };
      } else {
        return {
          'success': false,
          'error':
              'Erreur lors de la récupération de l\'évolution des commandes',
        };
      }
    } else {
      return {
        'success': false,
        'error': 'Erreur de connexion (${response.statusCode})',
      };
    }
  } catch (ex) {
    print('Get orders evolution error: $ex');
    return {
      'success': false,
      'error': 'Erreur de connexion: ${ex.toString()}',
    };
  }
}

/// Récupérer les classements des restaurants
Future<Map<String, dynamic>> getRestaurantRankings({
  String? startDate,
  String? endDate,
  int? limit,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('uuid') ?? '';

  try {
    final headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $uid',
    };

    // Construire les paramètres de requête
    final Map<String, String> queryParams = {};

    if (startDate != null) {
      queryParams['start_date'] = startDate;
    }

    if (endDate != null) {
      queryParams['end_date'] = endDate;
    }

    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }

    Uri uri;
    if (queryParams.isNotEmpty) {
      uri = Uri.parse('${serverPath}getOrderByRestaurant')
          .replace(queryParameters: queryParams);
    } else {
      uri = Uri.parse('${serverPath}getOrderByRestaurant');
    }

    final response = await http.get(uri, headers: headers).timeout(_timeout);

    print('Get restaurant rankings: $uri');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);

      if (jsonResult['error'] == '0') {
        return {
          'success': true,
          'data': jsonResult['data'],
          'currency': jsonResult['currency'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de la récupération des classements',
        };
      }
    } else {
      return {
        'success': false,
        'error': 'Erreur de connexion (${response.statusCode})',
      };
    }
  } catch (ex) {
    print('Get restaurant rankings error: $ex');
    return {
      'success': false,
      'error': 'Erreur de connexion: ${ex.toString()}',
    };
  }
}

/// Récupérer les produits les plus vendus
Future<Map<String, dynamic>> getTopFoods({
  int limit = 5,
  int? restaurantId,
  String? startDate,
  String? endDate,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('uuid') ?? '';

  try {
    final headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $uid',
    };

    // Construire les paramètres de requête
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
    };

    if (restaurantId != null) {
      queryParams['restaurant_id'] = restaurantId.toString();
    }

    if (startDate != null) {
      queryParams['start_date'] = startDate;
    }

    if (endDate != null) {
      queryParams['end_date'] = endDate;
    }

    Uri uri;
    if (queryParams.isNotEmpty) {
      uri = Uri.parse('${serverPath}getTopFoods')
          .replace(queryParameters: queryParams);
    } else {
      uri = Uri.parse('${serverPath}getTopFoods');
    }

    final response = await http.get(uri, headers: headers).timeout(_timeout);

    print('Get top foods: $uri');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);

      if (jsonResult['error'] == '0') {
        return {
          'success': true,
          'data': jsonResult['data'],
          'summary': jsonResult['summary'],
          'filters': jsonResult['filters'],
          'currency': jsonResult['currency'],
          'user_role': jsonResult['user_role'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de la récupération des produits populaires',
        };
      }
    } else {
      return {
        'success': false,
        'error': 'Erreur de connexion (${response.statusCode})',
      };
    }
  } catch (ex) {
    print('Get top foods error: $ex');
    return {
      'success': false,
      'error': 'Erreur de connexion: ${ex.toString()}',
    };
  }
}

Future<Map<String, dynamic>?> getSelectedStatus(int orderId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  var url =
      "${serverPath}getSelectedStatus"; // Assurez-vous que cette route existe
  var response = await http
      .post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $uid',
            'Content-type': 'application/json',
            'Accept': "application/json",
          },
          body: jsonEncode({
            'commande_id': orderId,
          }))
      .timeout(const Duration(seconds: 30));

  if (response.statusCode == 200) {
    Map<String, dynamic> body = json.decode(response.body);
    return body;
  } else {
    print(response.body);
    return null;
  }
}

Future<dynamic> addRestaurantStatus(
    idRestaurant, content, media_type, media) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uuid') ?? "";
  // var url = '${serverPath}foodsList';
  var url = '${serverPath}addStatus';
  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': "application/json",
    'Authorization': "Bearer $uid",
  };
  var body = json.encoder.convert({
    "restaurant": idRestaurant,
    "content": content,
    "media_type": media_type,
    "media": media
  });
  try {
    var response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: body)
        .timeout(const Duration(seconds: 30));
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);

      if (jsonResult["error"] != "0") return {"error": "1"};
      if (jsonResult["error"] == "0") return {"error": "0"};
    }
  } catch (ex) {}
}

void saveUserDataToSharedPreferences(
    Map<String, dynamic> userData, String password, String uuid, notify) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  print(uuid);

  prefs.setInt('userId', userData['id']);
  prefs.setString('userName', userData['name']);
  prefs.setString('userEmail', userData['email']);
  prefs.setString('userPassword', password);
  prefs.setInt('userRole', userData['role']);
  prefs.setInt('userImageId', userData['imageid'] ?? 0);

  prefs.setString('userPhone', userData['phone']);
  prefs.setString('userAvatar', userData['avatar']);
  prefs.setString('uuid', uuid);

  print(prefs.getString("uuid"));
  prefs.setString('userAddress', userData['address'] ?? "");

  account.okUserEnter(
      userData['name'],
      password,
      userData['avatar'],
      userData['email'],
      uuid,
      userData['phone'],
      notify,
      userData['id'].toString());

  // ... ajoutez d'autres champs que vous souhaitez enregistrer
}
