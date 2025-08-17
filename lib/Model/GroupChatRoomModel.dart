import 'package:whats_up/Model/ChatModel.dart';
import 'package:whats_up/Model/GroupMessageModel.dart';
import 'package:whats_up/Model/User.dart';

class GroupChatRoomModel {
  String? groupId; // ID của nhóm chat
  String? groupName;
  String? groupImageUrl;
  List<User>? participants; // Danh sách thành viên
  List<GroupMessageModel>? messages;
  int? unReadMessNo;
  String? lastMessage;
  String? lastMessageSenderId;
  String? lastMessageSenderName;
  String? lastMessageTimestamp;
  String? timestamp;
  Map<String, String>? draftMessages; // key = userId, value = nội dung draft

  GroupChatRoomModel({

    this.groupId,
    this.groupName,
    this.groupImageUrl,
    this.participants,
    this.messages,
    this.unReadMessNo,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageSenderName,
    this.lastMessageTimestamp,
    this.timestamp,
    this.draftMessages,
  });

  GroupChatRoomModel.fromJson(Map<String, dynamic> json) {

    groupId = json["groupId"];
    groupName = json["groupName"];
    groupImageUrl = json["groupImageUrl"];

    if (json["participants"] is List) {
      participants = (json["participants"] as List)
          .map((e) => User.fromJson(e))
          .toList();
    }

    if (json["messages"] is List) {
      messages = (json["messages"] as List)
          .map((e) => GroupMessageModel.fromJson(e))
          .toList();
    }

    unReadMessNo = json["unReadMessNo"];
    lastMessage = json["lastMessage"];
    lastMessageSenderId = json["lastMessageSenderId"];
    lastMessageTimestamp = json["lastMessageTimestamp"];
    timestamp = json["timestamp"];

    if (json["draftMessages"] is Map) {
      draftMessages = Map<String, String>.from(json["draftMessages"]);
    }
  }

  static List<GroupChatRoomModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(GroupChatRoomModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};

    _data["groupId"] = groupId;
    _data["groupName"] = groupName;
    _data["groupImageUrl"] = groupImageUrl;

    if (participants != null) {
      _data["participants"] = participants!.map((e) => e.toJson()).toList();
    }

    if (messages != null) {
      _data["messages"] = messages!.map((e) => e.toJson()).toList();
    }

    _data["unReadMessNo"] = unReadMessNo;
    _data["lastMessage"] = lastMessage;
    _data["lastMessageSenderId"] = lastMessageSenderId;
    _data["lastMessageSenderName"] = lastMessageSenderName;
    _data["lastMessageTimestamp"] = lastMessageTimestamp;
    _data["timestamp"] = timestamp;

    if (draftMessages != null) {
      _data["draftMessages"] = draftMessages;
    }

    return _data;
  }
}
