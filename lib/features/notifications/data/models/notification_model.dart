import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    required super.senderId,
    required super.itemId,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    try {
      final data = document.data() ?? <String, dynamic>{};
      
      DateTime? parsedCreatedAt;
      if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
        parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
      }

      return NotificationModel(
        id: document.id,
        recipientId: data['recipientId'] as String? ?? '',
        senderId: data['senderId'] as String? ?? '',
        itemId: data['itemId'] as String? ?? '',
        title: data['title'] as String? ?? '',
        body: data['body'] as String? ?? '',
        type: _typeFromString(data['type'] as String?),
        isRead: data['isRead'] as bool? ?? false,
        createdAt: parsedCreatedAt ?? DateTime.now(),
      );
    } catch (e) {
      return NotificationModel(
        id: document.id,
        recipientId: '',
        senderId: '',
        itemId: '',
        title: 'Error Loading Notification',
        body: 'Failed to parse notification: $e',
        type: NotificationType.system,
        isRead: true,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'itemId': itemId,
      'title': title,
      'body': body,
      'type': type.name,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static NotificationType _typeFromString(String? value) {
    switch (value) {
      case 'claimSubmitted':
        return NotificationType.claimSubmitted;
      case 'claimAccepted':
        return NotificationType.claimAccepted;
      case 'claimRejected':
        return NotificationType.claimRejected;
      case 'itemResolved':
        return NotificationType.itemResolved;
      case 'system':
      default:
        return NotificationType.system;
    }
  }
}
