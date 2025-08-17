import 'package:whats_up/Model/ChatRoomModel.dart';

class ChatRoomWithCount {
  final ChatRoomModel room;
  final int unreadCount;

  ChatRoomWithCount({required this.room, required this.unreadCount});
}
