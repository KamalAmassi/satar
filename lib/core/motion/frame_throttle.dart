/// يحدّ معدل الرسم: يسمح بإطار فقط إذا مضى [interval] (مع سماحية صغيرة لاهتزاز vsync).
class FrameThrottle {
  FrameThrottle(this.interval) : _slack = interval ~/ 8;

  final Duration interval;
  final Duration _slack;
  Duration? _last;

  bool shouldEmit(Duration now) {
    final last = _last;
    if (last != null && now - last < interval - _slack) return false;
    _last = now;
    return true;
  }

  void reset() => _last = null;
}
