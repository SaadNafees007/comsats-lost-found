import 'package:equatable/equatable.dart';

enum NotificationType {
  claimSubmitted,
  claimAccepted,
  claimRejected,
  itemResolved,
  system,
}

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.itemId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String recipientId;
  final String senderId;
  final String itemId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    recipientId,
    senderId,
    itemId,
    title,
    body,
    type,
    isRead,
    createdAt,
  ];
}
