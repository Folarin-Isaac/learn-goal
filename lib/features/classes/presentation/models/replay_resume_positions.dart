class ReplayResumePositions {
  const new();

  static const Duration _minimumWorthResuming = Duration(seconds: 10);
  static const Duration _endMargin = Duration(seconds: 15);
  static final Map<String, Duration> _positions = {};

  static Duration? of(String key) => _positions[key];

  static void save(String key, Duration position, Duration duration) {
    final nearEnd =
        duration > Duration.zero && position >= duration - _endMargin;
    if (position < _minimumWorthResuming || nearEnd) {
      _positions.remove(key);
    } else {
      _positions[key] = position;
    }
  }
}
