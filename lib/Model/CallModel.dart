class CallModel {
  String? id;
  String? receiverName;
  String? callerPic;
  String? callerName;
  String? callerUid;
  String? callerEmail;
  String? receiverPic;
  String? receiverUid;
  String? receiverEmail;
  String? status;
  String? type; // "audio" hoặc "video"

  CallModel({
    this.id,
    this.receiverName,
    this.callerPic,
    this.callerUid,
    this.callerEmail,
    this.receiverPic,
    this.receiverUid,
    this.receiverEmail,
    this.callerName,
    this.status,
    this.type,
  });

  CallModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["receiverName"] is String) {
      receiverName = json["receiverName"];
    }
    if (json["callerPic"] is String) {
      callerPic = json["callerPic"];
    }
    if (json["callerUid"] is String) {
      callerUid = json["callerUid"];
    }
    if (json["callerEmail"] is String) {
      callerEmail = json["callerEmail"];
    }
    if (json["callerName"] is String) {
      callerName = json["callerName"];
    }
    if (json["receiverPic"] is String) {
      receiverPic = json["receiverPic"];
    }
    if (json["receiverUid"] is String) {
      receiverUid = json["receiverUid"];
    }
    if (json["receiverEmail"] is String) {
      receiverEmail = json["receiverEmail"];
    }
    if (json["status"] is String) {
      status = json["status"];
    }
    if (json["type"] is String) {
      type = json["type"];
    }
  }

  static List<CallModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(CallModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["receiverName"] = receiverName;
    _data["callerPic"] = callerPic;
    _data["callerUid"] = callerUid;
    _data["callerEmail"] = callerEmail;
    _data["callerName"] = callerName;
    _data["receiverPic"] = receiverPic;
    _data["receiverUid"] = receiverUid;
    _data["receiverEmail"] = receiverEmail;
    _data["status"] = status;
    _data["type"] = type;
    return _data;
  }
}
