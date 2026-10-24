class ChatMessage {
  const new({
    required this.text,
    required this.timestamp,
    required this.isMine,
    this.senderName,
  });

  final String text;
  final String timestamp;
  final bool isMine;
  final String? senderName;
}

const _text =
    'Secure your slice of sunshine! Make your deposit and get '
    'ready to bask in solar energy';

const mockThreadMessages = [
  ChatMessage(text: _text, timestamp: '08:15 pm', isMine: true),
  ChatMessage(
    text: _text,
    timestamp: '08:15 pm',
    isMine: false,
    senderName: 'Ayodeji Oloruntoba',
  ),
  ChatMessage(text: _text, timestamp: '08:15 pm', isMine: true),
  ChatMessage(text: _text, timestamp: '08:15 pm', isMine: true),
];

const mockRequestPreviewMessage = ChatMessage(
  text: _text,
  timestamp: '08:15 pm',
  isMine: false,
  senderName: 'Ayodeji Oloruntoba',
);
