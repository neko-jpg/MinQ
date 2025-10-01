import 'package:cloud_firestore/cloud_firestore.dart';

class Pair {
  final String id;
  final List<String> members;
  final String category;
  final DateTime createdAt;
  final DateTime? lastHighfiveAt;

  Pair({
    required this.id,
    required this.members,
    required this.category,
    required this.createdAt,
    this.lastHighfiveAt,
  });

  String? get user1Id => members.isNotEmpty ? members[0] : null;
  String? get user2Id => members.length >= 2 ? members[1] : null;

  factory Pair.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Pair(
      id: snapshot.id,
      members: List<String>.from(data['members'] ?? []),
      category: data['category'] ?? 'general',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastHighfiveAt: (data['lastHighfiveAt'] as Timestamp?)?.toDate(),
    );
  }
}
