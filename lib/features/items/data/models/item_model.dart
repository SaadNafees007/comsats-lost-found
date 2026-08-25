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
    try {
      final data = document.data() ?? <String, dynamic>{};

      DateTime parsedDate = DateTime.now();
      if (data['date'] != null) {
        if (data['date'] is Timestamp) {
          parsedDate = (data['date'] as Timestamp).toDate();
        } else if (data['date'] is String) {
          parsedDate = DateTime.tryParse(data['date'] as String) ?? DateTime.now();
        }
      }

      DateTime? parsedCreatedAt;
      if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
        parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
      }

      DateTime? parsedUpdatedAt;
      if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
        parsedUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
      }

      List<String> parsedUrls = [];
      if (data['imageUrls'] != null) {
        if (data['imageUrls'] is List) {
          parsedUrls = (data['imageUrls'] as List)
              .map((e) => e.toString())
              .toList();
        }
      }

      return ItemModel(
        id: document.id,
        ownerId: data['ownerId'] as String? ?? '',
        type: _itemTypeFromString(data['type'] as String?),
        title: data['title'] as String? ?? '',
        description: data['description'] as String? ?? '',
        category: data['category'] as String? ?? '',
        location: data['location'] as String? ?? '',
        date: parsedDate,
        imageUrls: parsedUrls,
        status: _itemStatusFromString(data['status'] as String?),
        createdAt: parsedCreatedAt,
        updatedAt: parsedUpdatedAt,
      );
    } catch (e) {
      // Return a safe fallback instead of throwing and crashing the entire Stream
      return ItemModel(
        id: document.id,
        ownerId: '',
        type: ItemType.lost,
        title: 'Error Loading Item',
        description: 'Failed to parse item document: $e',
        category: '',
        location: '',
        date: DateTime.now(),
        imageUrls: const [],
        status: ItemStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
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
