class ActiveTimer {
  const ActiveTimer({
    required this.categoryId,
    required this.startTime,
    this.memo,
  });

  final String categoryId;
  final DateTime startTime;
  final String? memo;

  int elapsedSecondsAt(DateTime now) =>
      now.difference(startTime).inSeconds.clamp(0, 1 << 30);
}
