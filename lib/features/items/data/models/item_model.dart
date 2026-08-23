import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.ownerId,
    required super.type,
    required super.title,
    required super.description,
    required super.category,
    required super.location,
    required super.date,
    required super.imageUrls,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    final dateTimestamp = data['date'] as Timestamp?;

    final createdAtTimestamp = data['createdAt'] as Timestamp?;

    final updatedAtTimestamp = data['updatedAt'] as Timestamp?;

    return ItemModel(
      id: document.id,
      ownerId: data['ownerId'] as String? ?? '',
      type: _itemTypeFromString(data['type'] as String?),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: dateTimestamp?.toDate() ?? DateTime.now(),
      imageUrls: List<String>.from(
        data['imageUrls'] as List<dynamic>? ?? <dynamic>[],
      ),
      status: _itemStatusFromString(data['status'] as String?),
      createdAt: createdAtTimestamp?.toDate(),
      updatedAt: updatedAtTimestamp?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'type': type.name,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'date': Timestamp.fromDate(date),
      'imageUrls': imageUrls,
      'status': status.name,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static ItemType _itemTypeFromString(String? value) {
    switch (value) {
      case 'found':
        return ItemType.found;

      case 'lost':
      default:
        return ItemType.lost;
    }
  }

  static ItemStatus _itemStatusFromString(String? value) {
    switch (value) {
      case 'claimed':
        return ItemStatus.claimed;

      case 'resolved':
        return ItemStatus.resolved;

      case 'active':
      default:
        return ItemStatus.active;
    }
  }
}
