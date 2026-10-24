class SubscriptionHistoryItem {
  const new({
    required this.label,
    required this.amount,
    required this.date,
    this.isPaid = true,
  });

  final String label;
  final String amount;
  final String date;
  final bool isPaid;
}

const mockSubscriptionHistory = [
  SubscriptionHistoryItem(
    label: 'Class',
    amount: 'NGN 30,000',
    date: '20/07/23',
  ),
  SubscriptionHistoryItem(
    label: 'Evaluation',
    amount: 'NGN 10,000',
    date: '20/07/23',
  ),
  SubscriptionHistoryItem(
    label: 'Class',
    amount: 'NGN 30,000',
    date: '20/07/23',
  ),
  SubscriptionHistoryItem(
    label: 'Class',
    amount: 'NGN 30,000',
    date: '20/07/23',
  ),
  SubscriptionHistoryItem(
    label: 'Class',
    amount: 'NGN 30,000',
    date: '20/07/23',
  ),
  SubscriptionHistoryItem(
    label: 'Evaluation',
    amount: 'NGN 10,000',
    date: '20/07/23',
  ),
];
