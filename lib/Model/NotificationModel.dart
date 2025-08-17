class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime timestamp;
  final String senderId;
  final String? receiverId;
  final String? groupId;
  final Map<String, dynamic> extraData;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.senderId,
    this.receiverId,
    this.groupId,
    required this.extraData,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'],
      groupId: json['groupId'],
      extraData: Map<String, dynamic>.from(json['extraData'] ?? {}),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'senderId': senderId,
      'receiverId': receiverId,
      'groupId': groupId,
      'extraData': extraData,
      'isRead': isRead,
    };
  }
}
