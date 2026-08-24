import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('notifications');

  /// Streams all notifications for [recipientId] sorted by createdAt DESC.
  Stream<List<NotificationModel>> getNotifications(String recipientId) {
    return _notificationsCollection
        .where('recipientId', isEqualTo: recipientId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map(NotificationModel.fromFirestore)
              .toList();
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notifications;
        });
  }

  /// Sends a new notification document.
  Future<void> sendNotification(NotificationModel notification) async {
    await _notificationsCollection
        .add(notification.toFirestore())
        .timeout(const Duration(seconds: 15));
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection
        .doc(notificationId)
        .update({'isRead': true})
        .timeout(const Duration(seconds: 15));
  }

  /// Marks all notifications for [recipientId] as read.
  Future<void> markAllAsRead(String recipientId) async {
    final query = await _notificationsCollection
        .where('recipientId', isEqualTo: recipientId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit().timeout(const Duration(seconds: 15));
  }
}
