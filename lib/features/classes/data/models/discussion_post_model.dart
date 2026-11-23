import 'package:lengoal/core/utils/server_date.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';

// ClassDiscussion message DTO, shared by the post list and get-replies.
DiscussionPost discussionPostFromJson(Map<String, dynamic> json) {
  return DiscussionPost(
    id: json['id'] as String? ?? '',
    parentPostId: _nonEmpty(json['parentPostId']),
    senderUserId: json['senderUserId'] as String?,
    senderName: json['senderName'] as String? ?? '',
    content: json['content'] as String? ?? '',
    createdAt: parseServerDate(json['createdAt'] as String?) ?? DateTime.now(),
    role: DiscussionUserRole.fromCode((json['userType'] as num?)?.toInt()),
    isEdited: json['isEdited'] as bool? ?? false,
    likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  );
}

String? _nonEmpty(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;
