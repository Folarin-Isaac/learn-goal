import 'package:equatable/equatable.dart';

enum DiscussionUserRole {
  admin(1),
  educator(2),
  learner(4);

  DiscussionUserRole(this.code);

  final int code;

  static DiscussionUserRole fromCode(int? code) => values.firstWhere(
    (role) => role.code == code,
    orElse: () => DiscussionUserRole.learner,
  );
}

// One message in a class discussion. Top-level posts have no
// parentPostId; replies point at the post they answer.
class DiscussionPost extends Equatable {
  const new({
    required this.id,
    required this.senderName,
    required this.content,
    required this.createdAt,
    this.parentPostId,
    this.senderUserId,
    this.role = DiscussionUserRole.learner,
    this.isEdited = false,
    this.likeCount = 0,
  });

  final String id;
  final String? parentPostId;
  final String? senderUserId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final DiscussionUserRole role;
  final bool isEdited;
  final int likeCount;

  @override
  List<Object?> get props => [
    id,
    parentPostId,
    senderUserId,
    senderName,
    content,
    createdAt,
    role,
    isEdited,
    likeCount,
  ];
}
