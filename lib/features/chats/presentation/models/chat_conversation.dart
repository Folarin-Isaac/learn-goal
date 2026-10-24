import 'package:flutter/material.dart';

enum ChatThreadType { group, direct, request }

class ChatConversation {
  const new({
    required this.name,
    required this.avatarInitial,
    required this.avatarColor,
    required this.preview,
    required this.timestamp,
    required this.unreadCount,
    required this.type,
    this.lastSenderName,
  });

  final String name;
  final String avatarInitial;
  final Color avatarColor;
  final String preview;
  final String timestamp;
  final int unreadCount;
  final ChatThreadType type;
  final String? lastSenderName;
}

const mockGroupChats = [
  ChatConversation(
    name: 'Gross Anatomy',
    avatarInitial: 'G',
    avatarColor: Color(0xFF8B5E3C),
    preview: 'make sure you at...',
    lastSenderName: 'Jenny Wilson',
    timestamp: '5:45 pm',
    unreadCount: 1,
    type: ChatThreadType.group,
  ),
  ChatConversation(
    name: 'Natural sciences and na...',
    avatarInitial: 'N',
    avatarColor: Color(0xFFF5B400),
    preview: 'make sure you atte...',
    lastSenderName: 'John smith',
    timestamp: '2:42 pm',
    unreadCount: 1,
    type: ChatThreadType.group,
  ),
  ChatConversation(
    name: 'Geography and places',
    avatarInitial: 'G',
    avatarColor: Color(0xFF4A3B2A),
    preview: 'make sure you a...',
    lastSenderName: 'Theresa Webb',
    timestamp: '5:45 pm',
    unreadCount: 1,
    type: ChatThreadType.group,
  ),
];

const mockDirectChats = [
  ChatConversation(
    name: 'Ayodeji Oloruntoba',
    avatarInitial: 'A',
    avatarColor: Color(0xFF8B5E3C),
    preview: 'Make sure you attend the next c...',
    timestamp: '5:45 pm',
    unreadCount: 1,
    type: ChatThreadType.direct,
  ),
  ChatConversation(
    name: 'John Smith',
    avatarInitial: 'J',
    avatarColor: Color(0xFFF5B400),
    preview: 'Make sure you attend the next c...',
    timestamp: '2:42 pm',
    unreadCount: 1,
    type: ChatThreadType.direct,
  ),
  ChatConversation(
    name: 'Theresa Webb',
    avatarInitial: 'T',
    avatarColor: Color(0xFF4A3B2A),
    preview: 'Make sure you attend the next c...',
    timestamp: '5:45 pm',
    unreadCount: 1,
    type: ChatThreadType.direct,
  ),
];

const mockChatRequests = [
  ChatConversation(
    name: 'Ayodeji Oloruntoba',
    avatarInitial: 'A',
    avatarColor: Color(0xFF8B5E3C),
    preview: 'Make sure you attend the next c...',
    timestamp: '5:45 pm',
    unreadCount: 1,
    type: ChatThreadType.request,
  ),
  ChatConversation(
    name: 'John Smith',
    avatarInitial: 'J',
    avatarColor: Color(0xFFF5B400),
    preview: 'Make sure you attend the next c...',
    timestamp: '2:42 pm',
    unreadCount: 1,
    type: ChatThreadType.request,
  ),
  ChatConversation(
    name: 'Theresa Webb',
    avatarInitial: 'T',
    avatarColor: Color(0xFF4A3B2A),
    preview: 'Make sure you attend the next c...',
    timestamp: '5:45 pm',
    unreadCount: 1,
    type: ChatThreadType.request,
  ),
];
