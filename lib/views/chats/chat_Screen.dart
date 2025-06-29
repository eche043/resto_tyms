import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/const/colors.dart';
import 'package:odrive_restaurant/common/const/images.dart';
import 'package:odrive_restaurant/services/message_provider.dart';
import 'package:odrive_restaurant/common/widgets/appbar.dart';
import 'package:odrive_restaurant/common/widgets/bg_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final int orderId;
  final int currentUserId;
  final int receiverId;

  ChatScreen({
    super.key,
    required this.orderId,
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MessageProvider>(context, listen: false)
        .fetchMessages(widget.orderId));
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      await _recorder.startRecorder(toFile: 'audio_note.aac');
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    String? path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    if (path != null) {
      _uploadAudio(File(path));
    }
  }

  Future<void> _uploadAudio(File file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";

    var request =
        http.MultipartRequest('POST', Uri.parse('${serverPath}uploadAudio'));
    request.headers['Authorization'] = "Bearer $uid";
    request.files.add(await http.MultipartFile.fromPath('audio', file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      print("responseData");
      print(responseData);
      print("responseData");
      var jsonData = json.decode(responseData);
      String audioUrl = jsonData['audio_url'];
      await Provider.of<MessageProvider>(context, listen: false)
          .addAudioMessage(widget.orderId, widget.receiverId, audioUrl);
    } else {
      print("response error");
      print(response);
      // Handle the error
      print("response error");
      var responseData = await response.stream.bytesToString();
      print(responseData);
      print('Failed to upload audio: ${response.statusCode}');
    }
  }

  void playAudio(String url) async {
    await audioPlayer.play(UrlSource(url));
  }

  Future<void> _pickImage(ImageSource source) async {
    print("pick image");
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      print("picker image__________________-------___________");
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File file) async {
    print("upload image__________________-------___________");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uuid') ?? "";

    var request = http.MultipartRequest(
        'POST', Uri.parse('${serverPath}messageUploadImage'));
    request.headers['Authorization'] = "Bearer $uid";
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      print(jsonData);
      String imageUrl = jsonData['image_url'];
      await Provider.of<MessageProvider>(context, listen: false)
          .addImageMessage(widget.orderId, widget.receiverId, imageUrl);
    } else {
      print('Failed to upload image: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(
            smsImageAsset: mailIcon,
            leadingImageAsset: drawer,
            title: 'Messages',
            notificationImageAsset: notificationIcon,
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 20.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Consumer<MessageProvider>(
                      builder: (context, provider, _) {
                        if (provider.messages.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return ListView.builder(
                          itemCount: provider.messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            var message = provider.messages[index];
                            bool isSender =
                                message.senderId == widget.currentUserId;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: isSender
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isSender) ...[
                                    const CircleAvatar(),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: isSender
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isSender ? white : appColor,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: message.audioUrl != null
                                              ? IconButton(
                                                  icon: Icon(Icons.play_arrow),
                                                  onPressed: () {
                                                    // Play the audio note
                                                    playAudio(
                                                        message.audioUrl!);
                                                  },
                                                )
                                              : message.imageUrl != null
                                                  ? Image.network(
                                                      message.imageUrl!,
                                                      width: 100,
                                                      height: 100,
                                                    )
                                                  : Text(
                                                      message.messageText ?? '',
                                                      style: TextStyle(
                                                        color: isSender
                                                            ? blackColor
                                                            : white,
                                                        fontSize: 13.0,
                                                      ),
                                                      softWrap: true,
                                                    ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Icon(
                                              Icons.done_all,
                                              size: 16,
                                              color: Colors.grey,
                                            ), // Dummy double tick
                                            const SizedBox(width: 4),
                                            Text(
                                              message.timestamp,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSender) ...[
                                    const SizedBox(width: 8),
                                    const CircleAvatar(radius: 20),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            _pickImage(ImageSource.camera);
                          },
                          icon: const ImageIcon(AssetImage(cameraIcon)),
                        ),
                        IconButton(
                          onPressed: () {
                            _pickImage(ImageSource.gallery);
                          },
                          icon: const Icon(Icons.photo_library),
                        ),
                        IconButton(
                          onPressed:
                              _isRecording ? _stopRecording : _startRecording,
                          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  40), // Set border radius
                              color: Colors.white, // Set background color
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: TextFormField(
                                      controller: messageController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter message',
                                        hintStyle: TextStyle(
                                          color: fontGrey.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    String messageText = messageController.text;
                                    messageController.clear();
                                    await Provider.of<MessageProvider>(context,
                                            listen: false)
                                        .addMessage(widget.orderId,
                                            widget.receiverId, messageText);
                                    messageController.clear();
                                  },
                                  icon: const ImageIcon(AssetImage(sendIcon)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
