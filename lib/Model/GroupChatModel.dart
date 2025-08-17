import 'package:whats_up/Model/User.dart';

class GroupChatModel {
  String? id;
  String? name;
  String? description;
  String? profileUrl;             // Avatar nhóm
  String? groupCoverUrl;          // Ảnh bìa nhóm
  String? groupType;              // public | private
  String? createAt;
  String? createBy;
  List<User>? members;            // Danh sách thành viên
  Map<String, String>? memberRoles; // userId: role ("admin", "member", ...)
  List<String>? statusMembers;       // online/offline theo userId
  String? lastMessage;
  String? lastMessageTime;
  int? unReadCount;
  String? timeStamp;
  List<User>? membersSeen;
  bool? isMuted;                  // Tắt thông báo cho nhóm này
  Map<String, dynamic>? pinnedMessage; // Tin nhắn được ghim
  

  // --- Các trường mới ---
  String? lastMessageSenderId;
  String? lastMessageSenderName;
  String? lastMessageTimestamp;
  String? timestamp;
  Map<String, String>? draftMessages;

  GroupChatModel({
    this.id,
    this.name,
    this.description,
    this.profileUrl,
    this.groupCoverUrl,
    this.groupType,
    this.createAt,
    this.createBy,
    this.members,
    this.memberRoles,
    this.statusMembers,
    this.lastMessage,
    this.lastMessageTime,
    this.unReadCount,
    this.timeStamp,
    this.membersSeen,
    this.isMuted,
    this.pinnedMessage,
    this.lastMessageSenderId,
    this.lastMessageSenderName,
    this.lastMessageTimestamp,
    this.timestamp,
    this.draftMessages,
  });

  GroupChatModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    description = json["description"];
    profileUrl = json["profileUrl"];
    groupCoverUrl = json["groupCoverUrl"];
    groupType = json["groupType"];
    createAt = json["createAt"];
    createBy = json["createBy"];

    if (json["members"] != null) {
      members = List<User>.from(json["members"].map((x) => User.fromJson(x)));
    }

    memberRoles = json["memberRoles"]?.cast<String, String>();
    statusMembers = json["statusMembers"]?.cast<String>();
    lastMessage = json["lastMessage"];
    lastMessageTime = json["lastMessageTime"];
    unReadCount = json["unReadCount"];
    timeStamp = json["timeStamp"];

    if (json["membersSeen"] != null) {
      membersSeen = List<User>.from(json["membersSeen"].map((x) => User.fromJson(x)));
    }

    isMuted = json["isMuted"];
    pinnedMessage = json["pinnedMessage"];

    // --- Trường mới ---
    lastMessageSenderId = json["lastMessageSenderId"];
    lastMessageSenderName = json["lastMessageSenderName"];
    lastMessageTimestamp = json["lastMessageTimestamp"];
    timestamp = json["timestamp"];
    draftMessages = json["draftMessages"]?.cast<String, String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data["id"] = id;
    data["name"] = name;
    data["description"] = description;
    data["profileUrl"] = profileUrl;
    data["groupCoverUrl"] = groupCoverUrl;
    data["groupType"] = groupType;
    data["createAt"] = createAt;
    data["createBy"] = createBy;

    if (members != null) {
      data["members"] = members!.map((x) => x.toJson()).toList();
    }

    data["memberRoles"] = memberRoles;
    data["statusMembers"] = statusMembers;
    data["lastMessage"] = lastMessage;
    data["lastMessageTime"] = lastMessageTime;
    data["unReadCount"] = unReadCount;
    data["timeStamp"] = timeStamp;

    if (membersSeen != null) {
      data["membersSeen"] = membersSeen!.map((x) => x.toJson()).toList();
    }

    data["isMuted"] = isMuted;
    data["pinnedMessage"] = pinnedMessage;

    // --- Trường mới ---
    data["lastMessageSenderId"] = lastMessageSenderId;
    data["lastMessageSenderName"] = lastMessageSenderName;
    data["lastMessageTimestamp"] = lastMessageTimestamp;
    data["timestamp"] = timestamp;
    data["draftMessages"] = draftMessages;

    return data;
  }
}
