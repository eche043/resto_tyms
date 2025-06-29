import 'dart:io';

import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:flutter/material.dart';
import 'package:odrive_restaurant/views/statut/cameraPage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class StatutScreen extends StatefulWidget {
  const StatutScreen({super.key});

  @override
  State<StatutScreen> createState() => _StatutScreenState();
}

class _StatutScreenState extends State<StatutScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    // Afficher un dialogue pour choisir entre Photo ou Vidéo
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context); // Fermer le modal
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    // Appel API pour une image
                    String filePath = image.path;
                    /* ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Envoi de l'image en cours"),
                        backgroundColor: Colors.green,
                      ),
                    ); */
                    await addRestaurantStatus(
                        1, // idRestaurant
                        "", // content
                        "image", // media_type
                        File(filePath) // media (fichier image)
                        );

                    print("Image capturée : ${image.path}");
                    // Afficher ou utiliser l'image capturée
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Enregistrer une vidéo'),
                onTap: () async {
                  Navigator.pop(context); // Fermer le modal
                  final XFile? video =
                      await _picker.pickVideo(source: ImageSource.camera);
                  if (video != null) {
                    String filePath = video.path;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Envoi de la vidéo en cours"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Appel API pour une vidéo
                    await addRestaurantStatus(
                        1, // idRestaurant
                        "", // content
                        "video", // media_type
                        File(filePath) // media (fichier vidéo)
                        );

                    print("Vidéo capturée : ${video.path}");
                    // Afficher ou utiliser la vidéo capturée
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(leadingImageAsset: drawer, title: 'Statuts'),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 10.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(storyIcon),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ),
                title: Text("Mon statut"),
                subtitle: Text("Appuyez pour ajouter un statut"),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Action pour l'édition
              Get.to(() => EditStatusPage(),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 500));
            },
            child: Icon(Icons.edit),
            heroTag: 'edit', // Pour éviter des erreurs de duplication de tag
          ),
          SizedBox(height: 10), // Espacement entre les deux boutons
          FloatingActionButton(
            backgroundColor: appColor,
            onPressed: () {
              // Action pour la caméra
              _openCamera().then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Envoi de la vidéo en cours"),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
            child: Icon(
              Icons.camera_alt,
              color: white,
            ),
            heroTag: 'camera', // Tag unique pour ce bouton
          ),
        ],
      ),
    );
  }
}

class EditStatusPage extends StatefulWidget {
  const EditStatusPage({super.key});

  @override
  State<EditStatusPage> createState() => _EditStatusPageState();
}

class _EditStatusPageState extends State<EditStatusPage> {
  TextEditingController _statutController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.blue, // Fond bleu
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextField(
                    controller: _statutController,
                    style: TextStyle(
                        color: Colors.white, fontSize: 24), // Texte blanc
                    decoration: InputDecoration(
                      hintText: "Saisissez votre texte",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    cursorColor: Colors.green, // Couleur du curseur
                    textAlign:
                        TextAlign.center, // Centrer le texte et le hintText
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                // Vérification si le champ contient du texte
                if (_statutController.text.isNotEmpty) {
                  var response = await addRestaurantStatus(
                      1, _statutController.text, "text", null);
                  if (response["error"] == "0") {
                    Get.back();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Une erreur s'est produite"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  print("Texte envoyé : ${_statutController.text}");
                  // Action supplémentaire si nécessaire, comme envoyer les données au serveur
                } else {
                  // Message ou action si aucun texte n'a été saisi
                  print("Veuillez saisir un texte avant d'envoyer.");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Veuillez saisir un texte."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}
