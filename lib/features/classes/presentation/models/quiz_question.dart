class QuizQuestion {
  const new({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  final String text;
  final List<String> options;
  final int correctOptionIndex;
}
