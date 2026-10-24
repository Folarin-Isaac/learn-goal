class PracticeStats {
  const new({
    required this.averagePercent,
    required this.solvedPercent,
    required this.mockPercent,
    required this.percentileRank,
    required this.mockSolvedPercent,
    required this.avgSeconds,
    required this.avgSecondsPercent,
  });

  final int averagePercent;
  final int solvedPercent;
  final int mockPercent;
  final int percentileRank;
  final int mockSolvedPercent;
  final int avgSeconds;
  final int avgSecondsPercent;
}

const mockPracticeStats = PracticeStats(
  averagePercent: 80,
  solvedPercent: 45,
  mockPercent: 68,
  percentileRank: 45,
  mockSolvedPercent: 45,
  avgSeconds: 23,
  avgSecondsPercent: 40,
);
