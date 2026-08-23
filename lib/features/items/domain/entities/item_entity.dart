enum ItemType { lost, found }

enum ItemStatus { active, claimed, resolved }

class ItemEntity {
  const ItemEntity({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;

  final ItemType type;
  final String title;
  final String description;
  final String category;
  final String location;

  final DateTime date;

  final List<String> imageUrls;

  final ItemStatus status;

  final DateTime? createdAt;
  final DateTime? updatedAt;
}
