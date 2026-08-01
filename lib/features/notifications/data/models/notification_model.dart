enum NotificationType { payment, info, success, announcement }

class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'info'),
        orElse: () => NotificationType.info,
      ),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
