import 'package:flutter/material.dart';

class CommunityPost {
  const new({
    required this.authorName,
    required this.authorTag,
    required this.authorInitial,
    required this.avatarColor,
    required this.timestamp,
    required this.body,
    required this.likeCount,
    required this.commentCount,
    this.replies = const [],
  });

  final String authorName;
  final String authorTag;
  final String authorInitial;
  final Color avatarColor;
  final String timestamp;
  final String body;
  final int likeCount;
  final int commentCount;
  final List<CommunityPost> replies;
}

const _bodyText =
    'The certification develops your strategic thinking abilities, '
    'technical skills, and professional values, which are vital and '
    'highly valuable in any business environment.';

const mockCommunityPosts = [
  CommunityPost(
    authorName: 'Victoria Chad',
    authorTag: 'CFA level 2 May 2025 Candidate',
    authorInitial: 'V',
    avatarColor: Color(0xFF8B5E3C),
    timestamp: '5:45 pm / 12 July 2023',
    body: _bodyText,
    likeCount: 11,
    commentCount: 11,
    replies: [
      CommunityPost(
        authorName: 'Jenny Wilson',
        authorTag: 'ACCA Cohort 1 Tutor',
        authorInitial: 'J',
        avatarColor: Color(0xFF4A3B2A),
        timestamp: '5:45 pm / 12 July 2023',
        body: _bodyText,
        likeCount: 11,
        commentCount: 11,
      ),
      CommunityPost(
        authorName: 'Jenny Wilson',
        authorTag: 'ACCA Cohort 1 Tutor',
        authorInitial: 'J',
        avatarColor: Color(0xFF4A3B2A),
        timestamp: '5:45 pm / 12 July 2023',
        body: _bodyText,
        likeCount: 11,
        commentCount: 11,
      ),
    ],
  ),
  CommunityPost(
    authorName: 'Victoria Chad',
    authorTag: 'CFA level 2 May 2025 Candidate',
    authorInitial: 'V',
    avatarColor: Color(0xFF8B5E3C),
    timestamp: '5:45 pm / 12 July 2023',
    body: _bodyText,
    likeCount: 11,
    commentCount: 11,
  ),
];
