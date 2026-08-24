import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Stream<List<NotificationEntity>> getNotifications(String recipientId) {
    return _remoteDataSource.getNotifications(recipientId);
  }

  @override
  Future<void> sendNotification(NotificationEntity notification) async {
    final model = NotificationModel(
      id: notification.id,
      recipientId: notification.recipientId,
      senderId: notification.senderId,
      itemId: notification.itemId,
      title: notification.title,
      body: notification.body,
      type: notification.type,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
    );
    await _remoteDataSource.sendNotification(model);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String recipientId) async {
    await _remoteDataSource.markAllAsRead(recipientId);
  }
}
