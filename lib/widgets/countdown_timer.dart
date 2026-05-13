import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime? targetTime;
  final PrayerType? targetPrayer;
  final VoidCallback onTimerComplete;

  const CountdownTimer({
    super.key,
    required this.targetTime,
    required this.targetPrayer,
    required this.onTimerComplete,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer jika target sholat atau waktunya berubah
    if (widget.targetTime != oldWidget.targetTime ||
        widget.targetPrayer != oldWidget.targetPrayer) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();

    if (widget.targetTime == null) {
      setState(() => _timeLeft = Duration.zero);
      return;
    }

    _calculateTimeLeft();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    if (widget.targetTime == null) return;

    final now = DateTime.now();
    final difference = widget.targetTime!.difference(now);

    if (difference.isNegative || difference.inSeconds == 0) {
      _timer?.cancel();
      setState(() => _timeLeft = Duration.zero);
      // Trigger callback ketika waktu habis agar parent merefresh data (ganti hari dll)
      widget.onTimerComplete();
    } else {
      setState(() => _timeLeft = difference);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.targetTime == null || widget.targetPrayer == null) {
      return const SizedBox.shrink(); // Jangan tampilkan jika tidak ada target
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: AppColors.countdownGradient,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Menuju ${widget.targetPrayer!.label}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCountdown(_timeLeft),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pukul ${formatTime(widget.targetTime!)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
