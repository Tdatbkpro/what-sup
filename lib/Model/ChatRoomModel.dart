import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/User.dart';

class ChatRoomModel {
  String? id;
  User? sender;
  User? receiver;
  List<ChatModel>? messages;
  List<String>? participants;
  int? unReadMessNo;
  String? lastMessage;
  String? lastMessageTimestamp;
  String? timestamp;
  Map<String, String>? draftMessages; // 👈 Thay đổi từ String sang Map

  ChatRoomModel({
    this.id,
    this.sender,
    this.receiver,
    this.messages,
    this.participants,
    this.unReadMessNo,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.timestamp,
    this.draftMessages, // 👈 Thêm vào constructor
  });

  ChatRoomModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    sender = json["sender"] != null ? User.fromJson(json["sender"]) : null;
    receiver = json["receiver"] != null ? User.fromJson(json["receiver"]) : null;
    if (json["messages"] is List) {
      messages = (json["messages"] as List)
          .map((e) => ChatModel.fromJson(e))
          .toList();
    }
    if (json["participants"] is List) {
      participants = List<String>.from(json["participants"]);
    }
    unReadMessNo = json["unReadMessNo"];
    lastMessage = json["lastMessage"];
    lastMessageTimestamp = json["lastMessageTimestamp"];
    timestamp = json["timestamp"];

    if (json["draftMessages"] is Map) {
      draftMessages = Map<String, String>.from(json["draftMessages"]);
    }
  }

  static List<ChatRoomModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(ChatRoomModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    if (sender != null) _data["sender"] = sender?.toJson();
    if (receiver != null) _data["receiver"] = receiver?.toJson();
    if (messages != null) {
      _data["messages"] = messages!.map((e) => e.toJson()).toList();
    }
    if (participants != null) _data["participants"] = participants;
    _data["unReadMessNo"] = unReadMessNo;
    _data["lastMessage"] = lastMessage;
    _data["lastMessageTimestamp"] = lastMessageTimestamp;
    _data["timestamp"] = timestamp;
    if (draftMessages != null) _data["draftMessages"] = draftMessages; // 👈
    return _data;
  }
}
