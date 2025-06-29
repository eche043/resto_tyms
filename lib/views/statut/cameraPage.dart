import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class CameraWithGalleryPage extends StatefulWidget {
  @override
  _CameraWithGalleryPageState createState() => _CameraWithGalleryPageState();
}

class _CameraWithGalleryPageState extends State<CameraWithGalleryPage> {
  final ImagePicker _picker = ImagePicker();
  List<AssetEntity> galleryItems = [];

  @override
  void initState() {
    super.initState();
    _openCamera();
    _loadGalleryItems();
  }

  Future<void> _loadGalleryItems() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // Accès autorisé, charger les images
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
      List<AssetEntity> media = await albums[0].getAssetListPaged(
          page: 0, size: 100); // Récupère 100 premiers éléments
      setState(() {
        galleryItems = media;
      });
    } else {
      // Accès refusé
      PhotoManager.openSetting();
    }
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      print("Image capturée : ${image.path}");
      // Ici, tu peux afficher l'image capturée
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        title: Text('Caméra avec Galerie'),
      ), */
      body: Column(
        children: [
          /* Expanded(
            child: Center(
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 50),
                onPressed: _openCamera, // Ouvre la caméra
              ),
            ),
          ), */
          Container(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: galleryItems.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Uint8List?>(
                  future: galleryItems[index]
                      .thumbnailDataWithSize(ThumbnailSize(150, 150)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
