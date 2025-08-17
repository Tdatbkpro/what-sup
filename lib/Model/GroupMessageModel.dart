import 'package:whats_up/Model/ChatModel.dart';

class GroupMessageModel {
  String? id;
  String? groupId;
  String? senderId;
  String? senderName;
  String? senderAvatar;

  String? message;
  String? type;

  List<String>? imageUrls;
  String? videoUrl;
  String? audioUrl;
  FileInfo? document;

  String? timestamp;
  List<String>? seenBy;

  bool? isPinned;
  String? pinnedBy;
  String? pinnedAt;

  String? replyToMessageId;
  List<String>? mentions;

  String? mapUrl;
  String? businessId;

  Map<String, String>? reactions;
  List<String>? deletedFor;

  ReplyInfo? replies;

  GroupMessageModel({
    this.id,
    this.groupId,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    this.message,
    this.type = "text",
    this.imageUrls,
    this.videoUrl,
    this.audioUrl,
    this.document,
    this.timestamp,
    this.seenBy,
    this.isPinned = false,
    this.pinnedBy,
    this.pinnedAt,
    this.replyToMessageId,
    this.mentions,
    this.reactions,
    this.deletedFor,
    this.replies,
    this.mapUrl,
    this.businessId,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    return GroupMessageModel(
      id: json['id'],
      groupId: json['groupId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      message: json['message'],
      type: json['type'],
      imageUrls: (json['imageUrls'] as List?)?.cast<String>(),
      videoUrl: json['videoUrl'],
      audioUrl: json['audioUrl'],
      document: json['document'] != null ? FileInfo.fromJson(json['document']) : null,
      timestamp: json['timestamp'],
      seenBy: (json['seenBy'] as List?)?.cast<String>(),
      isPinned: json['isPinned'] ?? false,
      pinnedBy: json['pinnedBy'],
      pinnedAt: json['pinnedAt'],
      mapUrl: json['mapUrl'],
      businessId: json['businessId'],
      replyToMessageId: json['replyToMessageId'],
      mentions: (json['mentions'] as List?)?.cast<String>(),
      reactions: json['reactions'] != null ? Map<String, String>.from(json['reactions']) : null,
      deletedFor: (json['deletedFor'] as List?)?.cast<String>(),
      replies: json['replies'] != null ? ReplyInfo.fromJson(json['replies']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = {};
    _data['id'] = id;
    _data['groupId'] = groupId;
    _data['senderId'] = senderId;
    _data['senderName'] = senderName;
    _data['senderAvatar'] = senderAvatar;
    _data['message'] = message;
    _data['type'] = type;
    _data['imageUrls'] = imageUrls;
    _data['videoUrl'] = videoUrl;
    _data['audioUrl'] = audioUrl;
    _data['document'] = document?.toJson();
    _data['timestamp'] = timestamp;
    _data['seenBy'] = seenBy;
    _data['isPinned'] = isPinned;
    _data['pinnedBy'] = pinnedBy;
    _data['pinnedAt'] = pinnedAt;
    _data['replyToMessageId'] = replyToMessageId;
    _data['mentions'] = mentions;
    _data['reactions'] = reactions;
    _data['deletedFor'] = deletedFor;
    _data['mapUrl'] = mapUrl;
    _data['businessId'] = businessId;
 if (replies != null) {
      _data['replies'] = replies!.toJson();
    }

    return _data;
  }

  ChatModel convertGroupMessageToChatModel(GroupMessageModel groupMessage) {
  return ChatModel(
    id: groupMessage.id,
    message: groupMessage.message,
    senderName: groupMessage.senderName,
    senderId: groupMessage.senderId,
    receiverId: groupMessage.groupId,
    timestamp: groupMessage.timestamp,
    readStatus: groupMessage.seenBy?.contains(groupMessage.senderId ?? '') == true
        ? 'read'
        : 'unread',
    imageUrls: groupMessage.imageUrls,
    videoUrl: groupMessage.videoUrl,
    audioUrl: groupMessage.audioUrl,
    document: groupMessage.document,
    reactions: groupMessage.reactions,
    replies: groupMessage.replies,
    mapUrl: groupMessage.mapUrl,
    businessId: groupMessage.businessId,
  );
}

}
