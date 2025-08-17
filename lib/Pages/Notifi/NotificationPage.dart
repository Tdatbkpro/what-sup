import 'package:flutter/material.dart';
import 'package:whats_up/Model/NotificationModel.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> notifications = [];

  void _handleReceive(AppNotification noti) {
    setState(() {
      notifications.insert(0, noti); // thêm đầu danh sách
    });
  }
  void sendNotification(AppNotification notification, Function(AppNotification) onReceive) {
  Future.delayed(Duration(milliseconds: 500), () {
    onReceive(notification); // truyền về nơi nhận
  });
}

  void _sendFriendRequest() {
    final noti = AppNotification(
      id: UniqueKey().toString(),
      type: "friend_request",
      title: "Yêu cầu kết bạn",
      body: "Minh đã gửi yêu cầu kết bạn",
      timestamp: DateTime.now(),
      senderId: "user123",
      receiverId: "user456",
      extraData: {"fromUserName": "Minh"},
    );
    sendNotification(noti, _handleReceive);
  }

  void _sendGroupInvite() {
    final noti = AppNotification(
      id: UniqueKey().toString(),
      type: "group_invite",
      title: "Mời vào nhóm",
      body: "Bạn được mời vào nhóm Flutter Devs",
      timestamp: DateTime.now(),
      senderId: "user123",
      receiverId: "user456",
      groupId: "group789",
      extraData: {"groupName": "Flutter Devs"},
    );
    sendNotification(noti, _handleReceive);
  }

  void _sendCallIncoming() {
    final noti = AppNotification(
      id: UniqueKey().toString(),
      type: "call_incoming",
      title: "Cuộc gọi đến",
      body: "Minh đang gọi bạn...",
      timestamp: DateTime.now(),
      senderId: "user123",
      receiverId: "user456",
      extraData: {"callType": "video"},
    );
    sendNotification(noti, _handleReceive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông báo"),
        actions: [
          IconButton(icon: Icon(Icons.person_add), onPressed: _sendFriendRequest),
          IconButton(icon: Icon(Icons.group_add), onPressed: _sendGroupInvite),
          IconButton(icon: Icon(Icons.call), onPressed: _sendCallIncoming),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final noti = notifications[index];
          return ListTile(
            tileColor: !noti.isRead ? Colors.blue.withOpacity(0.05) : null,
            leading: Icon(_getIcon(noti.type), color: noti.isRead ? Colors.grey : Colors.blue),
            title: Text(noti.title),
            subtitle: Text(noti.body),
            trailing: !noti.isRead
                ? Icon(Icons.circle, size: 10, color: Colors.red)
                : null,
            onTap: () {
              setState(() => noti.isRead = true);
              _handleAction(noti);
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "friend_request": return Icons.person_add;
      case "group_invite": return Icons.group_add;
      case "call_incoming": return Icons.call;
      default: return Icons.notifications;
    }
  }

  void _handleAction(AppNotification noti) {
    switch (noti.type) {
      case "friend_request":
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xử lý kết bạn")));
        break;
      case "group_invite":
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mở trang nhóm")));
        break;
      case "call_incoming":
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Cuộc gọi đến"),
            content: Text("Bạn có muốn nhận cuộc gọi không?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Từ chối")),
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Nhận")),
            ],
          ),
        );
        break;
    }
  }
}
