class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.studentId,
    this.department,
    this.role,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? studentId;
  final String? department;
  final String? role;
}
