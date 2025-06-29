class Message {
  final int id;
  final int orderId;
  final int senderId;
  final int receiverId;
  final String? messageText;
  final String timestamp;
  final String? audioUrl;
  final String? imageUrl;

  Message({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.receiverId,
    this.messageText,
    required this.timestamp,
    this.audioUrl,
    this.imageUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      orderId: json['order_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      messageText: json['message_text'],
      timestamp: json['timestamp'],
      audioUrl: json['audio_url'],
      imageUrl: json['image_url'],
    );
  }
}
