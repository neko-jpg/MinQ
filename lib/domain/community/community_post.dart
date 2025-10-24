import 'package:equatable/equatable.dart';

class CommunityPost extends Equatable {
  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorDisplayName,
    required this.message,
    required this.createdAt,
    required this.likeCount,
    required this.flagged,
  });

  final String id;
  final String authorId;
  final String authorDisplayName;
  final String message;
  final DateTime createdAt;
  final int likeCount;
  final bool flagged;

  CommunityPost copyWith({int? likeCount}) {
    return CommunityPost(
      id: id,
      authorId: authorId,
      authorDisplayName: authorDisplayName,
      message: message,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      flagged: flagged,
    );
  }

  @override
  List<Object?> get props => [id, authorId, authorDisplayName, message, createdAt, likeCount, flagged];
}
