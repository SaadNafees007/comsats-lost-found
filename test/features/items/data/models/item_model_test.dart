import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comsats_lost_found/features/items/data/models/item_model.dart';
import 'package:comsats_lost_found/features/items/domain/entities/item_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItemModel', () {
    final now = DateTime(2026, 8, 24, 12, 0);

    final testItem = ItemModel(
      id: 'test-id-123',
      ownerId: 'user-456',
      type: ItemType.lost,
      title: 'Lost Calculator',
      description: 'Casio fx-991EX lost near EE Block',
      category: 'Electronics',
      location: 'EE Block Room 102',
      date: now,
      imageUrls: const ['https://example.com/image.jpg'],
      status: ItemStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    test('toFirestore should return valid map', () {
      final map = testItem.toFirestore();

      expect(map['ownerId'], 'user-456');
      expect(map['type'], 'lost');
      expect(map['title'], 'Lost Calculator');
      expect(map['category'], 'Electronics');
      expect(map['status'], 'active');
      expect(map['imageUrls'], ['https://example.com/image.jpg']);
      expect(map['date'], isA<Timestamp>());
    });

    test('ItemType enum strings should map correctly', () {
      expect(ItemType.lost.name, 'lost');
      expect(ItemType.found.name, 'found');
    });

    test('ItemStatus enum strings should map correctly', () {
      expect(ItemStatus.active.name, 'active');
      expect(ItemStatus.claimed.name, 'claimed');
      expect(ItemStatus.resolved.name, 'resolved');
    });
  });
}
