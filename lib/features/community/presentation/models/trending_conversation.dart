class TrendingConversation {
  const new({
    required this.title,
    required this.commentsLabel,
    required this.participantInitials,
  });

  final String title;
  final String commentsLabel;
  final List<String> participantInitials;
}

const mockTrendingConversations = [
  TrendingConversation(
    title: 'Financial Accounting and Taxes',
    commentsLabel: '1.1K',
    participantInitials: ['V', 'J', 'A'],
  ),
  TrendingConversation(
    title: 'Investment Banking Basics',
    commentsLabel: '1.1K',
    participantInitials: ['D', 'E', 'F'],
  ),
  TrendingConversation(
    title: 'Equity Finance Strategies',
    commentsLabel: '890',
    participantInitials: ['G', 'H'],
  ),
];
