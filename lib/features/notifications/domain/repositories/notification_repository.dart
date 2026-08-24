import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> getNotifications(String recipientId);
  Future<void> sendNotification(NotificationEntity notification);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String recipientId);
}
