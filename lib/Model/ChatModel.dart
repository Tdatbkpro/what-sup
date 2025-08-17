class FileInfo {
  final String fileName;
  final int fileSize;
  final String fileUrl;

  FileInfo({
    required this.fileName,
    required this.fileSize,
    required this.fileUrl,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      fileUrl: json['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileSize': fileSize,
      'fileUrl': fileUrl,
    };
  }
}
class ReplyInfo {
  final String? id;
  final String? content;

  ReplyInfo({this.id, this.content});

  factory ReplyInfo.fromJson(Map<String, dynamic> json) {
    return ReplyInfo(
      id: json['id'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
    };
  }
}

class ChatModel {
  String? id;
  String? message;
  String? senderName;
  String? senderId;
  String? receiverId;
  String? timestamp;
  String? readStatus;
  List<String>? imageUrls;
  String? videoUrl;
  String? audioUrl;
  FileInfo? document;
  Map<String, String>? reactions;
  ReplyInfo? replies; // ✅ Dùng class thay vì record
  String? mapUrl;
  String? businessId;
  List<String>? deletedFor;
bool? isRecalled;

  ChatModel({
    this.id,
    this.message,
    this.senderName,
    this.senderId,
    this.receiverId,
    this.timestamp,
    this.readStatus,
    this.imageUrls,
    this.videoUrl,
    this.audioUrl,
    this.document,
    this.reactions,
    this.replies,
    this.mapUrl,
    this.businessId,
    this.deletedFor,
    this.isRecalled,
  });

  ChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    senderName = json['senderName'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    timestamp = json['timestamp'];
    readStatus = json['readStatus'];
    imageUrls = json['imageUrls'] == null ? null : List<String>.from(json['imageUrls']);
    videoUrl = json['videoUrl'];
    audioUrl = json['audioUrl'];
    document = json['document'] != null ? FileInfo.fromJson(json['document']) : null;
    reactions = json['reactions'] != null ? Map<String, String>.from(json['reactions']) : null;
    deletedFor = json['deletedFor'] != null ? List<String>.from(json['deletedFor']) : null;
  isRecalled = json['isRecalled'];

    // ✅ replies
    replies = json['replies'] != null ? ReplyInfo.fromJson(json['replies']) : null;

    mapUrl = json['mapUrl'];
    businessId = json['businessId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data['id'] = id;
    _data['message'] = message;
    _data['senderName'] = senderName;
    _data['senderId'] = senderId;
    _data['receiverId'] = receiverId;
    _data['timestamp'] = timestamp;
    _data['readStatus'] = readStatus;
    _data['imageUrls'] = imageUrls;
    _data['videoUrl'] = videoUrl;
    _data['audioUrl'] = audioUrl;
    _data['document'] = document?.toJson();
    _data['reactions'] = reactions;

    // ✅ replies
    if (replies != null) {
      _data['replies'] = replies!.toJson();
    }

    _data['mapUrl'] = mapUrl;
    _data['businessId'] = businessId;
    _data['deletedFor'] = deletedFor;
    _data['isRecalled'] = isRecalled;

    return _data;
  }
}
