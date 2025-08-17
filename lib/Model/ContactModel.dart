enum ContactStatus {
  pending,    // Chờ duyệt
  accepted,   // Đã chấp nhận
  rejected    // Đã từ chối
}

class Contact {
  final String id;
  final String senderId;     // Người gửi lời mời
  final String receiverId;   // Người nhận lời mời
  final DateTime createdAt;
  ContactStatus status;

  Contact({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    this.status = ContactStatus.pending,
  });

  // Convert từ Map (Firebase hoặc API)
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      createdAt: DateTime.parse(json['createdAt']),
      status: ContactStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ContactStatus.pending,
      ),
    );
  }

  // Convert sang Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
    };
  }
}
