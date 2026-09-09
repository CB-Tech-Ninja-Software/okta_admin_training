import 'dart:async';
import 'package:flutter/material.dart';
import 'package:directory_dash/core/constants/exam_constants.dart';

class ExamCountdown extends StatefulWidget {
  const ExamCountdown({super.key});

  @override
  State<ExamCountdown> createState() => _ExamCountdownState();
}

class _ExamCountdownState extends State<ExamCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _hasTarget = false;

  @override
  void initState() {
    super.initState();
    _tick();
    if (_hasTarget) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _tick() {
    final targetStr = ExamConstants.targetExamDateIso;
    if (targetStr == null || targetStr.isEmpty) {
      if (_hasTarget) {
        setState(() {
          _hasTarget = false;
          _remaining = Duration.zero;
        });
      }
      return;
    }

    final target = DateTime.tryParse(targetStr);
    if (target == null) {
      if (_hasTarget) {
        setState(() {
          _hasTarget = false;
          _remaining = Duration.zero;
        });
      }
      return;
    }

    final diff = target.difference(DateTime.now());
    setState(() {
      _hasTarget = true;
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (!_hasTarget) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary.withAlpha(60), scheme.primary.withAlpha(15)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.primary.withAlpha(90)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXAM STATUS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 28, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'No exam date scheduled',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Study at your own pace across all 8 Part I domains & Part II use cases.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final isExamTime = _remaining == Duration.zero;
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary.withAlpha(60), scheme.primary.withAlpha(15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isExamTime ? "IT'S EXAM TIME" : 'TIME UNTIL EXAM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          if (isExamTime)
            const Text('Go show them what you know. 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _unit('$days', 'days'),
                _unit(hours.toString().padLeft(2, '0'), 'hrs'),
                _unit(minutes.toString().padLeft(2, '0'), 'min'),
                _unit(seconds.toString().padLeft(2, '0'), 'sec'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _unit(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

