import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String? profileImageUrl;
  String? fullName;
  String? email;
  String? phone;

  var nameController = TextEditingController();
  var numberController = TextEditingController();
  var emailController = TextEditingController();

  var currentPasswordController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _formKey1 = GlobalKey<FormState>();
  bool _load = false;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  int course = 0;

  @override
  void initState() {
    super.initState();
    _loadUserDetail();
    _loadCourse();
  }

  Future<void> _loadUserDetail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('userAvatar');
      fullName = prefs.getString('userName');
      email = prefs.getString('userEmail');
      phone = prefs.getString('userPhone');

      nameController.text = fullName ?? "";
      numberController.text = phone ?? "";
      emailController.text = email ?? "";
    });
  }

  Future<void> _loadCourse() async {
    var response = await getCourse();
    if (response["error"] == '0') {
      setState(() {
        course = response["course"];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    var prefs = await SharedPreferences.getInstance();

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      var response = await uploadAvatar(_image!);
      if (response["ret"] == true) {
        setState(() {
          profileImageUrl = response["avatar"];
        });
        prefs.setString("userAvatar", response["avatar"]);
      } else {
        Fluttertoast.showToast(msg: "Erreur lors de l'enregistrement");
      }
    }
  }

  void showChangePasswordDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changer le mot de passe'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                customTextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  hint: 'Mot de passe actuel',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe actuel';
                    }
                    return null;
                  },
                ),
                8.heightBox,
                customTextField(
                  controller: newPasswordController,
                  obscureText: true,
                  hint: 'Nouveau mot de passe',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nouveau mot de passe';
                    }
                    return null;
                  },
                ),
                8.heightBox,
                customTextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  hint: 'Confirmer le nouveau mot de passe',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre nouveau mot de passe';
                    }
                    if (value != newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
              style: TextButton.styleFrom(
                foregroundColor: Colors
                    .red, // Changez cette couleur pour la couleur souhaitée
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  // Appeler la fonction pour changer le mot de passe
                  /* changePassword(
                  _currentPasswordController.text,
                  _newPasswordController.text,
                ); */
                  var response = await changePassword(
                      currentPasswordController.text,
                      newPasswordController.text);
                  if (response["error"] == "0") {
                    Fluttertoast.showToast(msg: "Mot de passe modifié");
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(msg: "Une erreur s'est produite");
                  }
                }
              },
              child: Text('Enregistrer'),
              style: TextButton.styleFrom(
                foregroundColor:
                    appColor, // Changez cette couleur pour la couleur souhaitée
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const CustomDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BgContainer(),
          const CustomAppBar(
            leadingImageAsset: drawer,
            title: 'Profile',
            notificationImageAsset: notificationIcon,
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 30.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(150)),
                          child: Stack(
                            children: [
                              InkWell(
                                child: Positioned(
                                  top: 110,
                                  left: 100,
                                  child: CircleAvatar(
                                    backgroundColor: appColor,
                                    child: Image.asset(
                                      editIcon,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  print("editttttttttt");
                                  _pickImage();
                                },
                              ),
                              Center(
                                child: CircleAvatar(
                                  maxRadius: 40,
                                  backgroundColor: white,
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(
                                              "$serverImages$profileImageUrl")
                                          as ImageProvider<Object>
                                      : const AssetImage(dpIcon)
                                          as ImageProvider<Object>,
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                  Form(
                    key: _formKey1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          boldText(
                            text: 'Full Name',
                            color: fontGrey.withOpacity(0.7),
                            size: 16.0,
                          ),
                          8.heightBox,
                          customTextField(
                            hint: '$fullName',
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          8.heightBox,
                          boldText(
                            text: 'Email',
                            color: fontGrey.withOpacity(0.7),
                            size: 16.0,
                          ),
                          8.heightBox,
                          customTextField(
                            hint: '$email',
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              } else if (!value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          8.heightBox,
                          boldText(
                            text: 'Phone Number',
                            color: fontGrey.withOpacity(0.7),
                            size: 16.0,
                          ),
                          8.heightBox,
                          customTextField(
                            hint: '$phone',
                            controller: numberController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          /* 8.heightBox,
                          boldText(
                              text: 'Date of birth',
                              color: fontGrey.withOpacity(0.7),
                              size: 16.0),
                          8.heightBox,
                          customTextField(
                            hint: '18/02/2000',
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: const Icon(
                                Icons.calendar_month_outlined,
                                color: blackColor,
                                size: 24,
                              ),
                            ),
                          ), */
                          25.heightBox,
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.9,
                                    48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(
                                    color: blackColor.withOpacity(0.3),
                                    width: 1),
                                backgroundColor: Colors.transparent,
                                elevation: 0.0,
                                padding: const EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                showChangePasswordDialog(context);
                              },
                              child: 'Change Password'
                                  .text
                                  .overflow(TextOverflow.ellipsis)
                                  .color(blackColor)
                                  .normal
                                  .size(14)
                                  .make(),
                            ),
                          ),
                          12.heightBox,
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.9,
                                    48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: appColor,
                                padding: const EdgeInsets.all(12.0),
                              ),
                              onPressed: () async {
                                if (_formKey1.currentState?.validate() ??
                                    false) {
                                  if (!_load) {
                                    setState(() {
                                      _load = true;
                                    });
                                    var prefs =
                                        await SharedPreferences.getInstance();
                                    dynamic response = await changeProfile(
                                        nameController.text,
                                        emailController.text,
                                        numberController.text);
                                    print(response);
                                    if (response["error"] == "0") {
                                      Fluttertoast.showToast(
                                          msg: "Profile modifié");
                                      prefs.setString(
                                          'userName', nameController.text);
                                      prefs.setString(
                                          'userEmail', emailController.text);
                                      prefs.setString(
                                          'userPhone', numberController.text);
                                      // Navigator.pop(context);
                                    } else if (response["error"] == "1") {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Nom complet et numéro obligatoire",
                                          backgroundColor: red,
                                          textColor: white);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Erreur vérifiez votre connexion",
                                          backgroundColor: red,
                                          textColor: white);
                                    }
                                    setState(() {
                                      _load = false;
                                    });
                                  }
                                }
                              },
                              child: !_load
                                  ? 'Save'
                                      .text
                                      .overflow(TextOverflow.ellipsis)
                                      .color(white)
                                      .normal
                                      .size(18)
                                      .make()
                                  : CircularProgressIndicator(
                                      color: white,
                                    ),
                            ),
                          ),
                          10.heightBox
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
