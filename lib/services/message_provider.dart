import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/model/message.dart';

class MessageProvider with ChangeNotifier {
  List<Message> messages = [];

  MessageProvider();

  Future<void> fetchMessages(int orderId) async {
    messages = await getMessages(orderId);
    print("messages______________-------________-");
    print(messages);
    notifyListeners();
  }

  Future<void> addMessage(
      int orderId, int receiverId, String messageText) async {
    await sendMessage(orderId, receiverId, messageText);
    await fetchMessages(orderId);
  }

  Future<void> addAudioMessage(
      int orderId, int receiverId, String audioUrl) async {
    await sendAudioMessage(orderId, receiverId, audioUrl);
    await fetchMessages(orderId);
  }

  Future<void> addImageMessage(
      int orderId, int receiverId, String imageUrl) async {
    print(orderId);
    print(receiverId);
    await sendImageMessage(orderId, receiverId, imageUrl);
    await fetchMessages(orderId);
  }
}
